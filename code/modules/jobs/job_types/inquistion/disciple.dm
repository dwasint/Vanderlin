/datum/job/advclass/disciple
	title = "Disciple"
	tutorial = "Disciples are Otavan martial artists, recruited by the Inquisition for their iron physique."
	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_PLAYER_ALL
	outfit = /datum/outfit/job/disciple
	category_tags = list(CTAG_INQUISITION)

/obj/item/storage/belt/leather/rope/dark
	color = "#505050"

/datum/outfit/job/disciple/pre_equip(mob/living/carbon/human/H)
	..()
	neck = /obj/item/clothing/neck/psycross/silver/astrata
	cloak = /obj/item/clothing/cloak/psydontabard/alt
	pants = /obj/item/clothing/pants/tights/colored/black
	mask = /obj/item/clothing/head/helmet/blacksteel/psythorns
	wrists = /obj/item/clothing/wrists/wrappings
	shoes = /obj/item/clothing/shoes/psydonboots
	neck = /obj/item/clothing/neck/psycross/silver
	belt = /obj/item/storage/belt/leather/rope/dark
	beltl = /obj/item/storage/belt/pouch/coins/mid
	beltr = /obj/item/key/church
	ring = /obj/item/clothing/ring/signet/silver
	backl = /obj/item/storage/backpack/satchel/otavan
	backpack_contents = list(
		/obj/item/key/inquisition = 1,
		/obj/item/paper/inqslip/arrival/ortho = 1
	)

	H.adjust_skillrank(/datum/skill/misc/athletics, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/wrestling, 4, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sneaking, 2, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
	H.adjust_skillrank(/datum/skill/misc/medicine, 2, TRUE)
	H.adjust_skillrank(/datum/skill/magic/holy, 2, TRUE)
	H.change_stat(STATKEY_STR, 3)
	H.change_stat(STATKEY_END, 2)
	H.change_stat(STATKEY_SPD, 2)
	H.change_stat(STATKEY_PER, -1)
	ADD_TRAIT(H, TRAIT_DODGEEXPERT, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)

	var/datum/devotion/devotion = new /datum/devotion(H, H.patron)
	devotion.make_cleric()
	devotion.grant_to(H)
	H.verbs += list(/mob/living/carbon/human/proc/devotionreport, /mob/living/carbon/human/proc/clericpray)

	var/weapons = list("MY BARE HANDS", "Katar", "Knuckles")
	var/weapon_choice = input(H,"Choose your PSYDONIAN weapon.", "TAKE UP PSYDON'S ARMS") as anything in weapons
	switch(weapon_choice)
		if("MY BARE HANDS")
			H.set_skillrank(/datum/skill/combat/unarmed, 5, TRUE)
		if("Katar")
			H.put_in_hands(new /obj/item/weapon/katar/psydon(H), TRUE)
		if("Knuckles")
			H.put_in_hands(new /obj/item/weapon/knuckles/psydon(H), TRUE)

