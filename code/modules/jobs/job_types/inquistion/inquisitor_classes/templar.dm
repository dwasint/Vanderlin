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

	var/helmets = list("Barbute", "Sallet", "Armet", "Bucket Helm")
	var/helmet_choice = input(H,"Choose your HELMET.", "TAKE UP PSYDON'S HELMS.") as anything in helmets
	switch(helmet_choice)
		if("Barbute")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psydonbarbute, ITEM_SLOT_HEAD, TRUE)
		if("Sallet")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psysallet, ITEM_SLOT_HEAD, TRUE)
		if("Armet")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psydonhelm, ITEM_SLOT_HEAD, TRUE)
		if("Bucket Helm")
			H.equip_to_slot_or_del(new /obj/item/clothing/head/helmet/heavy/psybucket, ITEM_SLOT_HEAD, TRUE)

	var/armors = list("Hauberk", "Cuirass")
	var/armor_choice = input(H, "Choose your ARMOR.", "TAKE UP PSYDON'S MANTLE.") as anything in armors
	switch(armor_choice)
		if("Hauberk")
			H.equip_to_slot_or_del(new /obj/item/clothing/armor/chainmail/hauberk/fluted, ITEM_SLOT_ARMOR, TRUE)
		if("Cuirass")
			H.equip_to_slot_or_del(new /obj/item/clothing/armor/cuirass/fluted, ITEM_SLOT_ARMOR, TRUE)
			H.change_stat(STATKEY_SPD, 1) //Less durability and coverage, but still upgradable. Balances out the innate -1 SPD debuff.

	var/weapons = list("Psydonic Longsword", "Psydonic War Axe", "Psydonic Whip", "Psydonic Flail", "Psydonic Mace", "Psydonic Spear + Handmace", "Psydonic Poleaxe + Shortsword")
	var/weapon_choice = input(H,"Choose your WEAPON.", "TAKE UP PSYDON'S ARMS.") as anything in weapons
	switch(weapon_choice)
		if("Psydonic Longsword")
			H.put_in_hands(new /obj/item/weapon/sword/long/psydon(H), TRUE)
			H.put_in_hands(new /obj/item/weapon/scabbard/sword(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/swords, 4, 4)
		if("Psydonic War Axe")
			H.put_in_hands(new /obj/item/weapon/axe/psydon(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 4, 4)
		if("Psydonic Whip")
			H.put_in_hands(new /obj/item/weapon/whip/psydon(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/whipsflails, 4, 4)
		if("Psydonic Flail")
			H.put_in_hands(new /obj/item/weapon/flail/psydon(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/whipsflails, 4, 4)
		if("Psydonic Mace")
			H.put_in_hands(new /obj/item/weapon/mace/goden/psydon(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 4, 4)
		if("Psydonic Spear + Handmace")
			H.put_in_hands(new /obj/item/weapon/polearm/spear/psydon(H), TRUE)
			H.put_in_hands(new /obj/item/weapon/mace/cudgel/psy(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/polearms, 4, 4)
		if("Psydonic Poleaxe + Shortsword")
			H.put_in_hands(new /obj/item/weapon/greataxe/psy(H), TRUE)
			H.put_in_hands(new /obj/item/weapon/sword/short/psy(H), TRUE)
			H.clamped_adjust_skillrank(/datum/skill/combat/axesmaces, 4, 4)
