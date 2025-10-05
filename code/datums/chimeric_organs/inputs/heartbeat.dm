/datum/chimeric_organs/input/heartbeat
	name = "heartbeat"
	desc = "Triggered every few heartbeats."
	var/beats_per_trigger = 1 // How many heartbeats before triggering
	var/current_beats = 0

/datum/chimeric_organs/input/heartbeat/register_triggers(mob/living/carbon/target)
	if(!target)
		return

	unregister_triggers()
	registered_signals += COMSIG_HUMAN_LIFE
	RegisterSignal(target, COMSIG_HUMAN_LIFE, PROC_REF(on_heartbeat))

/datum/chimeric_organs/input/heartbeat/proc/on_heartbeat(datum/source)
	SIGNAL_HANDLER

	current_beats++
	if(current_beats >= beats_per_trigger)
		current_beats = 0
		var/potency = node_purity / 100
		trigger_output(potency)
