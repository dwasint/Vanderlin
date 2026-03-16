
/atom
	var/list/obtained_from

/// Global reverse map: "[source_path]" -> list of obtained_from_entry dicts
/// Each entry: list("name", "icon", "icon_state", "_path", "source_label")
GLOBAL_LIST_INIT(obtained_from_reverse, build_obtained_from_reverse())
GLOBAL_VAR_INIT(obtained_from_built, FALSE)

/proc/build_obtained_from_reverse()
	var/list/list = list()
	if(GLOB.obtained_from_built)
		return
	for(var/obj/item/item_type as anything in subtypesof(/obj/item))
		if(IS_ABSTRACT(item_type))
			continue
		if(!(initial(item_type.item_flags) & OBTAINED_DATA))
			continue
		var/obj/item/new_item = new item_type()
		var/list/sources = new_item.obtained_from
		if(!length(sources))
			continue
		for(var/list/entry as anything in sources)
			if(!islist(entry) || length(entry) < 2)
				continue
			var/label = entry[1]
			var/atom/src_path = entry[2]
			if(!ispath(src_path))
				continue
			var/key = "[src_path]"
			if(!list[key])
				list[key] = list()
			list[key] += list(list(
				"name" = initial(item_type.name),
				"icon" = "[initial(item_type.icon)]",
				"icon_state" = "[initial(item_type.icon_state)]",
				"_path" = "[item_type]",
				"source_label" = label,
			))
		qdel(new_item)
	GLOB.obtained_from_built = TRUE
	return list

/atom/return_recipe_data()
	if(!length(obtained_from))
		return null

	var/list/data = list()
	data["type"] = "obtained_from"
	data["name"] = name
	data["category"] = "Sources"
	data["_output_path"] = "[type]"
	data["output_name"] = name
	data["output_icon"] = "[icon]"
	data["output_state"] = "[icon_state]"

	var/list/sources = list()
	for(var/list/entry as anything in obtained_from)
		if(!islist(entry) || length(entry) < 2)
			continue
		var/label    = entry[1]
		var/atom/src_path = entry[2]
		sources += list(list(
			"label" = label,
			"_path" = "[src_path]",
			"name" = initial(src_path.name),
			"icon" = "[initial(src_path.icon)]",
			"icon_state" = "[initial(src_path.icon_state)]",
		))
	data["sources"] = sources

	return data
