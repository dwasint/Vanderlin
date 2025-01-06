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
