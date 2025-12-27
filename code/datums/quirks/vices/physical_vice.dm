/datum/status_effect/debuff/badvision
	id = "badvision"
	alert_type = null
	effectedstats = list(STATKEY_PER = -20, STATKEY_SPD = -5, STATKEY_LCK = -20)
	duration = 100

/datum/quirk/vice/bad_sight
	name = "Poor Vision"
	desc = "I need spectacles to see normally from my years spent reading books."
	point_value = 2

/datum/quirk/vice/bad_sight/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	owner.adjust_skillrank(/datum/skill/misc/reading, 1, TRUE)

	if(H.wear_mask)
		var/type = H.wear_mask.type
		QDEL_NULL(H.wear_mask)
		H.put_in_hands(new type(get_turf(H)))
	H.equip_to_slot_or_del(new /obj/item/clothing/face/spectacles(H), ITEM_SLOT_MASK)

/datum/quirk/vice/bad_sight/on_life(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.wear_mask && istype(H.wear_mask, /obj/item/clothing/face/spectacles))
		var/obj/item/I = H.wear_mask
		if(!I.obj_broken)
			return
	H.set_eye_blur_if_lower(4 SECONDS)
	H.apply_status_effect(/datum/status_effect/debuff/badvision)

/datum/quirk/vice/cyclops_right
	name = "Cyclops (R)"
	desc = "I lost my right eye long ago. But it made me great at noticing things."
	point_value = 2
	incompatible_quirks = list(
		/datum/quirk/boon/night_vision
	)

/datum/quirk/vice/cyclops_right/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(H.wear_mask)
		var/type = H.wear_mask.type
		QDEL_NULL(H.wear_mask)
		H.put_in_hands(new type(get_turf(H)))
	H.equip_to_slot_or_del(new /obj/item/clothing/face/eyepatch(H), ITEM_SLOT_MASK)
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	head?.add_wound(/datum/wound/facial/eyes/right/permanent)
	H.update_fov_angles()

/datum/quirk/vice/cyclops_left
	name = "Cyclops (L)"
	desc = "I lost my left eye long ago. But it made me great at noticing things."
	point_value = 2
	incompatible_quirks = list(
		/datum/quirk/boon/night_vision
	)

/datum/quirk/vice/cyclops_left/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	if(H.wear_mask)
		var/type = H.wear_mask.type
		QDEL_NULL(H.wear_mask)
		H.put_in_hands(new type(get_turf(H)))
	H.equip_to_slot_or_del(new /obj/item/clothing/face/eyepatch/left(H), ITEM_SLOT_MASK)
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	head?.add_wound(/datum/wound/facial/eyes/left/permanent)
	H.update_fov_angles()

/datum/quirk/vice/tongueless
	name = "Tongueless"
	desc = "I said one word too many to a noble, they cut out my tongue. (Being mute is not an excuse to forego roleplay. Use of custom emotes is recommended.)"
	point_value = 4

/datum/quirk/vice/tongueless/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	head?.add_wound(/datum/wound/facial/tongue/permanent)

/datum/quirk/vice/wooden_arm_right
	name = "Wooden Arm (R)"
	desc = "I lost my right arm long ago, but the wooden arm doesn't bleed as much."
	point_value = 3

/datum/quirk/vice/wooden_arm_right/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_R_ARM)
	if(O)
		O.drop_limb()
		qdel(O)
	var/obj/item/bodypart/r_arm/prosthetic/wood/L = new()
	L.attach_limb(H)

/datum/quirk/vice/wooden_arm_left
	name = "Wooden Arm (L)"
	desc = "I lost my left arm long ago, but the wooden arm doesn't bleed as much."
	point_value = 3

/datum/quirk/vice/wooden_arm_left/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	var/obj/item/bodypart/O = H.get_bodypart(BODY_ZONE_L_ARM)
	if(O)
		O.drop_limb()
		qdel(O)
	var/obj/item/bodypart/l_arm/prosthetic/wood/L = new()
	L.attach_limb(H)

/datum/quirk/vice/leprosy
	name = "Leprosy"
	desc = "Become a leper. You will be hated, you will be shunned, you will bleed and you will be weak."
	point_value = 8

/datum/quirk/vice/leprosy/on_spawn()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	ADD_TRAIT(H, TRAIT_LEPROSY, TRAIT_GENERIC)

	// Equip iron mask - remove existing mask if present
	if(H.wear_mask)
		var/type = H.wear_mask.type
		QDEL_NULL(H.wear_mask)
		H.put_in_hands(new type(get_turf(H)))

	H.equip_to_slot_or_del(new /obj/item/clothing/face/facemask(H), ITEM_SLOT_MASK)

/datum/quirk/vice/leprosy/on_remove()
	if(!ishuman(owner))
		return

	var/mob/living/carbon/human/H = owner

	// Remove traits when quirk is removed
	REMOVE_TRAIT(H, TRAIT_LEPROSY, TRAIT_GENERIC)
