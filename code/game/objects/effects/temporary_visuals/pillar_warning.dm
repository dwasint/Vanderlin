
/obj/effect/temp_visual/pillar_warning
	icon = 'icons/effects/effects.dmi'
	icon_state = "spellwarning"
	layer = ABOVE_MOB_LAYER
	duration = 2 SECONDS

/obj/effect/temp_visual/pillar_warning/Initialize(mapload, life)
	if(life)
		duration = life
	. = ..()

/obj/effect/temp_visual/pillar_warning/fadein
	alpha = 0

/obj/effect/temp_visual/pillar_warning/fadein/Initialize(mapload, life)
	. = ..()
	animate(src, alpha = 255, time = duration)
