/datum/relation/friend
	name = "Friend"
	desc = "You have known them for a while and get along well."
	incompatible = list("Enemy")

/datum/relation/friend/get_desc_string()
	return "[holder?.name] and [other?.name] seem to be on good terms."
