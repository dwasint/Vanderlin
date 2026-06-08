/datum/relation/enemy
	name = "Enemy"
	desc = "You have known them for a while and really cannot stand each other."
	incompatible = list("Friend")

/datum/relation/enemy/get_desc_string()
	return "[holder?.name] and [other?.name] do not get along well."
