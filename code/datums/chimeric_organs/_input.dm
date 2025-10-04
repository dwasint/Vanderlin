// Base input datum - all inputs inherit from this
/datum/chimeric_organs/input
	abstract_type = /datum/chimeric_organs/input
	var/datum/chimeric_organs/output/attached_output
	var/list/registered_signals = list()

/datum/chimeric_organs/input/Destroy()
	unregister_triggers()
	attached_output = null
	attached_organ = null
	hosted_carbon = null
	. = ..()

/datum/chimeric_organs/input/proc/register_triggers(mob/living/carbon/target)
	return

/datum/chimeric_organs/input/proc/unregister_triggers()
	if(!hosted_carbon || !registered_signals.len)
		return

	for(var/signal in registered_signals)
		UnregisterSignal(hosted_carbon, signal)

	registered_signals.Cut()

/datum/chimeric_organs/input/proc/trigger_output(potency)
	if(!attached_output)
		return FALSE

	attached_output.trigger_effect(TRUE, potency)
	return TRUE
