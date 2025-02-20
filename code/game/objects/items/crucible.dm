/obj/item/crucible
	name = "crucible"
	layer = ABOVE_ALL_MOB_LAYER

	icon = 'icons/roguetown/weapons/crucible.dmi'
	icon_state = "crucible"


/obj/item/crucible/Initialize()
	. = ..()
	create_reagents(100)

/obj/item/crucible/examine(mob/user)
	. = ..()
	var/datum/reagent/molten_metal/metal = reagents.get_reagent(/datum/reagent/molten_metal)
	if(metal)
		for(var/datum/material/material as anything in metal.data)
			var/total_volume = metal.data[material]
			var/reagent_color = initial(material.color)
			if(total_volume / 3 < 1)
				. += "It contains less than 1 oz of <font color=[reagent_color]> Molten [initial(material.name)].</font>"
			else
				. += "It contains [round(total_volume / 3)] oz of <font color=[reagent_color]> Molten [initial(material.name)].</font>"

/obj/item/crucible/update_overlays()
	. = ..()
	if(overlays)
		overlays.Cut()

	if(!reagents.total_volume)
		return
	var/mutable_appearance/MA = mutable_appearance(icon, "filling")

	MA.color = mix_color_from_reagents(reagents.reagent_list)
	var/datum/reagent/molten_metal/metal = reagents.get_reagent(/datum/reagent/molten_metal)
	var/datum/material/largest = metal?.largest_metal
	if(initial(largest?.red_hot) && reagents.chem_temp > 500)
		var/mutable_appearance/MA2 = mutable_appearance(icon, "filling")
		MA2.plane = EMISSIVE_PLANE
		overlays += MA2

	overlays += MA

/obj/item/crucible/test_crucible
	var/list/material_data_to_add = list(
		/datum/material/copper = 18,
		/datum/material/tin = 2
	)
	var/temperature = 1500

/obj/item/crucible/test_crucible/Initialize()
	. = ..()
	reagents.add_reagent(/datum/reagent/molten_metal, 20, data = material_data_to_add, reagtemp = 4000)
	update_overlays()

/obj/item/crucible/test_crucible/bar
	material_data_to_add = list(
		/datum/material/copper = 90,
		/datum/material/tin = 10,
	)

/obj/item/crucible/test_crucible/copper
	material_data_to_add = list(
		/datum/material/copper = 100,
	)

/obj/item/crucible/test_crucible/tin
	material_data_to_add = list(
		/datum/material/tin = 100,
	)

/obj/item/crucible/test_crucible/gold
	material_data_to_add = list(
		/datum/material/gold = 100,
	)

/obj/item/crucible/test_crucible/silver
	material_data_to_add = list(
		/datum/material/silver = 100,
	)

/obj/item/crucible/test_crucible/steel
	material_data_to_add = list(
		/datum/material/steel = 100,
	)

/obj/item/crucible/test_crucible/blacksteel
	material_data_to_add = list(
		/datum/material/blacksteel = 100,
	)
