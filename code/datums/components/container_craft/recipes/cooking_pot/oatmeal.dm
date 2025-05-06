/datum/container_craft/cooking/oatmeal
	max_optionals = 2
	created_reagent = /datum/reagent/consumable/soup/oatmeal
	requirements =  list(/obj/item/reagent_containers/food/snacks/produce/grain/oat = 1)
	optional_wildcard_requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit = 2,
		/obj/item/reagent_containers/food/snacks/produce/vegetable = 2
	)

/datum/container_craft/cooking/oatmeal/after_craft(atom/created_output, obj/item/crafter, mob/initiator, list/found_optional_requirements, list/found_optional_wildcards, list/found_optional_reagents)
	. = ..()
	var/datum/reagent/consumable/soup/oatmeal/found_oatmeal = crafter.reagents.get_reagent(/datum/reagent/consumable/soup/oatmeal)
	var/extra_string = " with mashed "
	if(length(found_optional_wildcards))
		var/atom/movable/first = found_optional_wildcards[1]
		first = found_optional_wildcards[first]
		extra_string += first.name
		for(var/atom/movable/other in found_optional_wildcards)
			if(found_optional_wildcards[other] == first)
				return
			var/atom/movable/located = found_optional_wildcards[other]
			extra_string += " and [located.name]"
		found_oatmeal.name += extra_string
