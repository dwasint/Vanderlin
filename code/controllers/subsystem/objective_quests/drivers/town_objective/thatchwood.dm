/datum/objective_quest_driver/town_objective/area/thatchwood
	abstract_type = /datum/objective_quest_driver/town_objective/area/thatchwood //TODO: REMOVE THIS WHEN I FINISH THIS
	area_types = list(
		/area/outdoors/wilderness/outpost/vanderlin,
		/area/indoors/wilderness/tavern,
		/area/indoors/wilderness/shop,
		/area/outdoors/wilderness/beside_thatchwood,
	)
	stages = list(
		list(
			"quest_types" = list(/datum/quest/objective/thatchwood/kill),
			"triumph_reward" = 1,
			"triumph_reason" = "Secured Thatchwood."
		),
		list(
			"quest_types" = list(/datum/quest/objective/thatchwood/clear_trees),
			"triumph_reward" = 1,
			"triumph_reason" = "Cleared Thatchwood's forests."
		),
		list(
			"quest_types" = list(/datum/quest/objective/thatchwood/clear_clutter),
			"triumph_reward" = 1,
			"triumph_reason" = "Cleaned up Thatchwood."
		),
	)
	var/mob_count = 0
	var/tree_count = 0
	var/clutter_count = 0

	var/initial_mob_count = 0
	var/initial_tree_count = 0
	var/initial_clutter_count = 0

/datum/objective_quest_driver/town_objective/area/thatchwood/setup_stages()
	for(var/area/managed_area in real_areas)
		for(var/mob/living/living in managed_area.contents)
			mob_count++
			RegisterSignal(living, COMSIG_LIVING_DEATH, PROC_REF(mob_death))
		for(var/obj/structure/kneestingers/C in managed_area.contents)
			clutter_count++
			RegisterSignal(C, COMSIG_QDELETING, PROC_REF(clutter_cleanup))
		for(var/obj/structure/flora/newtree/newtree in managed_area.contents)
			tree_count++
			RegisterSignal(newtree, COMSIG_QDELETING, PROC_REF(tree_cleanup))

	initial_mob_count = mob_count
	initial_tree_count = tree_count
	initial_clutter_count = clutter_count


/datum/objective_quest_driver/town_objective/area/thatchwood/proc/mob_death(mob/living/source)
	mob_count--
	notify_active_quest(/datum/quest/objective/thatchwood/kill)

/datum/objective_quest_driver/town_objective/area/thatchwood/proc/tree_cleanup(obj/source)
	tree_count--
	notify_active_quest(/datum/quest/objective/thatchwood/clear_trees)

/datum/objective_quest_driver/town_objective/area/thatchwood/proc/clutter_cleanup(obj/source)
	clutter_count--
	notify_active_quest(/datum/quest/objective/thatchwood/clear_clutter)

/datum/objective_quest_driver/town_objective/area/thatchwood/Destroy()
	for(var/area/managed_area in real_areas)
		for(var/mob/living/living in managed_area.contents)
			UnregisterSignal(living, COMSIG_LIVING_DEATH)
		for(var/obj/structure/kneestingers/C in managed_area.contents)
			UnregisterSignal(C, COMSIG_QDELETING)
		for(var/obj/structure/flora/newtree/newtree in managed_area.contents)
			UnregisterSignal(newtree, COMSIG_QDELETING)
	return ..()
