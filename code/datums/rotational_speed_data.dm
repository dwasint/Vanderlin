/obj/structure
	var/rotation_provider = FALSE
	var/datum/rotational_information/rotation_data
	var/stress_generation = 0
	var/rotation_speed = 0
	var/rotation_direction = EAST
	///this is how much stress we use as a baseline torque affects it aswell as speed the stress is multipled by 2 for every stress_multiplier rpm's their is
	var/stress_use = 0
	///this is basically do we want to connect via a cog type or shaft
	var/required_connection_type = COG_SMALL

	var/stress_multiplier = 30
	var/cog_type = COG_SMALL

/obj/structure/Destroy()
	. = ..()
	if(rotation_data)
		if(rotation_provider)
			rotation_data.remove_provider(src)
		rotation_data.remove_child(src)

/obj/structure/proc/get_effective_speed()
	if(!rotation_data)
		return 0
	return rotation_data.rotations_per_minute / stress_multiplier

/obj/structure/proc/try_find_rotation_group()
	var/turf/step_forward = get_step(src, dir)
	for(var/obj/structure/structure in step_forward.contents)
		if(structure.rotation_data)
			structure.rotation_data.add_child(src)

	var/turf/step_back = get_step(src, GLOB.reverse_dir[dir])
	for(var/obj/structure/structure in step_back.contents)
		if(structure.rotation_data)
			if(rotation_data)
				rotation_data.try_merge_groups(src, structure.rotation_data)
			else
				structure.rotation_data.add_child(src)

	if(!rotation_data)
		rotation_data = new
		rotation_data.add_child(src)

/obj/structure/proc/add_stress_use()
	if(!rotation_data)
		return
	rotation_data.add_stress_user(src)

/obj/structure/proc/remove_stress_use()
	if(!rotation_data)
		return
	rotation_data.remove_stress_user(src)

/obj/structure/proc/return_connected(list/came_from)
	var/list/connected = list()
	if(!came_from)
		came_from = list()
	came_from |= src
	connected |= src

	var/turf/step_forward = get_step(src, dir)
	for(var/obj/structure/structure in step_forward.contents)
		if(structure in came_from)
			continue
		if(structure in rotation_data.children)
			connected |= structure.return_connected(came_from)

	var/turf/step_back = get_step(src, GLOB.reverse_dir[dir])
	for(var/obj/structure/structure in step_back.contents)
		if(structure in came_from)
			continue
		if(structure in rotation_data.children)
			connected |= structure.return_connected(came_from)
	return connected

/obj/structure/proc/set_rotational_speed(amount = 8)
	if(!rotation_provider)
		return
	if(!rotation_data)
		rotation_data = new
		rotation_data.children |= src
	rotation_speed = amount
	rotation_data.set_rotational_speed(amount, src)

/obj/structure/proc/set_rotational_direction(direction = EAST)
	if(!rotation_provider)
		return
	if(!rotation_data)
		rotation_data = new
		rotation_data.children |= src
	rotation_direction = direction
	rotation_data.set_rotational_direction(direction, src)

/obj/structure/proc/set_rotational_direction_and_speed(direction = EAST, amount = 8)
	if(!rotation_provider)
		return
	if(!rotation_data)
		rotation_data = new
		rotation_data.children |= src
	rotation_speed = amount
	rotation_direction = direction
	rotation_data.set_rotational_direction_and_speed(direction, amount, src)

/obj/structure/proc/update_animation_effect()
	return

/datum/rotational_information
	var/rotations_per_minute = 0
	var/total_stress = 0
	var/used_stress = 0
	var/torque = 1
	var/rotation_direction = EAST
	var/overstressed = FALSE

	var/list/children = list()
	var/list/providers = list()
	var/list/conflicting_providers = list()

	var/list/stress_users = list()
	var/obj/structure/highest_provider

/datum/rotational_information/proc/set_rotational_speed(amount = 8, obj/structure/incoming, force =FALSE)
	if(!force)
		if(amount > 0 && !(incoming in providers))
			add_provider(incoming)
		else if((incoming in providers) && amount <= 0)
			remove_provider(incoming)

		if(amount < rotations_per_minute && incoming != highest_provider)
			return
	rotations_per_minute = amount
	highest_provider = incoming
	update_animation_effect()
	adjust_stress_usage()

/datum/rotational_information/proc/set_rotational_direction(direction = EAST, obj/structure/incoming)
	if(length(providers) > 1)
		for(var/obj/structure/provider in providers)
			if(provider.rotation_direction != direction)
				conflicting_providers |= incoming
				breakdown()
				return

	if(incoming in conflicting_providers)
		conflicting_providers -= incoming
		for(var/obj/particle_emitter/emitter in incoming.particle_emitters)
			if(emitter.particles.type == /particles/smoke)
				incoming.particle_emitters -= emitter
				qdel(emitter)
		restore()
	rotation_direction = direction
	update_animation_effect()
	adjust_stress_usage()

/datum/rotational_information/proc/set_rotational_direction_and_speed(direction = EAST, amount = 8, obj/structure/incoming)
	if(amount > 0 && !(incoming in providers))
		add_provider(incoming)
	else if((incoming in providers) && amount <= 0)
		remove_provider(incoming)

	if(amount < rotations_per_minute && incoming != highest_provider)
		return

	if(length(providers) > 1)
		for(var/obj/structure/provider in providers)
			if(provider.rotation_direction != direction)
				conflicting_providers |= incoming
				breakdown()
				return

	if(incoming in conflicting_providers)
		conflicting_providers -= incoming
		for(var/obj/particle_emitter/emitter in incoming.particle_emitters)
			if(emitter.particles.type == /particles/smoke)
				incoming.particle_emitters -= emitter
				qdel(emitter)
		restore()

	highest_provider = incoming
	rotation_direction = direction
	rotations_per_minute = amount
	update_animation_effect()
	adjust_stress_usage()

/datum/rotational_information/proc/update_animation_effect()
	for(var/obj/structure/child as anything in children)
		child.update_animation_effect()

/datum/rotational_information/proc/add_provider(obj/structure/incoming)
	if(incoming in providers)
		return
	providers |= incoming
	total_stress += incoming.stress_generation


/datum/rotational_information/proc/remove_provider(obj/structure/incoming)
	providers -= incoming
	total_stress -= incoming.stress_generation
	if(incoming in conflicting_providers)
		conflicting_providers -= incoming
		restore()
	if(highest_provider == incoming)
		get_next_provider()

/datum/rotational_information/proc/get_next_provider(obj/structure/incoming)
	var/obj/structure/highest
	var/highest_number = 0
	for(var/obj/structure/provider in providers)
		if(provider.rotation_speed > highest_number)
			highest = provider
			highest_number = provider.rotation_speed

	highest_provider = highest
	set_rotational_speed(highest_number, highest, TRUE)
	adjust_stress_usage()

/datum/rotational_information/proc/add_child(obj/structure/child)
	children |= child
	child.rotation_data = src
	child.update_animation_effect()

/datum/rotational_information/proc/remove_child(obj/structure/child)
	children -= child
	child.rotation_data = null
	child.update_animation_effect()
	reasses_group()

/datum/rotational_information/proc/try_merge_groups(obj/structure/source, datum/rotational_information/opposing_group)
	if(opposing_group.rotation_direction != rotation_direction)
		source.visible_message(span_warning("[source] breaks apart from the opposing directions!"))
		playsound(source, 'sound/foley/cartdump.ogg', 75)
		remove_child(source)
		qdel(source)
		return

	if(opposing_group.rotations_per_minute > rotations_per_minute)
		set_rotational_speed(opposing_group.rotations_per_minute, opposing_group.highest_provider)

	for(var/obj/structure/provider in opposing_group.providers)
		add_provider(provider)

	for(var/obj/structure/child in opposing_group.children)
		add_child(child)

	qdel(opposing_group)

/datum/rotational_information/proc/reasses_group()
	while(length(children))
		var/list/connected = list()

		var/obj/structure/child = pick(children)
		connected = child.return_connected()

		make_new_group(connected)

/datum/rotational_information/proc/make_new_group(list/groupmates)

	var/datum/rotational_information/new_group = new
	new_group.rotation_direction = rotation_direction
	for(var/obj/structure/structure in groupmates)
		if(structure.rotation_provider)
			remove_provider(structure)
			new_group.add_provider(structure)
		if(structure.stress_use)
			remove_stress_user(structure)
			new_group.add_stress_user(structure)
		remove_child(structure)
		new_group.add_child(structure)

	new_group.get_next_provider()

/datum/rotational_information/proc/adjust_stress_usage()
	used_stress = 0

	for(var/obj/structure/user in stress_users)
		var/stress_multiplier = max(FLOOR(rotations_per_minute / user.stress_multiplier, 1),1)

		used_stress += stress_multiplier * user.stress_use

	if(used_stress > total_stress)
		breakdown()
	else if(overstressed)
		restore()

/datum/rotational_information/proc/breakdown()
	rotations_per_minute = 0
	overstressed = TRUE
	update_animation_effect()

	for(var/obj/structure/child in children)
		if(child in conflicting_providers)
			var/obj/particle_emitter/emitter = child.MakeParticleEmitter(/particles/smoke, FALSE)
			emitter.layer = child.layer + 1
		else
			child.MakeParticleEmitter(/particles/smoke, FALSE, 1 SECONDS)

/datum/rotational_information/proc/restore()
	if(length(conflicting_providers))
		return
	rotations_per_minute = highest_provider.rotation_speed
	overstressed = FALSE

	update_animation_effect()

/datum/rotational_information/proc/add_stress_user(obj/structure/user)
	stress_users |= user
	adjust_stress_usage()

/datum/rotational_information/proc/remove_stress_user(obj/structure/user)
	stress_users -= user
	adjust_stress_usage()
