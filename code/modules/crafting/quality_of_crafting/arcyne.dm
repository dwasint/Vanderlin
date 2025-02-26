/datum/repeatable_crafting_recipe/arcyne
	abstract_type = /datum/repeatable_crafting_recipe/arcyne
	reagent_requirements = list(
		/datum/reagent/medicine/manapot = 15
	)
	requirements = list(
		/obj/item/natural/stone = TRUE
	)
	tool_usage = list(
		/obj/item/weapon/knife = list("starts to carve out a rune", "start to carve a rune")
	)

	attacking_atom = /obj/item/weapon/knife
	starting_atom = /obj/item/natural/stone
	skillcraft = /datum/skill/magic/arcane
	craftdiff = 0
	subtypes_allowed = TRUE // so you can use any subtype of fur

/datum/repeatable_crafting_recipe/arcyne/arcana
	name = "amethyst"
	output = /obj/item/gem/amethyst

/datum/repeatable_crafting_recipe/arcyne/infernal_feather
	name = "infernal feather"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/infernalash = 2,
		/obj/item/natural/feather = 1,
	)
	output = /obj/item/natural/feather/infernal
	attacking_atom = /obj/item/natural/feather
	starting_atom = /obj/item/natural/infernalash
	uses_attacking_atom = TRUE
	craftdiff = 2

/datum/repeatable_crafting_recipe/arcyne/sending_stone
	name = "sending stones"
	reagent_requirements = list()
	requirements = list(
		/obj/item/gem/amethyst = 2,
		/obj/item/natural/stone = 2,
		/obj/item/natural/melded/t1 = 1,
	)
	output = /obj/item/sendingstonesummoner
	uses_attacking_atom = TRUE
	craftdiff = 2

/datum/repeatable_crafting_recipe/arcyne/voidlamptern
	name = "void lamptern"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t1  = 1,
		/obj/item/natural/obsidian = 1,
		/obj/item/flashlight/flare/torch/lantern = 1,
	)
	output = /obj/item/flashlight/flare/torch/lantern/voidlamptern
	starting_atom = /obj/item/flashlight/flare/torch/lantern
	attacking_atom = /obj/item/natural/obsidian
	uses_attacking_atom = TRUE
	craftdiff = 2

/datum/repeatable_crafting_recipe/arcyne/nomagicglove
	name = "mana binding gloves"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t2  = 1,
		/obj/item/clothing/gloves/roguetown/leather = 1,
		/obj/item/gem = 1,
	)
	output = /obj/item/clothing/gloves/roguetown/nomagic
	starting_atom = /obj/item/clothing/gloves/roguetown/leather
	attacking_atom = /obj/item/gem
	uses_attacking_atom = TRUE
	craftdiff = 3

/datum/repeatable_crafting_recipe/arcyne/temporalhourglass
	name = "temporal hourglass"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t2  = 1,
		/obj/item/natural/glass = 1,
		/obj/item/gem = 1,
	)
	output = /obj/item/hourglass/temporal
	starting_atom = /obj/item/natural/glass
	attacking_atom = /obj/item/natural/melded/t2
	uses_attacking_atom = TRUE
	craftdiff = 3

/datum/repeatable_crafting_recipe/arcyne/shimmeringlens
	name = "shimmering lens"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t2  = 1,
		/obj/item/natural/leyline = 1,
		/obj/item/natural/iridescentscale = 1,
	)
	output = /obj/item/clothing/ring/active/shimmeringlens
	starting_atom = /obj/item/natural/iridescentscale
	attacking_atom = /obj/item/natural/leyline
	uses_attacking_atom = TRUE
	craftdiff = 3

/datum/repeatable_crafting_recipe/arcyne/mimictrinket
	name = "mimic trinket"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t2  = 1,
		/obj/item/natural/wood/plank = 2,
	)
	output = /obj/item/mimictrinket
	starting_atom = /obj/item/natural/wood/plank
	attacking_atom = /obj/item/natural/melded/t2
	uses_attacking_atom = TRUE
	craftdiff = 3

/datum/repeatable_crafting_recipe/arcyne/binding
	name = "binding shackles"
	reagent_requirements = list()
	tool_usage = list()
	requirements = list(
		/obj/item/natural/melded/t2  = 1,
		/obj/item/ingot/iron = 2,
	)
	output = /obj/item/rope/chain/bindingshackles
	starting_atom = /obj/item/ingot/iron
	attacking_atom = /obj/item/natural/melded/t2
	uses_attacking_atom = TRUE
	craftdiff = 2
