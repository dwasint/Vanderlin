///so this is the most important step of the dungeon maker if you don't put these down right your gonna obliterate the dungeon
/obj/effect/dungeon_directional_helper
	name = "Dungeon Direction Helper"
	desc = "These help stitch together dungeons, it looks for the opposite direction on a template, basically write in the template if it has this"

	var/top = FALSE

/obj/effect/dungeon_directional_helper/Initialize()
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/dungeon_directional_helper/LateInitialize()
	var/turf/opposite_turf = get_step(get_turf(src), dir)

	if(!locate(/obj/effect/dungeon_directional_helper) in opposite_turf)
		SSdungeon_generator.find_soulmate(dir, get_turf(src), src)

/obj/effect/dungeon_directional_helper/south
	dir = SOUTH

/obj/effect/dungeon_directional_helper/north
	dir = NORTH

/obj/effect/dungeon_directional_helper/east
	dir = EAST

/obj/effect/dungeon_directional_helper/west
	dir = WEST

/obj/effect/dungeon_directional_helper/south/top
	dir = SOUTH
	top = TRUE

/obj/effect/dungeon_directional_helper/north/top
	dir = NORTH
	top = TRUE

/obj/effect/dungeon_directional_helper/east/top
	dir = EAST
	top = TRUE

/obj/effect/dungeon_directional_helper/west/top
	dir = WEST
	top = TRUE
