/datum/spellcraft_contribution/infernalash
	atom_path = /obj/item/natural/infernalash
	form_points = list(
		FORM_FIRE = 1,
	)
	form_cost_multipliers = list(
		FORM_FIRE = 0.9,
		FORM_WATER = 1.2,
	)

/datum/spellcraft_contribution/hellhoundfang
	atom_path = /obj/item/natural/hellhoundfang
	form_points = list(
		FORM_FIRE = 1,
	)
	form_cast_speed_multipliers = list(
		FORM_FIRE = 1.1,
		FORM_WATER = 0.8,
	)

/datum/spellcraft_contribution/moltencore
	atom_path = /obj/item/natural/moltencore
	form_points = list(
		FORM_FIRE = 2,
	)
	form_cost_multipliers = list(
		FORM_FIRE = 1.2,
		FORM_WATER = 1.2,
	)
	technique_points = list(
		TECHNIQUE_DESTRUCTION = 1,
	)

/datum/spellcraft_contribution/abyssalflame
	atom_path = /obj/item/natural/abyssalflame
	form_points = list(
		FORM_FIRE = 4,
	)
	form_cost_multipliers = list(
		FORM_FIRE = 1.4,
		FORM_WATER = 2,
	)
	technique_points = list(
		TECHNIQUE_DESTRUCTION = 2,
		TECHNIQUE_IMBUE = 1,
	)


/datum/spellcraft_contribution/firedust
	atom_path = /obj/item/alch/firedust
	form_cost_multipliers = list(
		FORM_FIRE = 0.95,
	)
	form_cast_speed_multipliers = list(
		FORM_FIRE = 0.95,
	)
	form_magnitude_modifications = list(
		FORM_FIRE = 0.05,
	)
