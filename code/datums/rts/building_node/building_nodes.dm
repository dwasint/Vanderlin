/obj/effect/building_node
	name = "Building Node"
	desc = "A generic building"
	plane = STRATEGY_PLANE

	///this is our template id
	var/work_template

	var/list/added_assignments

	var/list/workspots = list()

	var/maximum_workers = 1

	var/list/materials_to_store = list()

	var/list/persistant_nodes = list()

/obj/effect/building_node/proc/on_construction(mob/camera/strategy_controller/master_controller)
	SHOULD_CALL_PARENT(TRUE)
	master_controller.constructed_building_nodes |= src
	if(length(added_assignments))
		master_controller.add_assignments(added_assignments)

	var/datum/map_template/template = SSmapping.map_templates[work_template]

	var/list/turfs = template.get_affected_turfs(get_turf(src), TRUE)
	for(var/turf/turf as anything in turfs)
		for(var/obj/effect/workspot/spot in turf.contents)
			workspots |= spot
	after_construction(turfs)

	var/list/created_nodes = list()
	for(var/datum/persistant_workorder/node as anything in persistant_nodes)
		created_nodes |= new node(src)
	persistant_nodes = created_nodes

/obj/effect/building_node/proc/after_construction(list/turfs)
	return

/obj/effect/building_node/proc/select_workorder(mob/user)
	if(!length(persistant_nodes))
		return
	var/list/name_to_node = list()
	var/list/radial_options = list()
	for(var/datum/persistant_workorder/order in persistant_nodes)
		radial_options |= order.name
		radial_options[order.name] = image(order.ui_icon, order.ui_icon_state)
		name_to_node |= order.name
		name_to_node[order.name] = order

	var/picked = show_radial_menu(user, src, radial_options)
	if(!picked)
		return

	return name_to_node[picked]

/datum/food_item
	var/name = "Bread"
	var/stamina_restore = 50

/datum/food_item/bread
	name = "Bread"
	stamina_restore = 50

/obj/effect/building_node/kitchen
	name = "Kitchen"

	var/list/stored_foods

	var/list/eating_spots

/obj/effect/building_node/kitchen/after_construction(list/turfs)
	for(var/turf/turf as anything in turfs)
		for(var/obj/effect/foodspot/spot in turf.contents)
			eating_spots |= spot

/obj/effect/building_node/kitchen/proc/try_feed(mob/living/hungry_worker)
	if(!length(stored_foods))
		var/list/turfs = view(6, hungry_worker)
		shuffle_inplace(turfs)
		for(var/turf/open/open in turfs)
			hungry_worker.controller_mind.set_current_task(/datum/work_order/nappy_time, open)
			break
		return
	hungry_worker.controller_mind.set_current_task(/datum/work_order/eat_food, pick(eating_spots), pick(stored_foods), src)

/obj/effect/building_node/kitchen/proc/consume_food(datum/food_item/food_to_consume, mob/living/hungry_worker)
	hungry_worker.controller_mind.current_stamina = min(hungry_worker.controller_mind.maximum_stamina, hungry_worker.controller_mind.current_stamina + (initial(food_to_consume.stamina_restore)))

/obj/effect/building_node/stockpile
	name = "Stockpile"
	work_template = "stockpile"

	var/datum/stockpile/stockpile

/obj/effect/building_node/stockpile/on_construction(mob/camera/strategy_controller/master_controller)
	. = ..()
	if(!master_controller.resource_stockpile)
		master_controller.resource_stockpile = new /datum/stockpile
	stockpile = master_controller.resource_stockpile

/obj/effect/building_node/farm
	name = "Farm"
	work_template = "farm"

	icon = 'icons/roguetown/items/produce.dmi'
	icon_state = "wheatchaff"

	materials_to_store = list(
		"Grain" = 10
	)

	persistant_nodes = list(
		/datum/persistant_workorder/farm/grain,
		/datum/persistant_workorder/farm/fruit,
		/datum/persistant_workorder/farm/vegetable,
	)
