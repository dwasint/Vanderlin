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
	H.lighting_alpha = LIGHTING_PLANE_ALPHA_NV_TRAIT
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
	point_value = -4

/datum/quirk/boon/light_footed/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, 2)

/datum/quirk/boon/light_footed/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_SPD, -2)

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
	point_value = -3

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
