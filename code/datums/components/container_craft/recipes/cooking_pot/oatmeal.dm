/datum/container_craft/cooking/oatmeal
	created_reagent = /datum/reagent/consumable/soup/oatmeal
	requirements =  list(/obj/item/reagent_containers/food/snacks/produce/grain/oat = 1)
	optional_requirements = list(/obj/item/reagent_containers/food/snacks/produce/fruit = 1)

/datum/container_craft/cooking/oatmeal/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents)
	. = ..()
	var/datum/reagent/consumable/soup/oatmeal/found_oatmeal = crafter.reagents.get_reagent(/datum/reagent/consumable/soup/oatmeal)
	if(length(found_optional_requirements))
		var/atom/movable/first = found_optional_requirements[1]
		found_oatmeal.name = "oatmeal with mashed [first.name]"
