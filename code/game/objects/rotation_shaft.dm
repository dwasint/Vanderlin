/obj/structure/rotation_piece
	name = "shaft"

	icon = 'icons/roguetown/misc/shafts_cogs.dmi'
	icon_state = "shaft"

/obj/structure/rotation_piece/Initialize()
	. = ..()
	try_find_rotation_group()

/obj/structure/rotation_piece/cog
	name = "cog"

	icon_state = "1"

	var/cog_size = COG_SMALL

/obj/structure/rotation_piece/cog/try_find_rotation_group()

	for(var/direction in GLOB.cardinals)
		var/turf/step_back = get_step(src, direction)
		for(var/obj/structure/structure in step_back.contents)
			if(structure.rotation_data)
				if(rotation_data)
					rotation_data.try_merge_groups(src, structure.rotation_data)
				else
					structure.rotation_data.add_child(src)


/obj/structure/rotation_piece/cog/return_connected(list/came_from)
	var/list/connected = list()
	if(!came_from)
		came_from = list()
	came_from |= src
	connected |= src

	for(var/direction in GLOB.cardinals)
		var/turf/step_forward = get_step(src, direction)
		for(var/obj/structure/structure in step_forward.contents)
			if(structure in came_from)
				continue
			if(structure in rotation_data.children)
				connected |= structure.return_connected(came_from)

	return connected

/obj/structure/rotation_piece/cog/update_animation_effect()
	if(!rotation_data || rotation_data?.rotations_per_minute <= 0)
		animate(src, icon_state = "1", time = 1)
		return
	var/frame_stage = 1 / ((rotation_data.rotations_per_minute / 60) * 4)
	if(rotation_data.rotation_direction == WEST)
		animate(src, icon_state = "1", time = frame_stage, loop=-1)
		animate(icon_state = "2", time = frame_stage)
		animate(icon_state = "3", time = frame_stage)
		animate(icon_state = "4", time = frame_stage)
	else
		animate(src, icon_state = "4", time = frame_stage, loop=-1)
		animate(icon_state = "3", time = frame_stage)
		animate(icon_state = "2", time = frame_stage)
		animate(icon_state = "1", time = frame_stage)
