/datum/quirk/boon
	abstract_type = /datum/quirk/boon
	quirk_category = QUIRK_BOON

/datum/quirk/boon/keen_eye
	name = "Keen Eye"
	desc = "Years of hunting and tracking have honed your sight. You're better at noticing details and spotting hidden things."
	point_value = -4
	incompatible_quirks = list(
		/datum/quirk/vice/bad_sight
	)

/datum/quirk/boon/keen_eye/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_PER, 2)

/datum/quirk/boon/keen_eye/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_PER, -2)

/datum/quirk/boon/night_vision
	name = "Night Vision"
	desc = "You can see better in darkness than most. Perhaps you have elf blood, or maybe you just spent too many nights as a watchman."
	point_value = -4
	incompatible_quirks = list(
		/datum/quirk/vice/bad_sight,
		/datum/quirk/vice/cyclops_left,
		/datum/quirk/vice/cyclops_right
	)

/datum/quirk/boon/night_vision/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.lighting_alpha = LIGHTING_PLANE_ALPHA_LESSER_NV_TRAIT
	H.update_sight()

/datum/quirk/boon/night_vision/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.lighting_alpha = initial(H.lighting_alpha)
	H.update_sight()

/datum/quirk/boon/light_footed
	name = "Light Footed"
	desc = "You move with grace and agility. Your steps are quicker and more sure than most."
	point_value = -5

/datum/quirk/boon/light_footed/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, 1)

/datum/quirk/boon/light_footed/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, -1)

/* Surgery stuff
/datum/quirk/boon/steady_hands
	name = "Steady Hands"
	desc = "Your hands are steady and precise, perfect for delicate work or keeping your blade true in combat."
	point_value = -3

/datum/quirk/boon/steady_hands/on_spawn()
	ADD_TRAIT(owner, TRAIT_STEADY_HANDS, "[type]")

/datum/quirk/boon/steady_hands/on_remove()
	REMOVE_TRAIT(owner, TRAIT_STEADY_HANDS, "[type]")
*/

/datum/quirk/boon/tough_skin
	name = "Tough Skin"
	desc = "Years of hard labor or battle have toughened your hide. You can take more punishment than most."
	point_value = -5

/datum/quirk/boon/tough_skin/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_END, 2)

/datum/quirk/boon/tough_skin/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_END, -2)

/datum/quirk/boon/strong_back
	name = "Strong Back"
	desc = "You're used to carrying heavy loads. Whether from years of soldiering or hard labor, you can bear more weight."
	point_value = -5

/datum/quirk/boon/strong_back/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_STR, 1)

/datum/quirk/boon/strong_back/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_STR, -1)

/datum/quirk/boon/quick_reflexes
	name = "Quick Reflexes"
	desc = "Your reactions are faster than most. You can dodge, parry, and respond to danger with impressive speed."
	point_value = -4

/datum/quirk/boon/quick_reflexes/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, 1)
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_LCK, 1)

/datum/quirk/boon/quick_reflexes/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, -1)
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_LCK, -1)

/datum/quirk/boon/quick_learner
	name = "Quick Learner"
	desc = "You pick up new skills faster than most. Your mind is sharp and eager to learn."
	point_value = -5

/datum/quirk/boon/quick_learner/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, 2)

/datum/quirk/boon/quick_learner/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, -2)

/datum/quirk/boon/silver_tongue
	name = "Silver Tongue"
	desc = "You have a way with words. People tend to believe what you say and respond well to your persuasion."
	point_value = -4

/datum/quirk/boon/silver_tongue/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, 1)
	//idk what else to do here

/datum/quirk/boon/silver_tongue/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, -1)


/datum/quirk/boon/iron_will
	name = "Iron Will"
	desc = "Your resolve is unshakeable. You resist stress and fear better than most."
	point_value = -4

/datum/quirk/boon/iron_will/on_spawn()
	ADD_TRAIT(owner, TRAIT_STEELHEARTED, "[type]")

/datum/quirk/boon/iron_will/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_STEELHEARTED, "[type]")

/datum/quirk/boon/composed
	name = "Composed"
	desc = "You handle stress better than most. Pressure doesn't get to you as easily."
	point_value = -3

/datum/quirk/boon/composed/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(prob(1) && H.get_stress_amount() > 5)
		H.adjust_stress(-1)

/datum/quirk/boon/hardy
	name = "Hardy"
	desc = "You recover from injuries and illness faster than most. Your constitution is exceptional."
	point_value = -4

/datum/quirk/boon/hardy/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_CON, 2)

/datum/quirk/boon/hardy/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_CON, -2)

/* This is a future idea
/datum/quirk/boon/light_sleeper
	name = "Light Sleeper"
	desc = "You wake easily and need less sleep than most. Years of dangerous living have trained you to be alert even in rest."
	point_value = -2

/datum/quirk/boon/light_sleeper/on_spawn()
	ADD_TRAIT(owner, TRAIT_LIGHT_SLEEPER, "[type]")

/datum/quirk/boon/light_sleeper/on_remove()
	REMOVE_TRAIT(owner, TRAIT_LIGHT_SLEEPER, "[type]")
*/

/datum/quirk/boon/second_language
	name = "Second Language"
	desc = "You know an additional language."
	quirk_category = QUIRK_BOON
	point_value = -1
	customization_label = "Choose Language"
	customization_options = list(
		/datum/language/elvish,
		/datum/language/dwarvish,
		/datum/language/deepspeak,
		/datum/language/zalad,
		/datum/language/oldpsydonic,
		/datum/language/hellspeak,
		/datum/language/orcish,
	)

/datum/quirk/boon/second_language/on_spawn()
	if(!customization_value || !ispath(customization_value, /datum/language))
		return

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.grant_language(customization_value)

/datum/quirk/boon/pet
	name = "Loyal Companion"
	desc = "You have a loyal animal companion that will follow and protect you."
	point_value = -5
	customization_label = "Choose Pet Type"
	customization_options = list(
		/mob/living/simple_animal/pet/cat/cabbit,
		/mob/living/simple_animal/pet/cat/black,
		/mob/living/simple_animal/hostile/retaliate/frog,
		/mob/living/simple_animal/hostile/retaliate/chicken,
		/mob/living/simple_animal/hostile/retaliate/fox,
		/mob/living/simple_animal/hostile/retaliate/raccoon,
	)

	/// Reference to the spawned pet
	var/mob/living/simple_animal/pet_mob

/datum/quirk/boon/pet/on_spawn()
	if(!get_turf(owner))
		addtimer(CALLBACK(src, PROC_REF(on_spawn)), 0.5 SECONDS)
		return

	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	// Check if a pet type was selected
	if(!customization_value || !ispath(customization_value, /mob/living/simple_animal))
		customization_value = /mob/living/simple_animal/pet/cat/black

	// Spawn the pet at the owner's location
	pet_mob = new customization_value(get_turf(H))

	if(!pet_mob)
		return

	// Tame the pet to the owner
	pet_mob.tamed(H)

	// Set a name if the pet doesn't have a unique one
	if(pet_mob.name == initial(pet_mob.name))
		var/new_name = stripped_input(H, "What is your pet's name?", "Pet Name", initial(pet_mob.name), MAX_NAME_LEN)
		if(new_name)
			pet_mob.fully_replace_character_name(null, new_name)

	var/datum/component/obeys_commands/command_component = pet_mob.GetComponent(/datum/component/obeys_commands)
	if(command_component)
		var/datum/pet_command/follow/follow_command = command_component.available_commands["Follow"]
		if(follow_command)
			pet_mob.ai_controller?.set_blackboard_key(BB_CURRENT_PET_TARGET, H)
			follow_command.execute_action(pet_mob.ai_controller)

/datum/quirk/boon/pet/on_remove()
	// Don't delete the pet when quirk is removed, just release it
	if(pet_mob && !QDELETED(pet_mob))
		pet_mob.owner = null
		pet_mob.tame = FALSE
		pet_mob = null

/datum/quirk/boon/pet/get_option_name(option)
	if(ispath(option, /mob/living/simple_animal))
		var/mob/living/simple_animal/A = option
		return initial(A.name)
	return ..()

/datum/quirk/boon/folk_hero
	name = "Folk Hero"
	desc = "You're a local legend who saved your community from great danger. People recognize you, even as a foreigner."
	point_value = -3

/datum/quirk/boon/folk_hero/on_spawn()
	if(!ishuman(owner))
		return
	RegisterSignal(owner, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/quirk/boon/folk_hero/on_remove()
	if(!ishuman(owner))
		return
	UnregisterSignal(owner, COMSIG_PARENT_EXAMINE)

/datum/quirk/boon/folk_hero/proc/on_examine(mob/living/source, mob/user, list/examine_list)
	if(!ishuman(user) || !ishuman(source))
		return

	var/mob/living/carbon/human/H = source
	var/mob/living/carbon/human/examiner = user

	if(!examiner.mind || !H.mind)
		return

	// Folk heroes are recognized by others
	if(prob(80)) // 80% chance people recognize them
		examine_list += span_notice("You recognize [H.real_name], the folk hero!")

		// Add them to known people if not already known
		if(!examiner.mind.do_i_know(H.mind))
			examiner.mind.i_know_person(H.mind)
			H.mind.i_know_person(examiner.mind)

/datum/quirk/boon/quick_hands
	name = "Quick Hands"
	desc = "You have great hand-eye coordination and know how to move your fingers fast. All crafts are 10% faster."
	point_value = -4

/datum/quirk/boon/quick_hands/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_QUICK_HANDS, "[type]")

/datum/quirk/boon/quick_hands/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_QUICK_HANDS, "[type]")
