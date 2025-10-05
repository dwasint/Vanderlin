/datum/chimeric_organs/input/reagent
	name = "drowning"
	desc = "Triggered when you consume a specific brew."

	var/list/trigger_reagents = list() // List of reagent types that trigger this
	var/minimum_amount = 1 // Minimum amount needed to trigger

/datum/chimeric_organs/input/reagent/register_triggers(mob/living/carbon/target)
	if(!target)
		return

	unregister_triggers()
	registered_signals += COMSIG_CARBON_REAGENT_ADD
	RegisterSignal(target, COMSIG_CARBON_REAGENT_ADD, PROC_REF(on_reagent_added))

/datum/chimeric_organs/input/reagent/proc/on_reagent_added(datum/source, datum/reagent/consumed_reagent, consumed_amount)
	SIGNAL_HANDLER

	if(consumed_amount < minimum_amount)
		return

	var/passed = FALSE
	for(var/path in trigger_reagents)
		if(passed)
			break
		if(!ispath(consumed_reagent.type, path))
			continue
		passed = TRUE

	// Check if this reagent should trigger
	if(passed)
		var/potency = calculate_potency(consumed_reagent, consumed_amount)
		trigger_output(potency)

/datum/chimeric_organs/input/reagent/proc/calculate_potency(datum/reagent/reagent, amount)
	// Base potency calculation - can be overridden
	return (amount / minimum_amount) * (node_purity / 100)

/datum/chimeric_organs/input/reagent/blood
	trigger_reagents = list(/datum/reagent/blood)
	minimum_amount = 5
