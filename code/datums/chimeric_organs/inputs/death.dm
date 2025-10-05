/datum/chimeric_organs/input/death
	name = "mortis"
	desc = "Triggered when you are killed."

/datum/chimeric_organs/input/death/register_triggers(mob/living/carbon/target)
	if(!target)
		return

	unregister_triggers()
	registered_signals += COMSIG_LIVING_DEATH
	RegisterSignal(target, COMSIG_LIVING_DEATH, PROC_REF(on_death))

/datum/chimeric_organs/input/death/proc/on_death(datum/source)
	SIGNAL_HANDLER

	var/potency = node_purity / 10
	trigger_output(node_purity)
