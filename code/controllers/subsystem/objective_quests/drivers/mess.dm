/datum/objective_quest_driver/mess
	quest_type_path = /datum/quest/objective/clean_mess
	quest_difficulty = QUEST_DIFFICULTY_EASY
	cooldown_time = 5 MINUTES
	spawn_amount = 4
	value_threshold = 40
	value_max = 40000 ///lol

/datum/objective_quest_driver/mess/get_spawn_amount()
	return clamp(round(current_value / (0.5 * value_threshold)), 1, spawn_amount)
