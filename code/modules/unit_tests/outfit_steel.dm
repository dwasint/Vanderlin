/datum/unit_test/outfit_steel_items/Run()
	var/list/allowed_steel_outfits = list(
	)

	var/mob/living/carbon/human/dummy = allocate(/mob/living/carbon/human)

	for(var/outfit_type in subtypesof(/datum/outfit))
		var/datum/outfit/outfit = new outfit_type

		// Skip allowed outfits
		if(outfit_type in allowed_steel_outfits)
			continue

		// Equip the outfit
		dummy.equipOutfit(outfit_type, TRUE)

		// Check all contents
		for(var/obj/item/equipped_item in dummy.contents)
			if(equipped_item.melting_material == /datum/material/steel)
				TEST_FAIL("[outfit_type] contains steel item [equipped_item.type] which is not in the allowed list")

		// Strip for next iteration
		for(var/obj/item/equipped_item in dummy.contents)
			qdel(equipped_item)
