GLOBAL_LIST_EMPTY(blueprint_appearance_cache)
GLOBAL_LIST_EMPTY(active_blueprints)
GLOBAL_LIST_EMPTY(blueprint_recipes)

#define BLUEPRINT_SWITCHSTATE_NONE 0
#define BLUEPRINT_SWITCHSTATE_RECIPES 1

/proc/init_blueprint_recipes()
	if(GLOB.blueprint_recipes.len)
		return
	for(var/datum/blueprint_recipe/recipe as anything in subtypesof(/datum/blueprint_recipe))
		if(is_abstract(recipe))
			continue
		GLOB.blueprint_recipes[initial(recipe.name)] = new recipe

/datum/blueprint_recipe
	var/name = "Unknown Structure"
	var/desc = "A mysterious structure."
	var/atom/result_type = null // What gets built
	var/list/required_materials = list() // Materials needed (path = amount)
	var/atom/construct_tool
	var/build_time = 5 SECONDS
	var/category = "General"
	var/supports_directions = FALSE // Whether this recipe can be rotated
	var/default_dir = SOUTH // Default direction for the recipe
	///do we take up the whole floor?
	var/floor_object = FALSE

	var/datum/skill/skillcraft = /datum/skill/craft/crafting // What skill this recipe requires (e.g., /datum/skill/craft/carpentry)
	var/craftdiff = 0 // Difficulty modifier (0 = easy, higher = harder)
	var/verbage = "construct" // What the user does (e.g., "build", "assemble")
	var/verbage_tp = "constructs" // Third person version
	var/craftsound = 'sound/foley/bandage.ogg'
	var/edge_density = TRUE

/mob
	var/datum/blueprint_system/blueprints

/mob/proc/enter_blueprint()
	if(!client)
		return
	ADD_TRAIT(src, TRAIT_BLUEPRINT_VISION, TRAIT_GENERIC)
	blueprints = new(client)
