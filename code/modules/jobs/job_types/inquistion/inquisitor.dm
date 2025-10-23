/datum/job/inquisitor
	title = "Inquisitor"
	department_flag = INQUISITION
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_PLAYER_ALL		//Not been around long enough to be inquisitor, brand new race to the world.
	allowed_patrons = list(/datum/patron/psydon) //You MUST have a Psydonite character to start. Just so people don't get japed into Oops Suddenly Psydon!
	tutorial = "You have been sent here as a diplomatic envoy from the Sovereignty of Otava: a silver-tipped olive branch, unmatched in aptitude and unshakable in faith. Though you might be ostracized due to your Psydonic beliefs, neither the Church nor Crown can deny your value, whenever matters of inhumenity arise to threaten this fief."
	cmode_music = 'sound/music/inquisitorcombat.ogg'
	selection_color = JCOLOR_INQUISITION

	outfit = /datum/outfit/job/inquisitor
	display_order = JDO_PURITAN
	advclass_cat_rolls = list(CTAG_PURITAN = 20)
	give_bank_account = 30
	min_pq = 10
	bypass_lastclass = TRUE

/datum/outfit/job/inquisitor
	name = "Inquisitor"

/datum/job/inquisitor/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.grant_language(/datum/language/otavan)
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")


////Classic Inquisitor with a much more underground twist. Use listening devices, sneak into places to gather evidence, track down suspicious individuals. Has relatively the same utility stats as Confessor, but fulfills a different niche in terms of their combative job as the head honcho.

/datum/job/advclass/puritan/inspector
	title = "Inquisitor"
	tutorial = "Investigators from countless backgrounds, personally chosen by the High Bishop of the Otavan Sovereignty to root out heresy all across the world. Dressed in fashionable leathers and armed with a plethora of equipment, these beplumed officers are ready to tackle the inhumen: anywhere, anytime. Ideal for those who prefer sleuthy-and-clandestine affairs."
	outfit = /datum/outfit/job/inquisitor/inspector

	category_tags = list(CTAG_PURITAN)

/datum/outfit/job/inquisitor/inspector/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/knives, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 2, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 2)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 3)
	H.change_stat("speed", 1)
	H.change_stat("intelligence", 3)
	H.verbs |= /mob/living/carbon/human/proc/faith_test
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.make_templar(H)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_BLACKBAGGER, TRAIT_GENERIC) // Probably trained the Confessors. Or was one. Who knows.
	ADD_TRAIT(H, TRAIT_MEDIUMARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PURITAN, JOB_TRAIT)
	shirt = /obj/item/clothing/armor/gambeson/heavy/inq
	belt = /obj/item/storage/belt/leather/knifebelt/black/psydon
	neck = /obj/item/clothing/neck/gorget
	shoes = /obj/item/clothing/shoes/otavan/inqboots
	pants = /obj/item/clothing/pants/tights/colored/black
	backr =  /obj/item/storage/backpack/satchel/otavan
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	beltr = /obj/item/ammo_holder/quiver/bolts
	head = /obj/item/clothing/head/leather/inqhat
	mask = /obj/item/clothing/face/spectacles/inq/spawnpair
	gloves = /obj/item/clothing/gloves/leather/otavan
	wrists = /obj/item/clothing/neck/psycross/silver
	ring = /obj/item/clothing/ring/signet/silver
	armor = /obj/item/clothing/armor/medium/scale/inqcoat/armored
	backpack_contents = list(
		/obj/item/storage/keyring/inquisitor = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/weapon/knife/dagger/silver/psydon,
		/obj/item/clothing/head/inqarticles/blackbag = 1,
		/obj/item/inqarticles/garrote = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/grapplinghook = 1,
		/obj/item/storage/belt/pouch/coins/rich = 1,
		/obj/item/paper/inqslip/arrival/inq = 1,
		/obj/item/weapon/scabbard/knife = 1
		)

	var/weapons = list("Eucharist (Rapier)", "Daybreak (Whip)", "Stigmata (Halberd)")
	var/weapon_choice = input(H,"CHOOSE YOUR RELIQUARY PIECE.", "WIELD THEM IN HIS NAME.") as anything in weapons
	switch(weapon_choice)
		if("Eucharist (Rapier)")
			H.put_in_hands(new /obj/item/weapon/sword/rapier/psy/relic(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/scabbard/sword, ITEM_SLOT_BELT_L, TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/swords, 4, 4)
		if("Daybreak (Whip)")
			H.put_in_hands(new /obj/item/weapon/whip/antique/psywhip(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/whipsflails, 4, 4)
		if("Stigmata (Halberd)")
			H.put_in_hands(new /obj/item/weapon/halberd/psydon/relic(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/polearms, 4, 4)


///The dirty, violent side of the Inquisition. Meant for confrontational, conflict-driven situations as opposed to simply sneaking around and asking questions. Templar with none of the miracles, but with all the muscles and more.

/datum/job/advclass/puritan/ordinator
	title = "Ordinator"
	tutorial = "Adjudicators who - through valor and martiality - have proven themselves to be champions in all-but-name. Now, they have been personally chosen by the High Bishop of the Otavan Sovereignty for a mission-most-imperative: to hunt down and destroy the monsters threatening this fief. Ideal for those who prefer overt-and-chivalrous affairs."
	outfit = /datum/outfit/job/inquisitor/ordinator
	cmode_music = 'sound/music/combat_inqordinator.ogg'

	category_tags = list(CTAG_PURITAN)

/datum/outfit/job/inquisitor/ordinator/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.change_stat("strength", 2)
	H.change_stat("endurance", 3)
	H.change_stat("constitution", 3)
	H.change_stat("perception", 2)
	H.change_stat("intelligence", 2)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.make_templar()
	C.grant_to(H)

	H.verbs |= /mob/living/carbon/human/proc/faith_test
	H.verbs |= /mob/living/carbon/human/proc/torture_victim
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	shirt = /obj/item/clothing/armor/gambeson/heavy/inq
	armor = /obj/item/clothing/armor/plate/full/fluted/ornate/ordinator
	belt = /obj/item/storage/belt/leather/steel
	neck = /obj/item/clothing/neck/gorget
	shoes = /obj/item/clothing/shoes/otavan/inqboots
	backl = /obj/item/storage/backpack/satchel/otavan
	wrists = /obj/item/clothing/neck/psycross/silver
	ring = /obj/item/clothing/ring/signet/silver
	pants = /obj/item/clothing/pants/platelegs
	cloak = /obj/item/clothing/cloak/ordinatorcape
	beltr = /obj/item/storage/belt/pouch/coins/rich
	head = /obj/item/clothing/head/helmet/heavy/ordinatorhelm
	gloves = /obj/item/clothing/gloves/leather/otavan
	backpack_contents = list(
		/obj/item/storage/keyring/inquisitor = 1,
		/obj/item/paper/inqslip/arrival/inq = 1
		)

	var/weapons = list("Covenant And Creed (Broadsword + Shield)", "Covenant and Consecratia (Flail + Shield)", "Apocrypha (Greatsword) and a Silver Dagger")
	var/weapon_choice = input(H,"CHOOSE YOUR RELIQUARY PIECE.", "WIELD THEM IN HIS NAME.") as anything in weapons
	switch(weapon_choice)
		if("Covenant And Creed (Broadsword + Shield)")
			H.put_in_hands(new /obj/item/weapon/greatsword/broadsword/psy/relic(H), TRUE)
			H.put_in_hands(new /obj/item/paper/inqslip/arrival/inq(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/shield/tower/metal/psy, ITEM_SLOT_BACK_R, TRUE)
			var/annoyingbag = H.get_item_by_slot(ITEM_SLOT_BACK_L)
			qdel(annoyingbag)
			H.equip_to_slot_or_del(new /obj/item/storage/keyring/inquisitor, ITEM_SLOT_BACK_L, TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/swords, 5, 5)
			H.clamped_adjust_skillrank(/datum/skill/combat/shields, 4, 4)
		if("Covenant and Consecratia (Flail + Shield)")
			H.put_in_hands(new /obj/item/weapon/flail/psydon/relic(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/shield/tower/metal/psy, ITEM_SLOT_BACK_R, TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/whipsflails, 5, 5)
			H.clamped_adjust_skillrank(/datum/skill/combat/shields, 4, 4)
		if("Apocrypha (Greatsword) and a Silver Dagger")
			H.put_in_hands(new /obj/item/weapon/sword/long/greatsword/psydon/relic(H), TRUE)
			H.put_in_hands(new /obj/item/weapon/knife/dagger/silver/psydon(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/scabbard/knife, ITEM_SLOT_BACK_L, TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/swords, 5, 5)
			H.clamped_adjust_skillrank(/datum/skill/combat/knives, 4, 4)


/obj/item/clothing/gloves/chain/blk
		color = "#6c6c6c"

/obj/item/clothing/under/chainlegs/blk
		color = "#6c6c6c"

/obj/item/clothing/suit/armor/plate/blk
		color = "#6c6c6c"

/obj/item/clothing/shoes/boots/armor/blk
		color = "#6c6c6c"

/mob/living/carbon/human/proc/torture_victim()
	set name = "Extract Confession"
	set category = "Inquisition"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I won't torture myself!"))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 12)) * 100
	if(painpercent < 100)
		to_chat(src, span_warning("Not ready to speak yet."))
		return
	if(!do_after(src, 4 SECONDS, H))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	if(H.add_stress(/datum/stress_event/tortured))
		SEND_SIGNAL(src, COMSIG_TORTURE_PERFORMED, H)
		var/static/list/torture_lines = list(
			"CONFESS YOUR WRONGDOINGS!",
			"TELL ME YOUR SECRETS!",
			"SPEAK THE TRUTH!",
			"YOU WILL SPEAK!",
			"TELL ME!",
			"THE PAIN HAS ONLY BEGUN, CONFESS!",
		)
		say(pick(torture_lines), spans = list("torture"))
		H.emote("painscream")
		H.confession_time("antag", src)

/mob/living/carbon/human/proc/faith_test()
	set name = "Test Faith"
	set category = "Inquisition"

	var/obj/item/grabbing/I = get_active_held_item()
	var/mob/living/carbon/human/H
	if(!istype(I) || !ishuman(I.grabbed))
		return
	H = I.grabbed
	if(H == src)
		to_chat(src, span_warning("I won't torture myself!"))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	var/painpercent = (H.get_complex_pain() / (H.STAEND * 12)) * 100
	if(painpercent < 100)
		to_chat(src, span_warning("Not ready to speak yet."))
		return
	if(!do_after(src, 4 SECONDS, H))
		return
	if(!HAS_TRAIT(H, TRAIT_RESTRAINED) && !H.buckled)
		to_chat(src, span_warning("[H] needs to be restrained or buckled first!"))
		return
	if(H.stat == DEAD)
		to_chat(src, span_warning("[H] is dead already..."))
		return
	if(H.add_stress(/datum/stress_event/tortured))
		SEND_SIGNAL(src, COMSIG_TORTURE_PERFORMED, H)
		var/static/list/faith_lines = list(
			"DO YOU DENY PSYDON AND THE TEN?",
			"WHO IS YOUR GOD?",
			"ARE YOU FAITHFUL?",
			"TO WHICH SHEPHERD DO YOU FLOCK TO?",
		)
		say(pick(faith_lines), spans = list("torture"))
		H.emote("painscream")
		H.confession_time("patron", src)

/mob/living/carbon/human/proc/confession_time(confession_type = "antag", mob/living/carbon/human/user)
	var/timerid = addtimer(CALLBACK(src, PROC_REF(confess_sins), confession_type, FALSE, user), 10 SECONDS, TIMER_STOPPABLE)
	var/static/list/options = list("RESIST!!", "CONFESS!!")
	var/responsey = browser_input_list(src, "Resist torture?", "TEST OF PAIN", options)

	if(SStimer.timer_id_dict[timerid])
		deltimer(timerid)
	else
		to_chat(src, span_warning("Too late..."))
		return
	if(responsey == "RESIST!!")
		confess_sins(confession_type, resist=TRUE, interrogator=user)
	else
		confess_sins(confession_type, resist=FALSE, interrogator=user)

/mob/living/carbon/human/proc/confess_sins(confession_type = "antag", resist, mob/living/carbon/human/interrogator, torture=TRUE, obj/item/paper/confession/confession_paper, false_result)
	if(stat == DEAD)
		return
	var/static/list/innocent_lines = list(
		"I DON'T KNOW!",
		"STOP THIS MADNESS!!",
		"I DON'T DESERVE THIS!",
		"THE PAIN!",
		"I HAVE NOTHING TO SAY...!",
		"WHY ME?!",
		"I'M INNOCENT!",
		"I AM NO SINNER!",
	)
	var/resist_chance = 0
	if(resist)
		to_chat(src, span_boldwarning("I attempt to resist the torture!"))
		resist_chance = (STAINT + STAEND) + 10
		if(istype(buckled, /obj/structure/fluff/walldeco/chains)) // If the victim is on hanging chains, apply a resist penalty
			resist_chance -= 15
		if(confession_type == "antag")
			resist_chance += 25

	if(!prob(resist_chance))
		var/list/confessions = list()
		var/datum/antag_type = null
		switch(confession_type)
			if("antag")
				if(!false_result)
					for(var/datum/antagonist/antag in mind?.antag_datums)
						if(!length(antag.confess_lines))
							continue
						confessions += antag.confess_lines
						antag_type = antag.type
						break // Only need one antag type
			if("patron")
				if(ispath(false_result, /datum/patron))
					var/datum/patron/fake_patron = new false_result()
					if(length(fake_patron.confess_lines))
						confessions += fake_patron.confess_lines
						antag_type = fake_patron.type
				else
					if(length(patron?.confess_lines))
						confessions += patron.confess_lines
						antag_type = patron.type

		// Apply stress penalties for torturing innocents/faithful
		if(torture && interrogator && confession_type == "patron")
			var/datum/patron/interrogator_patron = interrogator.patron
			var/datum/patron/victim_patron = patron
			switch(interrogator_patron.associated_faith.type)
				if(/datum/faith/psydon)
					if(ispath(victim_patron.type, /datum/patron/divine) && victim_patron.type != /datum/patron/divine/necra) //lore
						interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					else if(victim_patron.type == /datum/patron/psydon/progressive)
						interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					else if(victim_patron.type == /datum/patron/godless/naivety)
						interrogator.add_stress(/datum/stress_event/torture_small_penalty)
					else if(victim_patron.type == /datum/patron/psydon)
						interrogator.add_stress(/datum/stress_event/torture_large_penalty)

		if(length(confessions))
			if(torture) // Only scream your confession if it's due to torture.
				say(pick(confessions), spans = list("torture"), forced = TRUE)
			else
				say(pick(confessions), forced = TRUE)

			var/obj/item/paper/confession/held_confession
			if(istype(confession_paper))
				held_confession = confession_paper
			else if(interrogator?.is_holding_item_of_type(/obj/item/paper/confession)) // This code is to process gettin a signed confession through torture.
				held_confession = interrogator.is_holding_item_of_type(/obj/item/paper/confession)
			if(held_confession && !held_confession.signed) // Check to see if the confession is already signed.
				switch(antag_type)
					if(/datum/antagonist/bandit)
						held_confession.bad_type = "AN OUTLAW OF THE THIEF-LORD"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/matthios)
						held_confession.bad_type = "A FOLLOWER OF THE THIEF-LORD"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					if(/datum/antagonist/maniac)
						held_confession.bad_type = "A MANIAC DELUDED BY MADNESS"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/assassin)
						held_confession.bad_type = "A DEATH CULTIST"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/zizocultist)
						held_confession.bad_type = "A SERVANT OF THE FORBIDDEN ONE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/zizocultist/leader)
						held_confession.bad_type = "A SERVANT OF THE FORBIDDEN ONE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/zizo)
						held_confession.bad_type = "A FOLLOWER OF THE FORBIDDEN ONE"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					if(/datum/antagonist/werewolf)
						var/datum/antagonist/werewolf/werewolf_antag = mind.has_antag_datum(/datum/antagonist/werewolf, TRUE)
						if(werewolf_antag.transformed) // haha real clever of ya
							return
						held_confession.bad_type = "A BEARER OF DENDOR'S CURSE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/werewolf/lesser)
						var/datum/antagonist/werewolf/werewolf_antag = mind.has_antag_datum(/datum/antagonist/werewolf, TRUE)
						if(werewolf_antag.transformed)
							return
						held_confession.bad_type = "A BEARER OF DENDOR'S CURSE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire)
						held_confession.bad_type = "A SCION OF KAINE"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire/lord)
						held_confession.bad_type = "THE BLOOD-LORD OF VANDERLIN"
						held_confession.antag = initial(antag_type:name)
					if(/datum/antagonist/vampire/lesser)
						held_confession.bad_type = "AN UNDERLING OF THE BLOOD-LORD"
						held_confession.antag = initial(antag_type:name)
					if(/datum/patron/inhumen/graggar)
						held_confession.bad_type = "A FOLLOWER OF THE DARK SUN"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					if(/datum/patron/godless/godless)
						held_confession.bad_type = "A DAMNED ANTI-THEIST"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/autotheist)
						held_confession.bad_type = "A DELUSIONAL SELF-PROCLAIMED GOD"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/defiant)
						held_confession.bad_type = "A DAMNED CHAINBREAKER"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/dystheist)
						held_confession.bad_type = "A SPURNER OF THE DIVINE"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/naivety)
						held_confession.bad_type = "A IGNORANT FOOL"
						held_confession.antag = "worshiper of nothing"
					if(/datum/patron/godless/rashan)
						held_confession.bad_type = "A FOLLOWER OF A FALSE GOD"
						held_confession.antag = "worshiper of the false god, Rashan-Kahl"
					if(/datum/patron/inhumen/baotha)
						held_confession.bad_type = "A FOLLOWER OF THE REMORSELESS RUINER"
						held_confession.antag = "worshiper of " + initial(antag_type:name)
					else
						return // good job you tortured an innocent person
				if(HAS_TRAIT_FROM(src, TRAIT_CONFESSED_FOR, held_confession.bad_type))
					visible_message(span_warning("[name] has already signed a confession!"), "I have already signed a confession!")
					return //cruel
				ADD_TRAIT(src, TRAIT_HAS_CONFESSED, TRAIT_GENERIC)
				ADD_TRAIT(src, TRAIT_CONFESSED_FOR, held_confession.bad_type)
				held_confession.signed = real_name
				held_confession.info = "THE GUILTY PARTY ADMITS THEIR SINFUL NATURE AS <font color='red'>[held_confession.bad_type]</font>. THEY WILL SERVE ANY PUNISHMENT OR SERVICE AS REQUIRED BY THE ORDER OF THE PSYCROSS UNDER PENALTY OF DEATH.<br/><br/>SIGNED,<br/><font color='red'><i>[held_confession.signed]</i></font>"
				held_confession.update_appearance(UPDATE_ICON_STATE)
			return
		else
			if(torture) // Only scream your confession if it's due to torture.
				say(pick(innocent_lines), spans = list("torture"), forced = TRUE)
			else
				say(pick(innocent_lines), forced = TRUE)
			return
	to_chat(src, span_good("I resist the torture!"))
	say(pick(innocent_lines), spans = list("torture"), forced = TRUE)
	return
