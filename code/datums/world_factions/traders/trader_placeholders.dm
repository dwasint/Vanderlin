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

GLOBAL_LIST_EMPTY(trader_location)

/obj/effect/landmark/stall
	name = "trader stall location"
	var/claimed_by_trader = FALSE

/obj/effect/landmark/stall/Initialize()
	. = ..()
	GLOB.trader_location += src

/obj/effect/landmark/stall/Destroy()
	. = ..()
	GLOB.trader_location -= src
