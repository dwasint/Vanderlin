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
	name = "Cheesecake Base"

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
	name = "Berry Cheesecake Base"

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
	name = "Raisin Cheesecake Base"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry
	output = /obj/item/reagent_containers/food/snacks/chescake
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 6 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Adding some juicy fruit filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/chescake_raisan
	name = "Cheesecake Base"

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
	name = "Cake Base"

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

/datum/repeatable_crafting_recipe/cooking/grenzelbun_alt
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

/datum/repeatable_crafting_recipe/cooking/cake_pear
	name = "Zybantu Cake Base"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/pear = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/pear
	output = /obj/item/reagent_containers/food/snacks/zybcake
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding mouth-watering pear filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cake_plum
	name = "Crimson Pine Cake Base"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/plum = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/plum
	output = /obj/item/reagent_containers/food/snacks/crimsoncake
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding some fine plum filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cake_tangerine
	name = "Scarletharp Cake Base"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/tangerine = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/tangerine
	output = /obj/item/reagent_containers/food/snacks/tangerinecake
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding some tangy tangerine filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/cake_strawberry
	name = "Strawberry Cake Base"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/strawberry = 1,
		/obj/item/reagent_containers/food/snacks/cake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cake
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/strawberry
	output = /obj/item/reagent_containers/food/snacks/strawbycake
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding some tangy tangerine filling..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_cheesecake
	name = "Unbaked Cheesecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cheese = 1,
		/obj/item/reagent_containers/food/snacks/chescake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/chescake
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese
	output = /obj/item/reagent_containers/food/snacks/chescake_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Spreading fresh cheese on the cake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_cheesecake_poison
	hides_from_books = TRUE
	name = "Unbaked Cheesecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cheese = 1,
		/obj/item/reagent_containers/food/snacks/chescake_poison = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/chescake_poison
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese
	output = /obj/item/reagent_containers/food/snacks/chescake_poison_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Spreading fresh cheese on the cake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_zybcake
	name = "Unbaked Zybantu Cake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/spiderhoney = 1,
		/obj/item/reagent_containers/food/snacks/zybcake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/zybcake
	starting_atom = /obj/item/reagent_containers/food/snacks/spiderhoney
	output = /obj/item/reagent_containers/food/snacks/zybcake_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Spreading spider-honey on the cake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_strawberrycake
	name = "Unbaked Strawberry Cake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/sugar = 1,
		/obj/item/reagent_containers/food/snacks/strawbycake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/strawbycake
	starting_atom = /obj/item/reagent_containers/food/snacks/sugar
	output = /obj/item/reagent_containers/food/snacks/strawbycake_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Spreading sugar frosting on the cake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_crimsoncake
	name = "Unbaked Crimson Cake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/chocolate = 1,
		/obj/item/reagent_containers/food/snacks/crimsoncake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/crimsoncake
	starting_atom = /obj/item/reagent_containers/food/snacks/chocolate
	output = /obj/item/reagent_containers/food/snacks/crimsoncake_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding chocolate to the dough..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_tangerinecake
	name = "Unbaked Scarletharp Cake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/sugar = 1,
		/obj/item/reagent_containers/food/snacks/tangerinecake = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/tangerinecake
	starting_atom = /obj/item/reagent_containers/food/snacks/sugar
	output = /obj/item/reagent_containers/food/snacks/tangerinecake_ready
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Spreading sugar frosting on the cake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_scone_tangerine
	name = "Unbaked Tangerine Scone"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/tangerine = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/scone_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/scone_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/tangerine
	output = /obj/item/reagent_containers/food/snacks/foodbase/scone_raw_tangerine
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding tangerine to the scone..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_scone_plum
	name = "Unbaked Plum Scone"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/plum = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/scone_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/scone_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/plum
	output = /obj/item/reagent_containers/food/snacks/foodbase/scone_raw_plum
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding plum to the scone..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_lemon
	name = "Unbaked Lemon Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/lemon = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/lemon
	output = /obj/item/reagent_containers/food/snacks/foodbase/lemongriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding lemon to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_apple
	name = "Unbaked Apple Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/apple = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/apple
	output = /obj/item/reagent_containers/food/snacks/foodbase/applegriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding apple to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_apple_alt
	name = "Unbaked Dried Apple Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/apple_dried = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/apple_dried
	output = /obj/item/reagent_containers/food/snacks/foodbase/applegriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding dried apple to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_berry
	name = "Unbaked Berry Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry
	output = /obj/item/reagent_containers/food/snacks/foodbase/berrygriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding jacksberry to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_berry_alt
	name = "Unbaked Raisin Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/raisins = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/raisins
	output = /obj/item/reagent_containers/food/snacks/foodbase/berrygriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding raisins to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/unbaked_griddlecake_berry_poison
	hides_from_books = TRUE
	name = "Unbaked Berry Griddlecake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison = 1,
		/obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/foodbase/griddlecake_raw
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/jacksberry/poison
	output = /obj/item/reagent_containers/food/snacks/foodbase/poisonberrygriddlecake_raw
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/gen_drop.ogg'
	crafting_message = "Adding jacksberry to the griddlecake..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/beef_mett
	name = "Grenzel Mett"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/veg/onion_sliced = 1,
		/obj/item/reagent_containers/food/snacks/meat/mince/beef = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/meat/mince/beef
	starting_atom = /obj/item/reagent_containers/food/snacks/veg/onion_sliced
	output = /obj/item/reagent_containers/food/snacks/meat/mince/beef/mett
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Kneading onions into the mince..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_sausage
	name = "Fatty Raw Sausage"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/fat = 1,
		/obj/item/reagent_containers/food/snacks/meat/mince = 1,
	)
	subtypes_allowed = TRUE
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/meat/mince
	starting_atom = /obj/item/reagent_containers/food/snacks/fat
	output = /obj/item/reagent_containers/food/snacks/meat/sausage
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Stuffing a wiener..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_sausage_inverse
	hides_from_books = TRUE
	name = "Fatty Raw Sausage"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/fat = 1,
		/obj/item/reagent_containers/food/snacks/meat/mince = 1,
	)
	subtypes_allowed = TRUE
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/fat
	starting_atom = /obj/item/reagent_containers/food/snacks/meat/mince
	output = /obj/item/reagent_containers/food/snacks/meat/sausage
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Stuffing a wiener..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/raw_sausage_alt
	name = "Lean Raw Sausage"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/meat/mince = 2,
	)
	subtypes_allowed = TRUE
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/meat/mince
	starting_atom = /obj/item/reagent_containers/food/snacks/meat/mince
	output = /obj/item/reagent_containers/food/snacks/meat/sausage
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Stuffing a wiener..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/pestranstick
	name = "Pestran Stick"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/butter = 1,
		/obj/item/grown/log/tree/stick = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/butter
	starting_atom = /obj/item/grown/log/tree/stick
	output = /obj/item/reagent_containers/food/snacks/pestranstick
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	crafting_message = "Skewering the butter..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_apple
	name = "Apple Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/apple = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/apple
	output = /obj/item/reagent_containers/food/snacks/jellycake_apple
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing apple into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_apple_alt
	name = "Dried Apple Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/apple_dried = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/apple_dried
	output = /obj/item/reagent_containers/food/snacks/jellycake_apple
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing dried apple into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_tangerine
	name = "Tangerine Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/tangerine = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/tangerine
	output = /obj/item/reagent_containers/food/snacks/jellycake_tangerine
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing tangerine into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_tangerine_alt
	name = "Dried Tangerine Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/tangerine_dried = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/tangerine_dried
	output = /obj/item/reagent_containers/food/snacks/jellycake_tangerine
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing dried tangerine into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_plum
	name = "Plum Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/plum = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/plum
	output = /obj/item/reagent_containers/food/snacks/jellycake_plum
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing plum into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_plum_alt
	name = "Dried Plum Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/plum_dried = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/plum_dried
	output = /obj/item/reagent_containers/food/snacks/jellycake_plum
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing dried plum into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_pear
	name = "Pear Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/pear = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/pear
	output = /obj/item/reagent_containers/food/snacks/jellycake_pear
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing pear into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_pear_alt
	name = "Dried Pear Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/pear_dried = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/pear_dried
	output = /obj/item/reagent_containers/food/snacks/jellycake_pear
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing dried pear into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/jellycake_lime
	name = "Lime Jellycake"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/produce/fruit/lime = 1,
		/obj/item/reagent_containers/food/snacks/jellycake_base = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/jellycake_base
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/fruit/lime
	output = /obj/item/reagent_containers/food/snacks/jellycake_lime
	minimum_skill_level = 3
	uses_attacked_atom = TRUE
	craft_time = 9 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	crafting_message = "Mixing lime into the gelatine..."
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/twoegg
	name = "Twin Eggs"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/egg = 2,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/egg
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/egg
	output = /obj/item/reagent_containers/food/snacks/cooked/twin_egg
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/valorian_omlette
	name = "Valorian Omlette"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/twin_egg = 1,
		/obj/item/reagent_containers/food/snacks/cheese_wedge = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/twin_egg
	starting_atom = /obj/item/reagent_containers/food/snacks/cheese_wedge
	output = /obj/item/reagent_containers/food/snacks/cooked/valorian_omlette
	uses_attacked_atom = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/frybird_tato
	name = "Frybird and Tatos"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/frybird = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/frybird
	starting_atom =/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked
	output = /obj/item/reagent_containers/food/snacks/cooked/frybird_tatos
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/frybird_tato
	hides_from_books = TRUE
	name = "Frybird and Tatos"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/frybird = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/frybird
	output = /obj/item/reagent_containers/food/snacks/cooked/frybird_tatos
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/frybird_tato
	name = "Frybird and Fried Tatos"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/frybird = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/fried = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/frybird
	starting_atom = /obj/item/reagent_containers/food/snacks/produce/vegetable/potato/fried
	output = /obj/item/reagent_containers/food/snacks/cooked/frybird_tatos
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/royal_truffle
	name = "Royal Truffles"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/ham = 1,
		/obj/item/reagent_containers/food/snacks/cooked/truffle = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/ham
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/truffle
	output = /obj/item/reagent_containers/food/snacks/cooked/royal_truffle
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/royal_truffle_toxic
	hides_from_books = TRUE
	name = "Royal Truffles"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/ham = 1,
		/obj/item/reagent_containers/food/snacks/cooked/truffle_toxic = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/ham
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/truffle_toxic
	output = /obj/item/reagent_containers/food/snacks/cooked/royal_truffle/toxin
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100

/datum/repeatable_crafting_recipe/cooking/frysteak_tato
	name = "Frysteak and Tatos"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/frysteak = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/frysteak
	starting_atom =/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked
	output = /obj/item/reagent_containers/food/snacks/cooked/frysteak_tatos
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding potato..."

/datum/repeatable_crafting_recipe/cooking/frysteak_tato
	name = "Frysteak and Onions"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/frysteak = 1,
		/obj/item/reagent_containers/food/snacks/onion_fried = 1,
	)
	required_table = TRUE
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/frysteak
	starting_atom =/obj/item/reagent_containers/food/snacks/onion_fried
	output = /obj/item/reagent_containers/food/snacks/cooked/frysteak_onion
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding onions..."

/datum/repeatable_crafting_recipe/cooking/wiener_cabbage
	name = "Wiener on Cabbage"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	starting_atom =/obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_cabbage
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding cabbage..."

/datum/repeatable_crafting_recipe/cooking/wiener_cabbage
	hides_from_books = TRUE
	name = "Wiener on Cabbage"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/produce/vegetable/cabbage
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_cabbage
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding cabbage..."

/datum/repeatable_crafting_recipe/cooking/wiener_potato
	name = "Wiener on Tato"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	starting_atom =/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_potato
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding potato..."

/datum/repeatable_crafting_recipe/cooking/wiener_potato
	name = "Wiener on Fried Tato"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/fried = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	starting_atom =/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/fried
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_potato
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding potato..."

/datum/repeatable_crafting_recipe/cooking/wiener_potato
	hides_from_books = TRUE
	name = "Wiener on Tato"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/produce/vegetable/potato/baked
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_potato
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding potato..."

/datum/repeatable_crafting_recipe/cooking/wiener_potato
	name = "Wiener on Onions"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/onion_fried = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	starting_atom =/obj/item/reagent_containers/food/snacks/onion_fried
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_onion
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding Onions..."

/datum/repeatable_crafting_recipe/cooking/wiener_potato
	hides_from_books = TRUE
	name = "Wiener on Onions"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/reagent_containers/food/snacks/onion_fried = 1,
	)
	starting_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	attacked_atom = /obj/item/reagent_containers/food/snacks/onion_fried
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_onion
	uses_attacked_atom = TRUE
	craft_time = 2 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Adding Onions..."

/datum/repeatable_crafting_recipe/cooking/wiener_stick
	name = "Skewered Wiener"
	subtypes_allowed = TRUE
	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage = 1,
		/obj/item/grown/log/tree/stick = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage
	starting_atom = /obj/item/grown/log/tree/stick
	output = /obj/item/reagent_containers/food/snacks/cooked/sausage_sticked
	uses_attacked_atom = TRUE
	craft_time = 3 SECONDS
	crafting_sound = 'sound/foley/dropsound/food_drop.ogg'
	extra_chance = 100
	crafting_message = "Skewering the sausage..."


/datum/repeatable_crafting_recipe/cooking/raw_griddledog
	name = "Raw Griddledog"

	requirements = list(
		/obj/item/reagent_containers/food/snacks/cooked/sausage_sticked = 1,
		/obj/item/reagent_containers/food/snacks/butterdough_slice = 1,
	)
	attacked_atom = /obj/item/reagent_containers/food/snacks/cooked/sausage_sticked
	starting_atom = /obj/item/reagent_containers/food/snacks/butterdough_slice
	output = /obj/item/reagent_containers/food/snacks/foodbase/griddledog_raw
	uses_attacked_atom = TRUE
	required_table = TRUE
	craft_time = 5 SECONDS
	crafting_sound = 'sound/foley/kneading_alt.ogg'
	extra_chance = 100
	crafting_message = "Covering sausage with dough..."
