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
