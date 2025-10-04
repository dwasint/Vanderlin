/datum/chimeric_organs/input/racist
	name = "racist"
	desc = "When in view of certain species will trigger."
	var/beats_per_trigger = 1 // How many heartbeats before triggering
	var/current_beats = 0
	var/datum/species/disliked_species = /datum/species/dwarf

/datum/chimeric_organs/input/racist/register_triggers(mob/living/carbon/target)
	if(!target)
		return

	unregister_triggers()
	registered_signals += COMSIG_HUMAN_LIFE
	RegisterSignal(target, COMSIG_HUMAN_LIFE, PROC_REF(on_heartbeat))

/datum/chimeric_organs/input/racist/proc/on_heartbeat(datum/source)
	SIGNAL_HANDLER
	current_beats++
	if(current_beats < beats_per_trigger)
		return
	current_beats = 0
	for(var/mob/living/carbon/human/human in view(7, hosted_carbon))
		if(istype(human.dna.species, disliked_species))
			var/potency = node_purity / 100
			trigger_output(potency)
			return
