/datum/blueprint_recipe/wall
	abstract_type = /datum/blueprint_recipe/wall

/datum/blueprint_recipe/wall/woodwall
	name = "Wood Wall"
	desc = "A wooden wall."
	result_type = /turf/closed/wall/mineral/wood
	required_materials = list(
		/obj/item/grown/log/tree/small = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 5 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry

/datum/blueprint_recipe/wall/woodwindow
	name = "Wood Murder Hole"
	desc = "A wooden wall with a murder hole."
	result_type = /turf/closed/wall/mineral/wood/window
	required_materials = list(
		/obj/item/grown/log/tree/small = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry


/datum/blueprint_recipe/wall/dwoodwall
	name = "Dark Wood Wall"
	desc = "A dark wooden wall."
	result_type = /turf/closed/wall/mineral/wooddark
	required_materials = list(
		/obj/item/natural/wood/plank = 3
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 7 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 2

/datum/blueprint_recipe/wall/dwoodwindow
	name = "Dark Wood Window"
	desc = "A dark wooden wall with a window."
	result_type = /turf/closed/wall/mineral/wooddark/window
	required_materials = list(
		/obj/item/natural/wood/plank = 3
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 7 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/carpentry
	craftdiff = 2


/datum/blueprint_recipe/wall/stonewall
	name = "Stone Wall"
	desc = "A stone wall."
	result_type = /turf/closed/wall/mineral/stone
	required_materials = list(
		/obj/item/natural/stone = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry

/datum/blueprint_recipe/wall/stonewindow
	name = "Stone Murder Hole"
	desc = "A stone wall with a murder hole."
	result_type = /turf/closed/wall/mineral/stone/window
	required_materials = list(
		/obj/item/natural/stone = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 7 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry

/datum/blueprint_recipe/wall/stonebrick
	name = "Stone Brick Wall"
	desc = "A stone brick wall."
	result_type = /turf/closed/wall/mineral/stonebrick
	required_materials = list(
		/obj/item/natural/stoneblock = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 8 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 2

/datum/blueprint_recipe/wall/fancyswall
	name = "Decorated Stone Wall"
	desc = "A decorated stone wall."
	result_type = /turf/closed/wall/mineral/decostone
	required_materials = list(
		/obj/item/natural/stoneblock = 3
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 10 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 2

/datum/blueprint_recipe/wall/craftstone
	name = "Craftstone Wall"
	desc = "A craftstone wall."
	result_type = /turf/closed/wall/mineral/craftstone
	required_materials = list(
		/obj/item/natural/stoneblock = 3
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 12 SECONDS
	category = "Walls"
	floor_object = TRUE

	skillcraft = /datum/skill/craft/masonry
	craftdiff = 3


/datum/blueprint_recipe/wall/tentwall
	name = "Tent Wall"
	desc = "A temporary tent wall."
	result_type = /turf/closed/wall/mineral/tent
	required_materials = list(
		/obj/item/grown/log/tree/stick = 1,
		/obj/item/natural/cloth = 1
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 3 SECONDS
	category = "Walls"
	floor_object = TRUE

/datum/blueprint_recipe/wall/daubwall
	name = "Daub Wall"
	desc = "A daub wall made of sticks and dirt."
	result_type = /turf/closed/wall/mineral/decowood
	required_materials = list(
		/obj/item/grown/log/tree/stick = 3,
		/obj/item/natural/dirtclod = 2
	)
	construct_tool = /obj/item/weapon/hammer
	build_time = 6 SECONDS
	category = "Walls"
	floor_object = TRUE
