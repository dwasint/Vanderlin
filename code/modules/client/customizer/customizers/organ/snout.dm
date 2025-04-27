
/obj/item/organ/snout
	name = "snout"
	desc = "A severed snout. What did you cut this off of?"
	icon_state = "severedtail" //placeholder
	visible_organ = TRUE
	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_SNOUT

/obj/item/organ/snout/beak
	name = "beak"


/datum/customizer/organ/snout
	abstract_type = /datum/customizer/organ/snout
	name = "Snout"

/datum/customizer_choice/organ/snout
	abstract_type = /datum/customizer_choice/organ/snout
	name = "Snout"
	organ_type = /obj/item/organ/snout
	organ_slot = ORGAN_SLOT_SNOUT

/datum/customizer/organ/snout/anthro
	allows_disabling = TRUE
	default_disabled = TRUE
	customizer_choices = list(/datum/customizer_choice/organ/snout/anthro)

/datum/customizer/organ/snout/anthrosmall
	allows_disabling = TRUE
	default_disabled = FALSE
	customizer_choices = list(/datum/customizer_choice/organ/snout/anthro)

/datum/customizer_choice/organ/snout/anthro
	name = "Wild-Kin Snout"
	organ_type = /obj/item/organ/snout/beak
	sprite_accessories = list(
		/datum/sprite_accessory/snout/bird,
		/datum/sprite_accessory/snout/bigbeak,
		/datum/sprite_accessory/snout/bigbeakshort,
		/datum/sprite_accessory/snout/slimbeak,
		/datum/sprite_accessory/snout/slimbeakshort,
		/datum/sprite_accessory/snout/slimbeakalt,
		/datum/sprite_accessory/snout/hookbeak,
		/datum/sprite_accessory/snout/hookbeakbig,
		)
