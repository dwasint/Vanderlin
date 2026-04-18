/mob/living/carbon/register_init_signals()
	. = ..()

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NO_SPLIT_PERSONALITY), PROC_REF(on_no_split_personality_trait_gain))

	// Combat message stuff
	RegisterSignal(src, COMSIG_CARBON_CLEAR_WOUND_MESSAGE, PROC_REF(clear_wound_message))
	RegisterSignal(src, COMSIG_CARBON_ADD_TO_WOUND_MESSAGE, PROC_REF(add_to_wound_message))


/mob/living/carbon/proc/clear_wound_message(datum/source)
	wound_message = ""

/mob/living/carbon/proc/add_to_wound_message(datum/source, new_message = "", clear_message = FALSE)
	if(clear_message)
		SEND_SIGNAL(src, COMSIG_CARBON_CLEAR_WOUND_MESSAGE)
	wound_message = "[wound_message][new_message]"
/**
 * On gain of TRAIT_NO_SPLIT_PERSONALITY
 *
 * This will make the mob lose the split personality trauma if they have it.
 */
/mob/living/carbon/proc/on_no_split_personality_trait_gain(datum/source)
	SIGNAL_HANDLER

	cure_trauma_type(/datum/brain_trauma/severe/split_personality, TRAUMA_LIMIT_ABSOLUTE)
