/datum/chimeric_organs/input/revival
	name = "phoenix"

/datum/chimeric_organs/input/revival/register_triggers(mob/living/carbon/target)
	if(!target)
		return

	unregister_triggers()
	registered_signals += COMSIG_LIVING_REVIVE
	RegisterSignal(target, COMSIG_LIVING_REVIVE, PROC_REF(on_revival))

/datum/chimeric_organs/input/revival/proc/on_revival(datum/source)
	SIGNAL_HANDLER

	var/potency = node_purity / 100
	trigger_output(potency)
