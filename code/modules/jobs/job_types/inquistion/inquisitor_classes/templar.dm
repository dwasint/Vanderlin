/datum/job/advclass/psydoniantemplar // A templar, but for the Inquisition
	title = "Psydonian Templar"
	tutorial = "You are the strong arm of the Inquisition. You serve under the local Inquisitor to forward the goals of the Otavan Inquisition. PSYDON Endures."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_PLAYER_ALL
	outfit = /datum/outfit/job/psydoniantemplar
	category_tags = list(CTAG_INQUISITION)
	cmode_music = 'sound/music/templarofpsydonia.ogg'

/datum/outfit/job/psydoniantemplar/pre_equip(mob/living/carbon/human/H)
	..()
	wrists = /obj/item/clothing/neck/psycross/silver
	cloak = /obj/item/clothing/cloak/psydontabard
	backr = /obj/item/weapon/shield/tower/metal
	gloves = /obj/item/clothing/gloves/chain/psydon
	neck = /obj/item/clothing/neck/chaincoif
	pants = /obj/item/clothing/pants/chainlegs
	backl = /obj/item/storage/backpack/satchel/otavan
	shirt = /obj/item/clothing/armor/gambeson/heavy/inq
	shoes = /obj/item/clothing/shoes/psydonboots
	armor = /obj/item/clothing/armor/chainmail/hauberk/fluted
	head = /obj/item/clothing/head/helmet/heavy/psydonhelm
	belt = /obj/item/storage/belt/leather/black
	beltl = /obj/item/storage/belt/pouch/coins/mid
	ring = /obj/item/clothing/ring/signet/silver
	backpack_contents = list(/obj/item/storage/keyring/inquisitor = 1)
	H.adjust_skillrank(/datum/skill/combat/swords, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/axesmaces, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/whipsflails, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/bows, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 1, TRUE)
	H.adjust_skillrank(/datum/skill/combat/shields, 3, TRUE)
	H.change_stat(STATKEY_STR, 2)
	H.change_stat(STATKEY_CON, 2)
	H.change_stat(STATKEY_END, 3)

	ADD_TRAIT(H, TRAIT_HEAVYARMOR, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)

	H.dna.species.soundpack_m = new /datum/voicepack/male/knight()
	var/datum/devotion/devotion = new /datum/devotion(H, H.patron)
	devotion.make_cleric()
	devotion.grant_to(H)
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)

	var/weapons = list("Bastard Sword","Flail","Mace")
	var/weapon_choice = input(H,"Choose your weapon.", "TAKE UP ARMS") as anything in weapons
	switch(weapon_choice)
		if("Bastard Sword")
			H.put_in_hands(new /obj/item/weapon/sword/long(H), TRUE)
			H.adjust_skillrank(/datum/skill/combat/swords, 1, TRUE)
		if("Flail")
			H.put_in_hands(new /obj/item/weapon/flail(H), TRUE)
			H.adjust_skillrank(/datum/skill/combat/whipsflails, 1, TRUE)
		if("Mace")
			H.put_in_hands(new /obj/item/weapon/mace(H), TRUE)
			H.adjust_skillrank(/datum/skill/combat/axesmaces, 1, TRUE)

	var/helmets = list("Barbute", "Sallet", "Armet", "Bucket Helm")
	var/helmet_choice = input(H,"Choose your PSYDONIAN helmet.", "TAKE UP PSYDON'S HELMS") as anything in helmets
	switch(helmet_choice)
		if("Barbute")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psydonbarbute, ITEM_SLOT_HEAD, TRUE)
		if("Sallet")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psysallet, ITEM_SLOT_HEAD, TRUE)
		if("Armet")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psydonhelm, ITEM_SLOT_HEAD, TRUE)
		if("Bucket Helm")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psybucket, ITEM_SLOT_HEAD, TRUE)
