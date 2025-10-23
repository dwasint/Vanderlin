/datum/job/absolver
	title = "Absolver"
	department_flag = INQUISITION
	faction = "Station"
	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	total_positions = 1 // THE ONE.
	spawn_positions = 1
	allowed_races = RACES_PLAYER_ALL
	allowed_patrons = list(/datum/patron/psydon) //You MUST have a Psydonite character to start. Just so people don't get japed into Oops Suddenly Psydon!
	tutorial = "The Orthodoxy claims you are naught more than a 'cleric', but you know the truth; you are a sacrifical lamb. Your hands, unmarred through prayer and pacifism, have been gifted with the power to manipulate lux - to siphon away the wounds of others, so that you may endure in their stead. Let your censer's light shepherd the Inquisitor's retinue forth, lest they're led astray by wrath and temptation."
	selection_color = JCOLOR_INQUISITION
	outfit = /datum/outfit/job/absolver
	bypass_lastclass = TRUE
	display_order = JDO_ABSOLVER
	min_pq = 3 // Low potential for grief. A pacifist by trade. Also needs to know wtf a PSYDON is.
	give_bank_account = 15

// REMEMBER FLAGELLANT? REMEMBER LASZLO? THIS IS HIM NOW. FEEL OLD YET?

/datum/job/absolver/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	. = ..()
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.grant_language(/datum/language/otavan)

/datum/outfit/job/absolver/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_skillrank(/datum/skill/misc/athletics, 3, TRUE) // Enduring.
	H.adjust_skillrank(/datum/skill/misc/climbing, 4, TRUE)
	H.adjust_skillrank(/datum/skill/misc/sewing, 3, TRUE) // A hobbyist.
	H.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
	H.adjust_skillrank(/datum/skill/combat/unarmed, 1, TRUE) // Parry things.
	H.adjust_skillrank(/datum/skill/misc/medicine, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/cooking, 3, TRUE)
	H.adjust_skillrank(/datum/skill/labor/fishing, 3, TRUE)
	H.adjust_skillrank(/datum/skill/misc/swimming, 3, TRUE)
	H.adjust_skillrank(/datum/skill/craft/crafting, 3, TRUE)
	wrists = /obj/item/clothing/wrists/bracers/psythorns
	gloves = /obj/item/clothing/gloves/leather/otavan/inqgloves
	beltr = /obj/item/flashlight/flare/torch/lantern/psycenser
	beltl = /obj/item/storage/belt/pouch/coins/rich
	neck = /obj/item/clothing/neck/psycross/silver
	cloak = /obj/item/clothing/cloak/absolutionistrobe
	backr = /obj/item/storage/backpack/satchel/otavan
	belt = /obj/item/storage/belt/leather
	pants = /obj/item/clothing/pants/trou/leather/advanced/colored/duelpants
	armor = /obj/item/clothing/armor/plate/cuirass/psydon
	shirt = /obj/item/clothing/armor/gambeson/heavy/inq
	shoes = /obj/item/clothing/shoes/psydonboots
	mask = /obj/item/clothing/head/helmet/blacksteel/psythorns
	head = /obj/item/clothing/head/helmet/heavy/absolver
	ring = /obj/item/clothing/ring/signet/silver
	backpack_contents = list(
		/obj/item/book/bibble/psy = 1,
		/obj/item/natural/bundle/cloth = 2,
		/obj/item/reagent_containers/glass/bottle/healthpot = 2,
		/obj/item/paper/inqslip/arrival/abso = 1,
		/obj/item/needle = 1,
		/obj/item/natural/worms/leech = 1,
		/obj/item/key/inquisition = 1,
		)
	H.change_stat(STATKEY_END, 3)
	H.change_stat(STATKEY_CON, 7)
	H.change_stat(STATKEY_SPD, -2)
	H.add_spell(/datum/action/cooldown/spell/psydonlux_tamper)
	H.add_spell(/datum/action/cooldown/spell/psydonabsolve)
	H.add_spell(/datum/action/cooldown/spell/diagnose)
	var/datum/devotion/C = new /datum/devotion(H, H.patron)
	C.make_absolver()
	C.grant_to(H)

	ADD_TRAIT(H, TRAIT_NOPAINSTUN, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_PACIFISM, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_CRITICAL_RESISTANCE, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_STEELHEARTED, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_INQUISITION, TRAIT_GENERIC)
	ADD_TRAIT(H, TRAIT_SILVER_BLESSED, TRAIT_GENERIC)

