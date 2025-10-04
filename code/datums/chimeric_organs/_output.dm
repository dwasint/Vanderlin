/datum/chimeric_organs/output
	abstract_type = /datum/chimeric_organs/output
	name = "Generic Output"
	desc = "This is a generic output you shouldn't be seeing this"
	slot = OUTPUT_NODE

	///the input we have latched onto, this is only ever done when its added to an organ
	var/datum/chimeric_organs/input/attached_input
	///list of all our registered signals
	var/list/registered_signals = list()

/datum/chimeric_organs/output/check_active()
	if(attached_input)
		return TRUE
	return FALSE

/datum/chimeric_organs/output/proc/trigger_effect(is_good = TRUE, multiplier)
	SHOULD_CALL_PARENT(TRUE)

	if(attached_special)
		if(attached_special.trigger_special(is_good, multiplier))
			return

/datum/chimeric_organs/output/proc/register_listeners(mob/living/carbon/target)
	return

/datum/chimeric_organs/output/proc/unregister_listeners()
	if(!hosted_carbon || !length(registered_signals))
		return

	for(var/signal in registered_signals)
		UnregisterSignal(hosted_carbon, signal)

	registered_signals.Cut()
