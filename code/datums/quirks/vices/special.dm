
/datum/quirk/vice/hunted
	name = "Hunted"
	desc = "Something in your past has made you a target. You're always looking over your shoulder. THIS IS A DIFFICULT QUIRK - You will be hunted and have assassination attempts made against you without any escalation. EXPECT A MORE DIFFICULT EXPERIENCE. PLAY AT YOUR OWN RISK."
	point_value = 8
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
	point_value = 10
	random_exempt = TRUE

/datum/quirk/vice/luxless/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner

	if(H.dna?.species?.id in RACES_PLAYER_LUXLESS)
		to_chat(H, span_warning("Your species already lacks lux. This quirk has no effect."))
		return

	H.apply_status_effect(/datum/status_effect/debuff/flaw_lux_taken)

/datum/quirk/vice/pacifist
	name = "Pacifist"
	desc = "I don't want to harm other living beings!"
	point_value = 6

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
