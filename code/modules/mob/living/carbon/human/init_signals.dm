/mob/living/carbon/human/register_init_signals()
	. = ..()

	/* ROGUE */
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LEPROSY), PROC_REF(on_leprosy_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_LEPROSY), PROC_REF(on_leprosy_trait_loss))

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_CRATEMOVER), PROC_REF(on_cratemover_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_CRATEMOVER), PROC_REF(on_cratemover_trait_loss))

	// Combat message stuff
	RegisterSignal(src, COMSIG_CARBON_CLEAR_WOUND_MESSAGE, PROC_REF(clear_wound_message))
	RegisterSignal(src, COMSIG_CARBON_ADD_TO_WOUND_MESSAGE, PROC_REF(add_to_wound_message))


/mob/living/carbon/proc/clear_wound_message(datum/source)
	wound_message = ""

/mob/living/carbon/proc/add_to_wound_message(datum/source, new_message = "", clear_message = FALSE)
	if(clear_message)
		SEND_SIGNAL(src, COMSIG_CARBON_CLEAR_WOUND_MESSAGE)
	wound_message = "[wound_message][new_message]"
