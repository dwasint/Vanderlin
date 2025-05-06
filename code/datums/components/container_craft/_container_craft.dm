GLOBAL_LIST_INIT(container_craft_to_singleton, init_container_crafts())

/proc/init_container_crafts()
	var/list/recipes = list()
	for(var/datum/container_craft/craft as anything in subtypesof(/datum/container_craft))
		if(is_abstract(craft))
			continue
		recipes |= craft
		recipes[craft] = new craft
	return recipes

//this legit is only a component to avoid copy pasting in the future
/datum/component/container_craft
	///this is also in priority incase of conflicting recipes, for instance if you have 12 swampweed recipes if the first is fufilled it will subtract its items going down.
	var/list/viable_recipe_types = list()

	var/datum/callback/on_craft_start
	var/datum/callback/on_craft_failed //this isn't failing to find recipe its something caused the recipe to end early, like lack of temperature on a cooking recipe
	var/datum/callback/on_craft_finished

/datum/component/container_craft/Initialize(list/recipes, datum/callback/start, datum/callback/fail, datum/callback/success)
	. = ..()
	if(!length(recipes))
		return FALSE
	viable_recipe_types = recipes

	on_craft_start = start
	on_craft_failed = fail
	on_craft_finished = success

	RegisterSignal(parent, COMSIG_STORAGE_CLOSED, PROC_REF(async_start))

/datum/component/container_craft/proc/async_start(datum/source, mob/user)
	INVOKE_ASYNC(src, PROC_REF(attempt_crafts), source, user)

/datum/component/container_craft/proc/attempt_crafts(datum/source, mob/user)

	var/list/stored_items = list()
	var/obj/item/host = parent
	for(var/obj/item/item in host.contents)
		stored_items |= item.type
		stored_items[item.type]++


	for(var/datum/container_craft/recipe as anything in viable_recipe_types)
		var/datum/container_craft/singleton = GLOB.container_craft_to_singleton[recipe]
		if(!singleton.try_craft(host, stored_items, user, on_craft_start, on_craft_failed))
			continue
		if(on_craft_finished)
			on_craft_finished?.InvokeAsync(source, user)
		if(QDELETED(host))
			return
		stored_items = list()
		for(var/obj/item/item in host.contents)
			stored_items |= item.type
			stored_items[item.type]++

