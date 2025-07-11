GLOBAL_LIST_EMPTY(vampire_objects)

/datum/antagonist/vampire
	name = "Vampire"
	roundend_category = "Vampires"
	antagpanel_category = "Vampire"
	job_rank = ROLE_VAMPIRE
	antag_hud_type = ANTAG_HUD_VAMPIRE
	antag_hud_name = "vamp"
	confess_lines = list(
		"I WANT YOUR BLOOD!",
		"DRINK THE BLOOD!",
		"CHILD OF KAIN!",
	)

	var/datum/clan/default_clan = /datum/clan/nosferatu

/datum/antagonist/vampire/New(incoming_clan = /datum/clan/nosferatu)
	. = ..()
	default_clan = incoming_clan

/datum/antagonist/vampire/examine_friendorfoe(datum/antagonist/examined_datum, mob/examiner, mob/examined)
	if(istype(examined_datum, /datum/antagonist/vampire/lord))
		return span_boldnotice("Kaine's firstborn!")
	if(istype(examined_datum, /datum/antagonist/vampire))
		return span_boldnotice("A child of Kaine.")
	if(istype(examined_datum, /datum/antagonist/zombie))
		return span_boldnotice("Another deadite.")
	if(istype(examined_datum, /datum/antagonist/skeleton))
		return span_boldnotice("Another deadite.")

/datum/antagonist/vampire/on_gain()
	SSmapping.retainer.vampires |= owner
	move_to_spawnpoint()
	owner.special_role = name

	if(ishuman(owner.current))
		var/mob/living/carbon/human/vampdude = owner.current
		vampdude.adv_hugboxing_cancel()

		// Apply the clan - this handles most of the vampire setup now
		vampdude.set_clan(default_clan)

	// The clan system now handles most of the setup, but we can still do antagonist-specific things
	after_gain()
	. = ..()
	equip()

/datum/antagonist/vampire/on_removal()
	. = ..()
	owner.current.remove_spells(source = src)

/datum/antagonist/vampire/lord/on_gain()
	. = ..()
	owner.special_role = span_redtext("[name]")
	owner.current.mana_pool.ethereal_recharge_rate += 0.2

/datum/antagonist/vampire/lord/on_removal()
	owner.current.mana_pool.ethereal_recharge_rate -= 0.2
	return ..()

/datum/antagonist/vampire/proc/after_gain()
	return


/datum/antagonist/vampire/on_removal()
	if(ishuman(owner.current))
		var/mob/living/carbon/human/vampdude = owner.current
		// Remove the clan when losing antagonist status
		vampdude.set_clan(null)

	if(!silent && owner.current)
		to_chat(owner.current, span_danger("I am no longer a [job_rank]!"))
	owner.special_role = null
	return ..()

/datum/antagonist/vampire/proc/equip()
	return

/obj/structure/vampire
	icon = 'icons/roguetown/topadd/death/vamp-lord.dmi'
	density = TRUE

/obj/structure/vampire/Initialize()
	GLOB.vampire_objects |= src
	. = ..()

/obj/structure/vampire/Destroy()
	GLOB.vampire_objects -= src
	return ..()

// LANDMARKS

/obj/effect/landmark/start/vampirelord
	name = "Vampire Lord"
	icon_state = "arrow"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/vampirelord/Initialize()
	. = ..()
	GLOB.vlord_starts += loc

/obj/effect/landmark/start/vampirespawn
	name = "Vampire Spawn"
	icon_state = "arrow"
	delete_after_roundstart = FALSE

/obj/effect/landmark/start/vampirespawn/Initialize()
	. = ..()
	GLOB.vspawn_starts += loc

/obj/effect/landmark/start/vampireknight
	name = "Death Knight"
	icon_state = "arrow"
	jobspawn_override = list("Death Knight")
	delete_after_roundstart = FALSE

/obj/effect/landmark/vteleport
	name = "Teleport Destination"
	icon_state = "x2"

/obj/effect/landmark/vteleportsending
	name = "Teleport Sending"
	icon_state = "x2"

/obj/effect/landmark/vteleportdestination
	name = "Return Destination"
	icon_state = "x2"
	var/amuletname

/obj/effect/landmark/vteleportsenddest
	name = "Sending Destination"
	icon_state = "x2"
