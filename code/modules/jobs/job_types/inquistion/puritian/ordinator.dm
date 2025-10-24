
/datum/job/advclass/puritan/ordinator
	title = "Ordinator"
	tutorial = "Adjudicators who - through valor and martiality - have proven themselves to be champions in all-but-name. Now, they have been personally chosen by the High Bishop of the Otavan Sovereignty for a mission-most-imperative: to hunt down and destroy the monsters threatening this fief. Ideal for those who prefer overt-and-chivalrous affairs."
	outfit = /datum/outfit/job/inquisitor/ordinator
	cmode_music = 'sound/music/combat_inqordinator.ogg'

	category_tags = list(CTAG_PURITAN)

	skills = list(
		/datum/skill/misc/climbing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/athletics = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_JOURNEYMAN,
	)

	jobstats = list(
		STATKEY_STR = 2,
		STATKEY_END = 3,
		STATKEY_CON = 3,
		STATKEY_PER = 2,
		STATKEY_INT = 2,
	)

	traits = list(
		TRAIT_STEELHEARTED,
		TRAIT_HEAVYARMOR,
		TRAIT_INQUISITION,

	)

/datum/outfit/job/inquisitor/ordinator/pre_equip(mob/living/carbon/human/H)
	..()
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.make_templar()
	C.grant_to(H)

	H.verbs |= /mob/living/carbon/human/proc/faith_test
	H.verbs |= /mob/living/carbon/human/proc/torture_victim

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
			H.put_in_hands(new /obj/item/weapon/sword/long/greatsword/broadsword/psy/relic(H), TRUE)
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
