/datum/unit_test/turf_coverage/Run()
	var/list/all_turfs = subtypesof(/turf)
	var/list/all_blueprint_recipes = subtypesof(/datum/blueprint_recipe)
	var/list/used_turfs = list()

	for(var/recipe_type in all_blueprint_recipes)
		var/datum/blueprint_recipe/recipe = new recipe_type()
		if(recipe.result_type && ispath(recipe.result_type, /turf))
			used_turfs |= recipe.result_type
		qdel(recipe)

	var/list/blacklisted_turfs = list(
		/turf/closed,
		/turf/closed/splashscreen,
	) + typesof(/turf/closed/indestructible) + typesof(/turf/open/water) + typesof(/turf/open/lava)
	used_turfs |= blacklisted_turfs

	// Find unused turfs
	var/list/unused_turfs = list()
	for(var/turf_type in all_turfs)
		if(!(turf_type in used_turfs))
			unused_turfs += turf_type

	var/unused_list = ""
	for(var/i = 1; i <= unused_turfs.len; i++)
		unused_list += "[unused_turfs[i]]"
		if(i < unused_turfs.len)
			unused_list += ", "

	TEST_ASSERT(!length(unused_turfs), "The following turfs are not used by any blueprint recipe or in the blacklist: [unused_list]")
