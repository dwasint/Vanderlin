/datum/distillation_recipe/sea_salt
	name = "Sea Salt"
	id = "sea_salt"
	distilled_reagent = /datum/reagent/water/salty
	consume_reagents = TRUE
	results = list(
		/datum/reagent/consumable/sodiumchloride = 0.2,
		/datum/reagent/water = 0.8
	)
	required_temp = T0C + 100
	distill_message = "The water boils away leaving salt."
