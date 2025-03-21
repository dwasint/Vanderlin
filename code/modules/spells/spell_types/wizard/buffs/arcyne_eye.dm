/obj/effect/proc_holder/spell/self/arcyne_eye
	name = "Arcyne Eye"
	desc = "Tap into the arcyne and see the leylines."
	clothes_req = FALSE
	active = FALSE
	releasedrain = 30
	chargedrain = 1
	chargetime = 0
	charge_max = 10 SECONDS
	warnie = "spellwarning"
	no_early_release = TRUE
	movement_interrupt = TRUE
	chargedloop = /datum/looping_sound/invokegen
	associated_skill = /datum/skill/magic/arcane
	attunements = list(
		/datum/attunement/arcyne = 0.1
		)
	cost = 1
	overlay_state = "transfix"

/obj/effect/proc_holder/spell/self/arcyne_eye/cast(list/targets, mob/living/user)
	playsound(get_turf(user), 'sound/vo/smokedrag.ogg', 100, TRUE)
	user.apply_status_effect(/datum/status_effect/arcyne_eye)
	return TRUE

/datum/status_effect/arcyne_eye
	duration = 1 MINUTES
	alert_type = null

/datum/status_effect/arcyne_eye/on_apply()
	ADD_TRAIT(owner, TRAIT_SEE_LEYLINES, type)
	owner.hud_used?.plane_masters_update()
	return TRUE

/datum/status_effect/arcyne_eye/on_remove()
	REMOVE_TRAIT(owner, TRAIT_SEE_LEYLINES, type)
	owner.hud_used?.plane_masters_update()
