/obj/abstract/visual_ui_element/hoverable/scroll_handle/book
	icon = 'icons/visual_ui/booklet.dmi'
	icon_state = "scroll-handle"

/obj/abstract/visual_ui_element/scroll_track/book
	icon = 'icons/visual_ui/booklet.dmi'
	icon_state = "scroll_bar"

/obj/abstract/visual_ui_element/hoverable/recipe_button
	icon = 'icons/visual_ui/booklet.dmi'
	icon_state = "recipe_button"

	layer = VISUAL_UI_BUTTON
	mouse_opacity = 1

	scroll_height = 18
	maptext_width = 130
	maptext_x = 48
	maptext_y = 32
	var/recipe

/obj/abstract/visual_ui_element/scrollable/recipe_group
	icon = 'icons/visual_ui/booklet.dmi'
	icon_state = "scroll_area"
	scroll_handle = /obj/abstract/visual_ui_element/hoverable/scroll_handle/book
	scroll_track = /obj/abstract/visual_ui_element/scroll_track/book

	const_offset = 0
	scroll_step = 8

	visible_width = 94
	visible_height = 133


	var/static/list/id_keys = list(
		"survival" = list(
			/datum/repeatable_crafting_recipe/survival,
			/datum/repeatable_crafting_recipe/cooking/soap,
			/datum/repeatable_crafting_recipe/cooking/soap/bath,
			/datum/repeatable_crafting_recipe/fishing,
			/datum/repeatable_crafting_recipe/sigsweet,
			/datum/repeatable_crafting_recipe/sigdry,
			/datum/repeatable_crafting_recipe/dryleaf,
			/datum/repeatable_crafting_recipe/westleach,
			/datum/repeatable_crafting_recipe/salami,
			/datum/repeatable_crafting_recipe/coppiette,
			/datum/repeatable_crafting_recipe/salo,
			/datum/repeatable_crafting_recipe/saltfish,
			/datum/repeatable_crafting_recipe/raisins,
			/datum/repeatable_crafting_recipe/parchment,
			/datum/repeatable_crafting_recipe/crafting,
		)
	)
/obj/abstract/visual_ui_element/scrollable/recipe_group/New(turf/loc, datum/visual_ui/P)
	. = ..()
	create_recipe_group()

/obj/abstract/visual_ui_element/scrollable/recipe_group/proc/create_recipe_group(id_key = "survival")
	var/list/recipe_list = id_keys[id_key]
	var/length = 1
	for(var/datum/repeatable_crafting_recipe/recipe as anything in recipe_list)
		if(is_abstract(recipe))
			for(var/atom/sub_path as anything in subtypesof(recipe))
				var/obj/abstract/visual_ui_element/hoverable/recipe_button/button = new /obj/abstract/visual_ui_element/hoverable/recipe_button(null, parent)
				button.offset_x = offset_x
				button.offset_y = offset_y + (18 * (length-1))
				button.update_ui_screen_loc()
				parent.elements += button

				button.maptext = {"<span style='font-size:8pt;font-family:"Pterra";color:[hover_color]' class='center maptext '>[initial(sub_path.name)]</span>"}
				button.recipe = sub_path
				register_element(button)
				length++
		else
			var/obj/abstract/visual_ui_element/hoverable/recipe_button/button = new /obj/abstract/visual_ui_element/hoverable/recipe_button(null, parent)
			button.offset_x = offset_x
			button.offset_y = offset_y + (18 * (length-1))
			button.update_ui_screen_loc()
			parent.elements += button

			button.maptext = {"<span style='font-size:8pt;font-family:"Pterra";color:[hover_color]' class='center maptext '>[initial(recipe.name)]</span>"}
			button.recipe = recipe
			register_element(button)
			length++
