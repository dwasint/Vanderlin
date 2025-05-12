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
