/datum/organ_process/brain
	slot = ORGAN_SLOT_BRAIN

/datum/organ_process/brain/handle_process(mob/living/carbon/owner, delta_time, times_fired)
	var/obj/item/organ/brain/brain = owner.getorganslot(ORGAN_SLOT_BRAIN)
	if(!brain)
		return

	var/effective_blood_oxygenation = GET_EFFECTIVE_BLOOD_VOL(owner.get_blood_oxygenation(), owner.total_blood_req)
	var/is_stable = owner.get_chem_effect(CE_STABLE)
	var/damprob = 0

	switch(effective_blood_oxygenation)
		if(BLOOD_VOLUME_OKAY to BLOOD_VOLUME_SAFE)
			if(DT_PROB(2.5, delta_time))
				to_chat(owner, span_warning("<i>I feel [pick("dizzy","woozy","faint")].</i>"))
			owner.adjustOxyLoss(round(0.005 * (BLOOD_VOLUME_NORMAL - effective_blood_oxygenation) * delta_time * 0.3, 1))
			damprob = is_stable ? 10 : 30
			if((brain.current_blood <= 0) && !brain.past_damage_threshold(2) && DT_PROB(damprob, delta_time))
				brain.applyOrganDamage(BRAIN_DAMAGE_LOW_OXYGENATION)
		if(BLOOD_VOLUME_BAD to BLOOD_VOLUME_OKAY)
			owner.adjust_eye_blur_up_to(4, 4)
			if(DT_PROB(5, delta_time))
				to_chat(owner, span_userdanger("<i>I feel very [pick("dizzy","woozy","faint")]...</i>"))
			owner.adjustOxyLoss(FLOOR(0.01 * (BLOOD_VOLUME_NORMAL - effective_blood_oxygenation) * delta_time * 0.3, 1))
			damprob = is_stable ? 15 : 50
			if((brain.current_blood <= 0) && !brain.past_damage_threshold(4) && DT_PROB(damprob, delta_time))
				brain.applyOrganDamage(BRAIN_DAMAGE_LOW_OXYGENATION)
		if(BLOOD_VOLUME_SURVIVE to BLOOD_VOLUME_BAD)
			owner.adjust_eye_blur_up_to(6, 6)
			if(DT_PROB(5, delta_time))
				owner.Unconscious(rand(3,5) SECONDS)
				to_chat(owner, span_userdanger("<i>I feel extremely [pick("dizzy","woozy","faint")]...</i>"))
			owner.adjustOxyLoss(2.5 * delta_time)
			damprob = is_stable ? 40 : 75
			if((brain.current_blood <= 0) && !brain.past_damage_threshold(6) && DT_PROB(damprob, delta_time))
				brain.applyOrganDamage(BRAIN_DAMAGE_LOWER_OXYGENATION)

		if(-INFINITY to BLOOD_VOLUME_SURVIVE)
			owner.adjust_eye_blur_up_to(6, 6)
			if((brain.current_blood <= 0) && DT_PROB(7.5, delta_time))
				to_chat(owner, span_userdanger("<i>I feel [pick("heavy", "dehydrated", "empty")] and [pick("faint", "weak", "lightheaded", "dizzy")]!</i>"))
			owner.adjustOxyLoss(5 * delta_time)
			owner.Unconscious(rand(6,12) SECONDS)
			damprob = is_stable ? 65 : 100
			if((brain.current_blood <= 0) && DT_PROB(damprob, delta_time))
				brain.applyOrganDamage(BRAIN_DAMAGE_LOWEST_OXYGENATION)

	owner.handle_brain_damage()

	if(!(brain.organ_flags & ORGAN_FAILING))
		var/healing_amount = -(brain.maxHealth * brain.healing_factor)
		healing_amount -= owner.satiety > 0 ? 4 * brain.healing_factor * owner.satiety / MAX_SATIETY : 0
		brain.applyOrganDamage(healing_amount)

	if(brain.damage >= BRAIN_DAMAGE_DEATH)
		to_chat(owner, "<span class='danger'>The last spark of life in your brain fizzles out...</span>")
		owner.death()
		brain.brain_death = TRUE
		return TRUE // owner is dead, no point continuing

	// Only run if damage increased this tick
	if(brain.damage > brain.prev_damage)
		brain.damage_delta = brain.damage - brain.prev_damage

		if(brain.damage > BRAIN_DAMAGE_MILD)
			if(prob(brain.damage_delta * (1 + max(0, (brain.damage - BRAIN_DAMAGE_MILD) / 100))))
				brain.gain_trauma_type(BRAIN_TRAUMA_MILD)

		if(brain.damage > BRAIN_DAMAGE_SEVERE)
			if(prob(brain.damage_delta * (1 + max(0, (brain.damage - BRAIN_DAMAGE_SEVERE) / 100))))
				if(prob(20))
					brain.gain_trauma_type(BRAIN_TRAUMA_SPECIAL)
				else
					brain.gain_trauma_type(BRAIN_TRAUMA_SEVERE)

		// Threshold warning messages to the owner
		if(owner.stat < UNCONSCIOUS)
			var/brain_message
			if(brain.prev_damage < BRAIN_DAMAGE_MILD && brain.damage >= BRAIN_DAMAGE_MILD)
				brain_message = "<span class='warning'>I feel lightheaded.</span>"
			else if(brain.prev_damage < BRAIN_DAMAGE_SEVERE && brain.damage >= BRAIN_DAMAGE_SEVERE)
				brain_message = "<span class='warning'>I feel less in control of your thoughts.</span>"
			else if(brain.prev_damage < (BRAIN_DAMAGE_DEATH - 20) && brain.damage >= (BRAIN_DAMAGE_DEATH - 20))
				brain_message = "<span class='warning'>I can feel your mind flickering on and off...</span>"
			if(brain_message)
				to_chat(owner, brain_message)

	// Always update prev_damage at end of tick so next tick's delta is accurate
	brain.prev_damage = brain.damage

	return TRUE
