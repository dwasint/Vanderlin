
/obj/item/natural/feather
	name = "feather"
	desc = "The plume from some avian."
	icon_state = "feather"
	possible_item_intents = list(/datum/intent/use)
	force = 0
	throwforce = 0
	firefuel = null
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_MOUTH|ITEM_SLOT_HEAD|ITEM_SLOT_HIP
	body_parts_covered = null
	experimental_onhip = TRUE
	max_integrity = 20
	muteinmouth = TRUE
	spitoutmouth = FALSE
	w_class = WEIGHT_CLASS_TINY

/*
/obj/item/natural/feather/pre_attack_secondary(atom/A, mob/living/carbon/human/user, params)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(istype(A, /obj/item/paper/confession))
		var/obj/item/paper/confession/confessional = A
		if(confessional.signed)
			return
		var/response = alert(user, "What voluntary confession do I want?","","Villainy", "Faith")
		if(!response)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		if(response == "Villainy")
			confessional.confession_type = "antag"
			confessional.name = "confession of villainy"
		else
			confessional.confession_type = "patron"
			confessional.name = "confession of faith"
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
*/
