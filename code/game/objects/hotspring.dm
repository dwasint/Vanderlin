/particles/hotspring_steam
	icon = 'icons/effects/particles/smoke.dmi'
	icon_state = list(
		"steam_cloud_1" = 1,
		"steam_cloud_2" = 1,
		"steam_cloud_3" = 1,
		"steam_cloud_4" = 1,
		"steam_cloud_5" = 1,
	)
	color = "#FFFFFF8A"
	count = 5
	spawning = 0.3
	lifespan = 3 SECONDS
	fade = 1.2 SECONDS
	fadein = 0.4 SECONDS
	position = generator(GEN_BOX, list(-17,-15,0), list(24,15,0), NORMAL_RAND)
	scale = generator(GEN_VECTOR, list(0.9,0.9), list(1.1,1.1), NORMAL_RAND)
	drift = generator(GEN_SPHERE, list(-0.01,0), list(0.01,0.01), UNIFORM_RAND)
	spin = generator(GEN_NUM, list(-2,2), NORMAL_RAND)
	gravity = list(0.05, 0.28)
	friction = 0.3
	grow = 0.037

/obj/structure/hotspring
	nomouseover = TRUE
	plane = FLOOR_PLANE
	icon = 'icons/obj/structures/hotspring.dmi'
	icon_state = "hotspring"

	var/obj/effect/abstract/particle_holder/cached/particle_effect

/obj/structure/hotspring/Initialize()
	. = ..()
	particle_effect = new(src, /particles/hotspring_steam, 6)
	//render the steam over mobs and objects on the game plane
	particle_effect.vis_flags &= ~VIS_INHERIT_PLANE

	AddElement(/datum/element/mob_overlay_effect, 2, -2, 100)

/obj/structure/hotspring/border
	icon_state = "hotspring_border_1"

/obj/structure/hotspring/border/two
	icon_state = "hotspring_border_2"

/obj/structure/hotspring/border/three
	icon_state = "hotspring_border_3"

/obj/structure/hotspring/border/four
	icon_state = "hotspring_border_4"

/obj/structure/hotspring/border/five
	icon_state = "hotspring_border_5"

/obj/structure/hotspring/border/six
	icon_state = "hotspring_border_6"

/obj/structure/hotspring/border/seven
	icon_state = "hotspring_border_7"

/obj/structure/hotspring/border/eight
	icon_state = "hotspring_border_8"

/obj/structure/hotspring/border/nine
	icon_state = "hotspring_border_9"

/obj/structure/hotspring/border/ten
	icon_state = "hotspring_border_10"

/obj/structure/hotspring/border/eleven
	icon_state = "hotspring_border_11"

/obj/structure/hotspring/border/twelve
	icon_state = "hotspring_border_12"

/obj/structure/hotspring/border/thirteen
	icon_state = "hotspring_border_13"

/obj/structure/hotspring/border/fourteen
	icon_state = "hotspring_border_14"

/obj/structure/flora/rock/hotspring
	name = "large rock"

	icon = 'icons/obj/structures/hotspring.dmi'
	icon_state = "bigrock"

/obj/structure/flora/rock/hotspring/grassy
	name = "grassy large rock"
	icon_state = "bigrock_grass"

/obj/structure/flora/rock/hotspring/small
	name = "small rock"
	density = FALSE
	icon_state = "stones_1"

/obj/structure/flora/rock/hotspring/small/two
	icon_state = "stones_2"

/obj/structure/flora/rock/hotspring/small/three
	icon_state = "stones_3"

/obj/structure/flora/rock/hotspring/small/four
	icon_state = "stones_4"

/obj/structure/flora/rock/hotspring/small/five
	icon_state = "stones_5"

/obj/machinery/light/fueled/torchholder/hotspring
	name = "stone lantern"
	icon = 'icons/obj/structures/hotspring.dmi'
	icon_state = "stonelantern1"
	base_state = "stonelantern"

/obj/machinery/light/fueled/torchholder/hotspring/standing
	name = "standing stone lantern"
	icon_state = "stonelantern_standing1"
	base_state = "stonelantern_standing"

/obj/effect/lily_petal
	name = "lily petals"
	icon = 'icons/obj/structures/hotspring.dmi'
	icon_state = "lilypetals1"

/obj/effect/lily_petal/two
	icon_state = "lilypetals2"

/obj/effect/lily_petal/three
	icon_state = "lilypetals3"

/obj/structure/chair/hotspring_bench
	name = "park bench"
	icon_state = "parkbench_sofamiddle"
	icon = 'icons/obj/structures/hotspring.dmi'
	buildstackamount = 1
	item_chair = null

/obj/structure/chair/hotspring_bench/left
	icon_state = "parkbench_sofaend_left"

/obj/structure/chair/hotspring_bench/right
	icon_state = "parkbench_sofaend_right"

/obj/structure/chair/hotspring_bench/corner
	icon_state = "parkbench_corner"
