/datum/quirk/vice
	abstract_type = /datum/quirk/vice
	quirk_category = QUIRK_VICE
	var/next_sate = 0
	var/sated = TRUE
	var/time = 5 MINUTES
	var/debuff = /datum/status_effect/debuff/addiction
	var/needsate_text
	var/sated_text = "That's much better..."
	var/unsate_time

/datum/quirk/vice/on_spawn()
	next_sate = world.time + rand(10 MINUTES, 20 MINUTES)

/datum/quirk/vice/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	// Skip for certain antags
	if(H.mind?.antag_datums)
		for(var/datum/antagonist/D in H.mind.antag_datums)
			if(istype(D, /datum/antagonist/vampire) || istype(D, /datum/antagonist/werewolf) || istype(D, /datum/antagonist/skeleton) || istype(D, /datum/antagonist/zombie))
				return

	var/oldsated = sated
	if(oldsated && next_sate && world.time > next_sate)
		sated = FALSE

	if(sated != oldsated)
		unsate_time = world.time
		if(needsate_text)
			to_chat(user, span_boldwarning("[needsate_text]"))

	if(!sated)
		switch(world.time - unsate_time)
			if(0 to 5 MINUTES)
				H.add_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice2)
				H.remove_stress(/datum/stress_event/vice3)
			if(5 MINUTES to 15 MINUTES)
				H.add_stress(/datum/stress_event/vice2)
				H.remove_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice3)
			if(15 MINUTES to INFINITY)
				H.add_stress(/datum/stress_event/vice3)
				H.remove_stress(/datum/stress_event/vice1)
				H.remove_stress(/datum/stress_event/vice2)
		if(debuff)
			H.apply_status_effect(debuff)

/mob/living/proc/sate_addiction()
	return

/mob/living/carbon/human/sate_addiction()
	for(var/datum/quirk/vice/V in quirks)
		remove_stress(list(/datum/stress_event/vice1, /datum/stress_event/vice2, /datum/stress_event/vice3))
		if(!V.sated)
			to_chat(src, span_blue(V.sated_text))
		V.sated = TRUE
		V.next_sate = world.time + V.time + rand(-1 MINUTES, 1 MINUTES)
		if(V.debuff)
			remove_status_effect(V.debuff)

/datum/quirk/vice/alcoholic
	name = "Drunkard"
	desc = "Drinking alcohol is my favorite thing."
	point_value = 3
	time = 40 MINUTES
	needsate_text = "Time for a drink."

/datum/quirk/vice/smoker
	name = "Smoker"
	desc = "I need to smoke something to take the edge off."
	point_value = 3
	time = 40 MINUTES
	needsate_text = "Time for a flavorful smoke."

/datum/quirk/vice/junkie
	name = "Junkie"
	desc = "I need a real high to take the pain of this rotten world away."
	point_value = 3
	time = 50 MINUTES
	needsate_text = "Time to reach a new high."

/datum/quirk/vice/pyromaniac
	name = "Fire Servant"
	desc = "The warmth and just seeing something turn to ash is so much fun!"
	point_value = 3
	time = 10 MINUTES
	needsate_text = "I need to see something turn to ash, or be on fire. Anything!"

/datum/quirk/vice/kleptomaniac
	name = "Thief-Borne"
	desc = "As a child I had to rely on theft to survive. Whether that changed or not, I just can't get over it."
	point_value = 4
	time = 30 MINUTES
	needsate_text = "I need to STEAL something! I'll die if I don't!"

/datum/quirk/vice/godfearing
	name = "Devout Follower"
	desc = "I need to pray to my Patron, their blessings are stronger."
	point_value = 1
	time = 40 MINUTES
	needsate_text = "Time to pray."

/datum/quirk/vice/maniac // this will probably NOT be used as an actual flaw
	name = "Maniac"
	desc = "The worms call me the maniac... I just like seeing limbs fly and blood drip, is there something so BAD about that?"
	random_exempt = TRUE
	time = 40 MINUTES // we dont wanna contribute to fragging
	point_value = 2
	needsate_text = "Where's all the blood?"
