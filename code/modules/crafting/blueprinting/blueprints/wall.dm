/datum/blueprint_recipe/wall
	abstract_type = /datum/blueprint_recipe/wall
	category = "Walls"

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

/datum/blueprint_recipe/wall/solid_window
	name = "Solid Glass Window"
	desc = "A solid framed window."
	required_materials = list(
		/obj/item/natural/wood/plank = 4,
		/obj/item/natural/glass = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/carpentry
	result_type = /turf/closed/wall/window

/datum/blueprint_recipe/wall/solid_window/alt
	name = "Alternative Solid Glass Window"
	result_type = /turf/closed/wall/window/openclose

/datum/blueprint_recipe/wall/silver_window
	name = "Solid Silver Stained Glass Window"
	desc = "A solid framed window."
	required_materials = list(
		/obj/item/ingot/silver = 2,
		/obj/item/natural/glass = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/blacksmithing
	result_type = /turf/closed/wall/window/stained

/datum/blueprint_recipe/wall/silver_window
	name = "Alternative Solid Silver Stained Glass Window"
	result_type = /turf/closed/wall/window/stained/alt

/datum/blueprint_recipe/wall/red_window
	name = "Solid Red Stained Glass Window"
	desc = "A solid framed window."
	required_materials = list(
		/obj/item/ingot/iron = 2,
		/obj/item/natural/glass = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/blacksmithing
	result_type = /turf/closed/wall/window/stained/red

/datum/blueprint_recipe/wall/yellow_window
	name = "Solid Yellow Stained Glass Window"
	desc = "A solid framed window."
	required_materials = list(
		/obj/item/ingot/iron = 2,
		/obj/item/natural/glass = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/blacksmithing
	result_type = /turf/closed/wall/window/stained/yellow


/datum/blueprint_recipe/wall/stonewindow
	name = "Solid Stone Window"
	desc = "A solid framed window."
	required_materials = list(
		/obj/item/natural/stoneblock = 2,
		/obj/item/natural/fibers = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/masonry
	result_type = /turf/closed/wall/mineral/stone/window

/datum/blueprint_recipe/wall/stonewindow/moss
	name = "Solid Mossy Stone Window"
	result_type = /turf/closed/wall/mineral/stone/window/moss

/datum/blueprint_recipe/wall/stonewindow/blue
	name = "Solid Mossy Bluestone Window"
	result_type = /turf/closed/wall/mineral/stone/window/moss/blue

/datum/blueprint_recipe/wall/stonewindow/red
	name = "Solid Mossy Redstone Window"
	result_type = /turf/closed/wall/mineral/stone/window/moss/red

/datum/blueprint_recipe/wall/mossstone
	name = "Mossy Stone Wall"
	desc = "A stone wall covered in moss."
	required_materials = list(
		/obj/item/natural/stoneblock = 2,
		/obj/item/natural/fibers = 2,
	)
	craftdiff = 2
	skillcraft = /datum/skill/craft/masonry
	result_type = /turf/closed/wall/mineral/stone/moss

/datum/blueprint_recipe/wall/mossstone/blue
	name = "Mossy Bluestone Wall"
	result_type = /turf/closed/wall/mineral/stone/moss/blue

/datum/blueprint_recipe/wall/mossstone/red
	name = "Mossy Redstone Wall"
	result_type = /turf/closed/wall/mineral/stone/moss/red
