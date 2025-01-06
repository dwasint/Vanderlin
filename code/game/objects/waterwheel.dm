
/obj/structure/waterwheel
	name = "waterwheel"

	icon = 'icons/roguetown/misc/waterwheel.dmi'
	icon_state = "1"

	rotation_provider = TRUE
	stress_generation = 1024
	layer = 5

/obj/structure/waterwheel/Initialize()
	. = ..()
	try_find_rotation_group()

	var/turf/open/water/river/water = get_turf(src)
	if(!istype(water))
		return
	if(water.water_volume)
		set_rotational_direction_and_speed(water.dir, 12)

/obj/structure/waterwheel/update_animation_effect()
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
