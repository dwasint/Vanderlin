/datum/chimeric_organs/input/reagent/alcohol
	name = "dwarven"
	desc = "Will trigger from any drank reagent but remove non alcoholic drinks"
	is_special = TRUE
	node_purity = 100 // No delay
	tier = 4
	minimum_amount = 0

/datum/chimeric_organs/input/reagent/alcohol/on_reagent_added(datum/reagent/consumed_reagent, consumed_amount, method)
	if(istype(consumed_reagent, /datum/reagent/consumable/ethanol))
		trigger_output(TRUE, consumed_amount)
	else if(istype(consumed_reagent, /datum/reagent/consumable))
		hosted_carbon.reagents.remove_reagent(consumed_reagent.type, consumed_amount) // you don't get to enjoy non alcoholic drinks anymore
		trigger_output(FALSE)
