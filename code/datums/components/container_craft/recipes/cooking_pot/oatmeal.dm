/datum/container_craft/cooking/oatmeal
	max_optionals = 2
	created_reagent = /datum/reagent/consumable/soup/oatmeal
	requirements = list(/obj/item/reagent_containers/food/snacks/produce/grain/oat = 1)
	optional_wildcard_requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit = 2,
		/obj/item/reagent_containers/food/snacks/produce/vegetable = 2
	)

/datum/container_craft/cooking/oatmeal/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents)
	. = ..()
	var/datum/reagent/consumable/soup/oatmeal/found_oatmeal = crafter.reagents.get_reagent(/datum/reagent/consumable/soup/oatmeal)

	if(!length(found_optional_wildcards))
		return

	var/extra_string = " with mashed "
	var/first_ingredient = TRUE

	var/list/all_used_ingredients = list()

	for(var/wildcard_type in found_optional_wildcards)
		var/list/items = found_optional_wildcards[wildcard_type]
		for(var/obj/item/ingredient in items)
			all_used_ingredients += ingredient

	for(var/obj/item/ingredient in all_used_ingredients)
		if(first_ingredient)
			extra_string += ingredient.name
			first_ingredient = FALSE
		else
			extra_string += " and [ingredient.name]"

	found_oatmeal.name += extra_string
