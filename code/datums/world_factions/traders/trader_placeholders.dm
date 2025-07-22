///Sale signs
/obj/structure/trader_sign
	name = "holographic store sign"
	desc = "A holographic sign that promises great deals."
	icon = 'icons/obj/trader_signs.dmi'
	icon_state = "faceless"
	anchored = TRUE
	max_integrity = 15
	layer = FLY_LAYER

/obj/structure/trader_sign/Initialize(mapload)
	. = ..()
	add_overlay("sign")
