/datum/blueprint_recipe/floor
	abstract_type = /datum/blueprint_recipe/floor

/datum/blueprint_recipe/floor/woodfloor
	name = "Wooden Floor"
	desc = "A ruined wooden floor."
	result_type = /turf/open/floor/ruinedwood
	required_materials = list(
		/obj/item/grown/log/tree/small = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 3 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1

/datum/blueprint_recipe/floor/woodfloor_dark
	name = "Dark Wooden Floor"
	desc = "A dark wooden floor."
	result_type = /turf/open/floor/wood
	required_materials = list(
		/obj/item/grown/log/tree/small = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 3 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1

/datum/blueprint_recipe/floor/woodplatform
	name = "Wood Platform"
	desc = "A wooden platform."
	result_type = /turf/open/floor/ruinedwood/platform
	required_materials = list(
		/obj/item/natural/wood/plank = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 4 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 1


/datum/blueprint_recipe/floor/stonefloor
	name = "Stone Floor"
	desc = "A cobbled stone floor."
	result_type = /turf/open/floor/cobblerock
	required_materials = list(
		/obj/item/natural/stone = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 4 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 0

/datum/blueprint_recipe/floor/stonefloor_cobblestone
	name = "Cobblestone Floor"
	desc = "A cobblestone floor."
	result_type = /turf/open/floor/cobble
	required_materials = list(
		/obj/item/natural/stone = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 4 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 0

/datum/blueprint_recipe/floor/stonefloor_blocks
	name = "Stone Block Floor"
	desc = "A stone block floor."
	result_type = /turf/open/floor/blocks
	required_materials = list(
		/obj/item/natural/stoneblock = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 5 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 1

/datum/blueprint_recipe/floor/stonefloor_newstone
	name = "Newstone Floor"
	desc = "A newstone floor."
	result_type = /turf/open/floor/blocks/newstone
	required_materials = list(
		/obj/item/natural/stoneblock = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 5 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 1

/datum/blueprint_recipe/floor/stonefloor_bluestone
	name = "Bluestone Floor"
	desc = "A bluestone floor."
	result_type = /turf/open/floor/blocks/bluestone
	required_materials = list(
		/obj/item/natural/stoneblock = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 5 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 1

/datum/blueprint_recipe/floor/stonefloor_herringbone
	name = "Herringbone Floor"
	desc = "A herringbone stone floor."
	result_type = /turf/open/floor/herringbone
	required_materials = list(
		/obj/item/natural/stoneblock = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 2

/datum/blueprint_recipe/floor/stonefloor_hexstone
	name = "Hexstone Floor"
	desc = "A hexagonal stone floor."
	result_type = /turf/open/floor/hexstone
	required_materials = list(
		/obj/item/natural/stoneblock = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 2


/datum/blueprint_recipe/floor/stoneplatform
	name = "Stone Platform"
	desc = "A stone platform."
	result_type = /turf/open/floor/blocks/platform
	required_materials = list(
		/obj/item/natural/stoneblock = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Floors"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 1


/datum/blueprint_recipe/floor/twig
	name = "Twig Floor"
	desc = "A floor made of twigs."
	result_type = /turf/open/floor/twig
	required_materials = list(
		/obj/item/grown/log/tree/stick = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 3 SECONDS
	category = "Floors"
	floor_object = TRUE

/datum/blueprint_recipe/floor/twigplatform
	name = "Twig Platform"
	desc = "A platform made of twigs and rope."
	result_type = /turf/open/floor/twig/platform
	required_materials = list(
		/obj/item/grown/log/tree/stick = 3,
		/obj/item/rope = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 4 SECONDS
	category = "Floors"
	floor_object = TRUE

	craftdiff = 1

/datum/blueprint_recipe/floor/dirt
	name = "Dirt Road"
	desc = "A dirt road."
	result_type = /turf/open/floor/dirt/road
	required_materials = list(
		/obj/item/natural/fibers = 1,
		/obj/item/natural/dirtclod = 3
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 4 SECONDS
	category = "Floors"
	floor_object = TRUE
