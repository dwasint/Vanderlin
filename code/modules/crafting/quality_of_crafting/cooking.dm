/datum/repeatable_crafting_recipe/cooking
	abstract_type = /datum/repeatable_crafting_recipe/cooking
	skillcraft = /datum/skill/craft/cooking


/datum/repeatable_crafting_recipe/cooking/soap
	name = "soap"
	tool_usage = list(
		/obj/item/pestle = list("starts to grind materials in the mortar", "start to grind materials in the mortar", 'sound/foley/mortarpestle.ogg'),
	)

	reagent_requirements = list(
		/datum/reagent/water = 10,
	)
	requirements = list(
		/obj/item/ash = 1,
		/obj/item/reagent_containers/food/snacks/fat = 1,
	)
	output = /obj/item/soap
	starting_atom = /obj/item/pestle
	attacked_atom = /obj/item/reagent_containers/glass/mortar
	tool_use_time = 4 SECONDS
	craft_time = 6 SECONDS

/datum/repeatable_crafting_recipe/cooking/soap/bath
	name = "herbal soap "
	tool_usage = list(
		/obj/item/pestle = list("starts to grind materials in the mortar", "start to grind materials in the mortar", 'sound/foley/mortarpestle.ogg'),
	)

	requirements = list(
		/obj/item/ash = 1,
		/obj/item/reagent_containers/food/snacks/fat = 1,
		/obj/item/alch/mentha = 1,
	)
	output = /obj/item/soap/bath

/datum/repeatable_crafting_recipe/cooking/chescake_poison
	hides_from_books = TRUE
	name = "Unbaked Cake of Cheese"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison
	output = /obj/item/reagent_containers/food/snacks/chescake_poison
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding some juicy fruit filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/chescake_poison_raisan
	hides_from_books = TRUE
	name = "Unbaked Cake of Cheese"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/raisins/poison = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins/poison
	output = /obj/item/reagent_containers/food/snacks/chescake_poison
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding some juicy fruit filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/chescake
	name = "Unbaked Berry Cake of Cheese"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry
	output = /obj/item/reagent_containers/food/snacks/chescake_poison
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding some juicy fruit filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/chescake_raisan
	name = "Unbaked Raisan Cake of Cheese"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/raisins = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins
	output = /obj/item/reagent_containers/food/snacks/chescake_poison
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding some juicy fruit filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cake_base
	name = "Unbaked Cake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/obj/item/reagent_containers/food/snacks/butterdough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough
	starting_atom = /obj/item/reagent_containers/food/snacks/egg
	output = /obj/item/reagent_containers/food/snacks/cake
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Working egg into the dough, shaping it into a cake..."
	minimum_skill_level = 2
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/biscuit_poison
	hides_from_books = TRUE
	name = "Unbaked Raisan Biscuit"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/raisins/poison = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins/poison
	output = /obj/item/reagent_containers/food/snacks/foodbase/biscuitpoison_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding raisins to the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/biscuit_berry
	name = "Unbaked Raisan Biscuit"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/raisins = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins
	output = /obj/item/reagent_containers/food/snacks/foodbase/biscuit_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding berries to the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/biscuit_berry/create_outputs(list/to_delete, mob/user)
	var/output_path = output
	if(user.mind.get_skill_level(/datum/skill/craft/cooking) >= 2)
		output_path =  /obj/item/reagent_containers/food/snacks/foodbase/biscuit_raw/good
	var/list/outputs = list()

	for(var/spawn_count = 1 to output_amount)
		var/obj/item/new_item = new output_path(get_turf(user))

		new_item.sellprice = sellprice
		new_item.randomize_price()

		if(length(pass_types_in_end))
			var/list/parts = list()
			for(var/obj/item/listed as anything in to_delete)
				if(!is_type_in_list(listed, pass_types_in_end))
					continue
				parts += listed
			new_item.CheckParts(parts)
			new_item.OnCrafted(user.dir, user)

		outputs += new_item

	return outputs

/datum/repeatable_crafting_recipe/cooking/unbaked_scones
	name = "Unbaked Scones"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/sugar = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/sugar
	output = /obj/item/reagent_containers/food/snacks/foodbase/scone_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	minimum_skill_level = 2
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding sugar to the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/dough
	name = "Dough"
	requirements = list(
		/obj/item/reagent_containers/powder/flour = 1,
		/obj/item/reagent_containers/food/snacks/dough_base = 1,
	)
	attacked_atom = /obj/item/reagent_containers/powder/flour
	starting_atom = /obj/item/reagent_containers/food/snacks/dough_base
	output = /obj/item/reagent_containers/food/snacks/dough
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading.ogg'
	crafting_message = "Kneading in more flour..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/dough_alt
	hides_from_books = TRUE
	name = "Dough"
	requirements = list(
		/obj/item/reagent_containers/powder/flour = 1,
		/obj/item/reagent_containers/food/snacks/dough_base = 1,
	)
	starting_atom = /obj/item/reagent_containers/powder/flour
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough_base
	output = /obj/item/reagent_containers/food/snacks/dough
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading.ogg'
	crafting_message = "Kneading in more flour..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/butter_dough
	name = "Butter Dough"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough = 1,
		/obj/item/reagent_containers/food/snacks/butterslice = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/butterslice
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough
	output = /obj/item/reagent_containers/food/snacks/butterdough
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Kneading butter into the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raisin_dough_poison
	hides_from_books = TRUE
	name = "Raisin Dough"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough = 1,
		/obj/item/reagent_containers/food/snacks/raisins/poison = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins/poison
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough
	output = /obj/item/reagent_containers/food/snacks/raisindough_poison
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading.ogg'
	crafting_message = "Kneading the dough and adding raisins..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raisin_dough
	name = "Raisin Dough"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough = 1,
		/obj/item/reagent_containers/food/snacks/raisins = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough
	output = /obj/item/reagent_containers/food/snacks/raisindough
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading.ogg'
	crafting_message = "Kneading the dough and adding raisins..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/reform_dough
	name = "Reform Dough"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough_slice = 2,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/dough_slice
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough_slice
	output = /obj/item/reagent_containers/food/snacks/dough
	uses_attacked_atom = TRUE
	required_table = TRUE
	craftdiff = 0
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading.ogg'
	crafting_message = "Combining dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cheesebun
	name = "Raw Gote Cheesebun"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough_slice = 1,
		/obj/item/reagent_containers/food/snacks/cheese/gote = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese/gote
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough_slice
	output = /obj/item/reagent_containers/food/snacks/foodbase/cheesebun_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Adding fresh gote cheese..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cheesebun_wedge
	name = "Raw Wedge Cheesebun"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough_slice = 1,
		/obj/item/reagent_containers/food/snacks/cheese_wedge = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese_wedge
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough_slice
	output = /obj/item/reagent_containers/food/snacks/foodbase/cheesebun_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Adding cheese..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cheesebun_fresh
	name = "Raw Fresh Cheesebun"
	requirements = list(
		/obj/item/reagent_containers/food/snacks/dough_slice = 1,
		/obj/item/reagent_containers/food/snacks/cheese = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese
	attacked_atom = /obj/item/reagent_containers/food/snacks/dough_slice
	output = /obj/item/reagent_containers/food/snacks/foodbase/cheesebun_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Adding fresh cheese..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/apple_fritter_raw
	name = "Raw Apple Fritter"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/apple = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/apple
	output = /obj/item/reagent_containers/food/snacks/foodbase/fritter_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding apple bits to the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/apple_fritter_raw/create_outputs(list/to_delete, mob/user)
	var/output_path = output
	if(user.mind.get_skill_level(/datum/skill/craft/cooking) >= 2)
		output_path =  /obj/item/reagent_containers/food/snacks/foodbase/fritter_raw/good
	var/list/outputs = list()

	for(var/spawn_count = 1 to output_amount)
		var/obj/item/new_item = new output_path(get_turf(user))

		new_item.sellprice = sellprice
		new_item.randomize_price()

		if(length(pass_types_in_end))
			var/list/parts = list()
			for(var/obj/item/listed as anything in to_delete)
				if(!is_type_in_list(listed, pass_types_in_end))
					continue
				parts += listed
			new_item.CheckParts(parts)
			new_item.OnCrafted(user.dir, user)

		outputs += new_item

	return outputs

/datum/repeatable_crafting_recipe/cooking/raw_griddle_cake
	name = "Raw Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/egg = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/egg
	output = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	minimum_skill_level = 1
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/eggbreak.ogg'
	sound_volume = 100
	crafting_message = "Working egg into the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_griddle_dog
	name = "Raw Griddledog"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage_sticked = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage_sticked
	output = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	sound_volume = 90
	crafting_message = "Covering sausage with dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_mushroom
	name = "Raw Mushroom Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/truffles = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/truffles
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/mushroom
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_mushroom
	name = "Raw Mince Handpie"

	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/meat/mince = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/meat/mince
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/mince
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_poison
	hides_from_books = TRUE
	name = "Raw Berry Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/poison
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_berry
	name = "Raw Berry Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/berry
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_apple
	name = "Raw Apple Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/apple = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/apple
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/apple
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_gote
	name = "Raw Gote Cheese Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cheese/gote = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese/gote
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/cheese
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_cheddar
	name = "Raw Cheddar Cheese Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cheese_wedge = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese_wedge
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/cheese
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_handpie_fresh
	name = "Raw Fresh Cheese Handpie"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cheese = 1,
		/obj/item/reagent_containers/food/snacks/piedough = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/piedough
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese
	output = /obj/item/reagent_containers/food/snacks/foodbase/handpieraw/cheese
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Making a handpie..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/grenzelbun
	name = "Grenzel Bun"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/bun = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/bun
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	output = /obj/item/reagent_containers/food/snacks/grenzelbun
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/grenzelbun
	hides_from_books = TRUE
	name = "Grenzel Bun"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/bun = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/bun
	attacked_atom  = /obj/item/reagent_containers/food/snacks/cooked/sausage
	output = /obj/item/reagent_containers/food/snacks/grenzelbun
	uses_attacked_atom = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	extra_chance = 100
