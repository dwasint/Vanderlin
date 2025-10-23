/datum/job/advclass/confessor
	title = "Confessor"
	tutorial = "Psydonite hunters, unmatched in the fields of subterfuge and investigation. There is no suspect too powerful to investigate, no room too guarded to infiltrate, and no weakness too hidden to exploit."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_PLAYER_ALL
	outfit = /datum/outfit/job/confessor
	category_tags = list(CTAG_INQUISITION)
	cmode_music = 'sound/music/cmode/antag/combat_deadlyshadows.ogg'


/datum/outfit/job/confessor/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/combat/wrestling, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE) // Quick
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE) // Stitch up your prey
	H.adjust_skillrank(/datum/skill/misc/sneaking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/stealing, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/lockpicking, 5, TRUE)
	H.adjust_skillrank(/datum/skill/combat/crossbows, 4, TRUE)
	wrists = /obj/item/clothing/neck/psycross/silver
	gloves = /obj/item/clothing/gloves/leather/otavan
	beltr = /obj/item/ammo_holder/quiver/bolts
	neck = /obj/item/clothing/neck/gorget
	backr = /obj/item/storage/backpack/satchel/otavan
	backl = /obj/item/gun/ballistic/revolver/grenadelauncher/crossbow
	belt = /obj/item/storage/belt/leather/knifebelt/black/psydon
	pants = /obj/item/clothing/pants/trou/leather/advanced/colored/duelpants
	armor = /obj/item/clothing/armor/leather/jacket/leathercoat/confessor
	shirt = /obj/item/clothing/armor/gambeson/heavy/inq
	shoes = /obj/item/clothing/shoes/psydonboots
	mask = /obj/item/clothing/face/facemask/steel/confessor
	head = /obj/item/clothing/head/roguehood/psydon/confessor
	ring = /obj/item/clothing/ring/signet/silver
	backpack_contents = list(
		/obj/item/key/inquisition = 1,
		/obj/item/rope/inqarticles/inquirycord = 1,
		/obj/item/lockpickring/mundane = 1,
		/obj/item/clothing/head/inqarticles/blackbag = 1,
		/obj/item/inqarticles/garrote = 1,
		/obj/item/grapplinghook = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1
		)
	H.change_stat("strength", -1) // weasel
	H.change_stat("endurance", 3)
	H.change_stat("perception", 2)
	H.change_stat("speed", 3)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PSYDONITE, TRAIT_GENERIC) // YOU'RE TRYING TO ENDURE, HERE.
	ADD_TRAIT(H, TRAIT_BLACKBAGGER, TRAIT_GENERIC) // NECESSARY EVIL.
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)
	H.grant_language(/datum/language/otavan)

	var/weapons = list("Shortsword", "Handmace", "Dagger")
	var/weapon_choice = input(H,"Choose your PSYDONIAN weapon.", "TAKE UP PSYDON'S ARMS") as anything in weapons
	switch(weapon_choice)
		if("Shortsword")
			H.put_in_hands(new /obj/item/weapon/sword/short/psy/preblessed(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/scabbard/sword, ITEM_SLOT_BELT_L, TRUE)
			H.set_skillrank(/datum/skill/combat/swords, 4, TRUE)
		if("Handmace")
			H.equip_to_slot_or_del(new /obj/item/weapon/mace/cudgel/psy/preblessed, ITEM_SLOT_BELT_L, TRUE)
			H.set_skillrank(/datum/skill/combat/axesmaces, 4, TRUE)
		if("Dagger")
			H.put_in_hands(new /obj/item/weapon/knife/dagger/silver/psydon(H), TRUE)
			H.equip_to_slot_or_del(new /obj/item/weapon/scabbard/knife, ITEM_SLOT_BELT_L, TRUE)
			H.set_skillrank(/datum/skill/combat/knives, 4, TRUE)
