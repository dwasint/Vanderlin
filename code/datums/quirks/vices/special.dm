
/datum/quirk/vice/hunted
	name = "Hunted"
	desc = "Something in your past has made you a target. You're always looking over your shoulder. THIS IS A DIFFICULT QUIRK - You will be hunted and have assassination attempts made against you without any escalation. EXPECT A MORE DIFFICULT EXPERIENCE. PLAY AT YOUR OWN RISK."
	point_value = 5
	var/logged = FALSE

/datum/quirk/vice/hunted/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(!logged && H.name)
		log_hunted("[H.ckey] playing as [H.name] has the hunted quirk.")
		logged = TRUE

/datum/quirk/vice/luxless
	name = "Lux-less"
	desc = "Through some grand misfortune, or heroic sacrifice - you have given up your link to Psydon, and with it - your soul. A putrid, horrid thing, you consign yourself to an eternity of nil after death. EXPECT A DIFFICULT, MECHANICALLY UNFAIR EXPERIENCE. (Rakshari, Hollowkin and Kobolds cannot take this - they already have no lux.)"
	point_value = 5
	random_exempt = TRUE

/datum/quirk/vice/luxless/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.apply_status_effect(/datum/status_effect/debuff/flaw_lux_taken)

/datum/quirk/vice/pacifist
	name = "Pacifist"
	desc = "I don't want to harm other living beings!"
	point_value = 8

/datum/quirk/vice/pacifist/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner

	// Check if player is an antagonist
	if(H.mind && ((H.mind in GLOB.pre_setup_antags) || H.mind.has_antag_datum(/datum/antagonist)))
		to_chat(H, span_warning("As an antagonist, you cannot be a pacifist. This quirk has been removed."))
		return

	ADD_TRAIT(owner, TRAIT_PACIFISM, "[type]")

/datum/quirk/vice/pacifist/on_remove()
	if(owner)
		REMOVE_TRAIT(owner, TRAIT_PACIFISM, "[type]")

/datum/quirk/vice/chronic_migraine
	name = "Chronic Migraines"
	desc = "You suffer from frequent, debilitating headaches that can strike without warning."
	point_value = 3

/datum/quirk/vice/chronic_migraine/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	for(var/obj/item/bodypart/BP in H.bodyparts)
		if(BP.body_zone == BODY_ZONE_HEAD)
			BP.chronic_pain = rand(17.5, 27.5)
			BP.chronic_pain_type = CHRONIC_NERVE_DAMAGE
			break
	to_chat(H, span_warning("You feel the familiar pressure building behind your eyes."))

/datum/quirk/vice/chronic_migraine/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	if(prob(2))
		for(var/obj/item/bodypart/BP in H.bodyparts)
			if(BP.body_zone == BODY_ZONE_HEAD)
				BP.lingering_pain += rand(25, 40)
				break

		if(prob(30))
			H.set_eye_blur_if_lower(rand(6 SECONDS, 12 SECONDS))
			to_chat(H, span_boldwarning("A severe migraine strikes! Your vision blurs and your head pounds!"))
		else
			to_chat(H, span_warning("A migraine headache begins to build."))

	if(prob(1))
		var/obj/item/bodypart/head = null
		for(var/obj/item/bodypart/BP in H.bodyparts)
			if(BP.body_zone == BODY_ZONE_HEAD)
				head = BP
				break

		if(head && head.lingering_pain > 20 && H.loc && H.loc.luminosity > 2)
			head.lingering_pain += rand(5, 10)
			to_chat(H, span_warning("The flickering flames make your migraine worse!"))


/datum/quirk/vice/skill_issue
	name = "Skill Issue"
	desc = "You were never the best at anything, and it shows. Lose 1 point to all starting skills."
	point_value = 5

/datum/quirk/vice/skill_issue/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	for(var/datum/skill/skill in SSskills.all_skills)
		if(H.get_skill_level(skill) > SKILL_LEVEL_NONE)
			H.adjust_skillrank(skill, -1, TRUE)

/datum/quirk/vice/deaf
	name = "Hard of Hearing"
	desc = "You can barely hear. Words said outside of a 2 tile radius become jumbled or unreadable unless screamed."
	point_value = 3

/datum/quirk/vice/deaf/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_PARTIAL_DEAF, "[type]")

/datum/quirk/vice/deaf/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_PARTIAL_DEAF, "[type]")

/datum/quirk/vice/traumatized
	name = "Traumatized"
	desc = "You were an adventurer once, till you took something to the knee. Choose a creature type to be terrified of."
	point_value = 3
	customization_label = "Choose Fear"
	customization_options = list(
		/datum/species/goblin,
		/datum/species/werewolf,
		/datum/species/orc,
	)

	var/fear_type
	var/next_scream_time = 0

/datum/quirk/vice/traumatized/on_spawn()
	if(!ishuman(owner))
		return
	if(!customization_value)
		customization_value = /datum/species/goblin
	fear_type = customization_value

/datum/quirk/vice/traumatized/on_life(mob/living/user)
	if(world.time < next_scream_time)
		return
	for(var/mob/living/carbon/human/human in view(5, user))
		if(is_species(human, fear_type))
			var/mob/living/carbon/human/H = user
			H.emote("scream")
			H.Immobilize(1.5 SECONDS)
			H.add_stress(/datum/stress_event/traumatized)
			to_chat(H, span_userdanger("You see [human] and freeze in terror!"))
			next_scream_time = world.time + 25 SECONDS

/datum/stress_event/traumatized
	desc = "<span class='danger'>I saw one of THOSE things again!</span>\n"
	stress_change = 5
	timer = 5 MINUTES

/datum/quirk/vice/tortured
	name = "Tortured"
	desc = "You were once tortured by bandits, Drow raiders, or your own kingdom. You fear it happening again and always answer truthfully when tortured."
	point_value = 2

/datum/quirk/vice/tortured/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_TORTURED, "[type]")

/datum/quirk/vice/tortured/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_TORTURED, "[type]")

/datum/stress_event/tortured
	desc = "<span class='danger'>The pain... it brings back memories.</span>\n"
	stress_change = 4
	timer = 5 MINUTES

/datum/quirk/vice/hardcore
	name = "Hardcore"
	desc = "ONE CHANCE. When you die, you have no place in the underworld. You will be reincarnated as a rat, unable to do anything."
	point_value = 3
	random_exempt = TRUE
	var/turning = FALSE

/datum/quirk/vice/hardcore/on_spawn()
	if(!ishuman(owner))
		return
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	RegisterSignal(owner, COMSIG_LIVING_TRY_ENTER_AFTERLIFE, PROC_REF(on_death))
	to_chat(owner, span_boldwarning("You have chosen HARDCORE mode. If you die, you will become a rat. There are no second chances."))

/datum/quirk/vice/hardcore/on_remove()
	if(!ishuman(owner))
		return
	UnregisterSignal(owner, COMSIG_LIVING_DEATH)
	UnregisterSignal(owner, COMSIG_LIVING_TRY_ENTER_AFTERLIFE)

/datum/quirk/vice/hardcore/proc/on_death(mob/living/source)
	if(turning)
		return TRUE
	if(!ishuman(source))
		return

	addtimer(CALLBACK(src, PROC_REF(transform_to_rat), source), 3 SECONDS)
	turning = TRUE
	return TRUE

/datum/quirk/vice/hardcore/proc/transform_to_rat(mob/living/carbon/human/H)
	turning = FALSE

	var/turf/T
	if(!H || QDELETED(H))
		T = get_turf(pick(SSjob.latejoin_trackers))
	else
		T = get_turf(H)
	if(!T)
		return

	var/mob/living/simple_animal/hostile/retaliate/bigrat/new_rat = new(T)
	new_rat.name = "[H.real_name] (rat)"
	new_rat.real_name = new_rat.name

	if(H.mind)
		H.mind.transfer_to(new_rat)

	to_chat(new_rat, span_userdanger("You have been reincarnated as a rat. Your adventure ends here."))

	// Make the rat unable to do much
	ADD_TRAIT(new_rat, TRAIT_PACIFISM, TRAIT_GENERIC)
	new_rat.melee_damage_lower = 0
	new_rat.melee_damage_upper = 0
	new_rat.status_flags |= GODMODE


/datum/quirk/vice/weak_heart
	name = "Weak Heart"
	desc = "You were born with a weak heart. You can't handle stressful situations for fear of your heart giving out (Half threshold for heart attacks and heart attack from being overly stressed)."
	point_value = 6
	incompatible_quirks = list(
		/datum/quirk/boon/iron_will
	)

/datum/quirk/vice/weak_heart/on_spawn()
	if(!ishuman(owner))
		return
	ADD_TRAIT(owner, TRAIT_WEAK_HEART, "[type]")

/datum/quirk/vice/weak_heart/on_remove()
	if(!ishuman(owner))
		return
	REMOVE_TRAIT(owner, TRAIT_WEAK_HEART, "[type]")
