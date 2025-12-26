
/datum/quirk/peculiarity
	abstract_type = /datum/quirk/peculiarity
	quirk_category = QUIRK_PECULIARITY
	point_value = 0

/datum/quirk/peculiarity/large_sized
	name = "Large Build"
	desc = "You're taller and broader than most. This makes you more imposing but also harder to miss."

/datum/quirk/peculiarity/large_sized/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(1.15, 1.15)
	H.update_transform()

/datum/quirk/peculiarity/large_sized/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(0.87, 0.87)
	H.update_transform()

/datum/quirk/peculiarity/small_sized
	name = "Small Build"
	desc = "You're smaller and more compact than most. This makes you less imposing but potentially harder to hit."

/datum/quirk/peculiarity/small_sized/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(0.9, 0.9)
	H.update_transform()

/datum/quirk/peculiarity/small_sized/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.transform = H.transform.Scale(1.11, 1.11)
	H.update_transform()


/datum/quirk/peculiarity/witless_pixie
	name = "Witless Pixie"
	desc = "By some cruel twist of fate, you have been born a dainty-minded, dim-witted klutz. Yours is a life of constant misdirection, confusion and general incompetence. It is no small blessing your dazzling looks make up for this, sometimes."

/datum/quirk/peculiarity/witless_pixie/on_spawn()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, rand(-2, -5))

	REMOVE_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
	REMOVE_TRAIT(H, TRAIT_UGLY, TRAIT_GENERIC)
	REMOVE_TRAIT(H, TRAIT_FISHFACE, TRAIT_GENERIC)

	if(prob(50))
		ADD_TRAIT(H, TRAIT_BEAUTIFUL, TRAIT_GENERIC)
	else if(prob(30))
		ADD_TRAIT(H, TRAIT_UGLY, TRAIT_GENERIC)

/datum/quirk/peculiarity/witless_pixie/on_remove()
	if(!ishuman(owner))
		return
	var/mob/living/carbon/human/H = owner
	// Remove stat penalty (inverse of what was applied)
	// This is approximate since we randomized on spawn
	H.adjust_stat_modifier(STATMOD_QUIRK, STATKEY_INT, 3)
