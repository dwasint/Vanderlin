/datum/slapcraft_step/use_item
	abstract_type = /datum/slapcraft_step/use_item
	insert_item = FALSE
	start_verb = "of"

/datum/slapcraft_step/use_item/sewing
	abstract_type = /datum/slapcraft_step/use_item/sewing
	skill_type = /datum/skill/misc/sewing


/datum/slapcraft_step/use_item/carpentry
	abstract_type = /datum/slapcraft_step/use_item/carpentry
	skill_type = /datum/skill/craft/carpentry

/datum/slapcraft_step/use_item/masonry
	abstract_type = /datum/slapcraft_step/use_item/masonry
	skill_type = /datum/skill/craft/masonry

/datum/slapcraft_step/use_item/engineering
	abstract_type = /datum/slapcraft_step/use_item/engineering
	skill_type = /datum/skill/craft/masonry

/datum/slapcraft_step/item
	abstract_type = /datum/slapcraft_step/item
	perform_time = 0.2 SECONDS
