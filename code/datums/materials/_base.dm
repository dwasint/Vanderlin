/datum/material
	abstract_type = /datum/material

	var/name
	///temperature in kelvin this melts at, until we get refiners this is largely not a thing
	var/melting_point = 1358.15
	///the integrity modifier applied to created gear
	var/integrity_modifier = 1
	///are we glowing with heat?
	var/red_hot = FALSE

	///basically a list of material traits think things like firestarter etc
	var/list/traits = list()
	///our materials color
	var/color
	///how hard our material is
	var/hardness

	var/can_be_molded = FALSE
	var/obj/item/ingot/ingot_type
