/datum/clan_leader
	var/list/lord_spells = list(
	)
	var/list/lord_verbs = list(
	)
	var/list/lord_traits = list()
	var/lord_title = "Lord"
	var/vitae_bonus = 5 // Extra vitae for lords
	var/ascended = FALSE

/datum/clan_leader/lord
	lord_spells = list(
		/obj/effect/proc_holder/spell/targeted/shapeshift/bat,
		/obj/effect/proc_holder/spell/targeted/mansion_portal,
		/obj/effect/proc_holder/spell/targeted/shapeshift/gaseousform
	)
	lord_verbs = list(
		/mob/living/carbon/human/proc/demand_submission,
		/mob/living/carbon/human/proc/punish_spawn
	)
	lord_traits = list(TRAIT_HEAVYARMOR)
	lord_title = "Lord"
	vitae_bonus = 500 // Extra vitae for lords
	ascended = FALSE

/datum/clan_leader/proc/make_new_leader(mob/living/carbon/human/H)
	ADD_TRAIT(H, TRAIT_CLAN_LEADER, "clan")

	// Add lord spells
	for(var/spell_type in lord_spells)
		H.AddSpell(new spell_type())

	// Add lord verbs
	for(var/verb_path in lord_verbs)
		H.verbs |= verb_path

	// Add lord traits
	for(var/trait in lord_traits)
		ADD_TRAIT(H, trait, "lord_component")

	// Update vampire datum if they have one
	var/datum/antagonist/vampire/vamp_datum = H.mind?.has_antag_datum(/datum/antagonist/vampire)
	H.maxbloodpool += vitae_bonus
	if(vamp_datum)
		vamp_datum.name = "[lord_title]"
		vamp_datum.antag_hud_name = "vamplord"

/datum/clan_leader/proc/remove_leader(mob/living/carbon/human/H)
	REMOVE_TRAIT(H, TRAIT_CLAN_LEADER, "clan")
	// Remove lord spells
	for(var/spell_type in lord_spells)
		var/obj/effect/proc_holder/spell/spell_instance = locate(spell_type) in H.mind.spell_list
		if(spell_instance)
			H.RemoveSpell(spell_instance)

	// Remove lord verbs
	for(var/verb_path in lord_verbs)
		H.verbs -= verb_path

	// Remove lord traits
	for(var/trait in lord_traits)
		REMOVE_TRAIT(H, trait, "lord_component")
	H.maxbloodpool -= vitae_bonus
