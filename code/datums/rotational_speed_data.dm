/obj/structure
	var/rotation_provider = FALSE
	var/datum/rotational_information/rotation_data
	var/stress_generation = 0
	var/rotation_speed = 0
	var/rotation_direction = EAST

/obj/structure/Destroy()
	. = ..()
	if(rotation_data)
		if(rotation_provider)
			rotation_data.remove_provider(src)
		rotation_data.remove_child(src)

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
	var/torque = 1
	var/rotation_direction = EAST

	var/list/children = list()
	var/list/providers = list()
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

/datum/rotational_information/proc/set_rotational_direction(direction = EAST, obj/structure/incoming)
	if(length(providers) > 1)
		for(var/obj/structure/provider in providers)
			if(provider.rotation_direction != direction)
				return
	rotation_direction = direction
	update_animation_effect()

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
				return

	highest_provider = incoming
	rotation_direction = direction
	rotations_per_minute = amount
	update_animation_effect()

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
		remove_child(structure)
		new_group.add_child(structure)

	new_group.get_next_provider()
