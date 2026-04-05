/obj/item/organ/heart
	name = "heart"
	desc = "Following your HEART shall be the whole of LAW."
	icon_state = "heart"
	zone = BODY_ZONE_CHEST
	organ_efficiency = list(ORGAN_SLOT_HEART = 100)
	w_class = WEIGHT_CLASS_SMALL
	low_threshold_passed = span_info("Prickles of pain appear then die out from within my chest...")
	high_threshold_passed = span_warning("Something inside my chest hurts, and the pain isn't subsiding. I am breathing far faster than before.")
	now_fixed = span_info("My heart begins to beat again.")
	high_threshold_cleared = span_info("The pain in my chest has died down, and my breathing becomes more relaxed.")
	organ_volume = 0.5
	max_blood_storage = 100
	current_blood = 100
	blood_req = 10
	oxygen_req = 5
	nutriment_req = 5
	hydration_req = 5
	/// Have we been bypassed to avoid nasty blockages?
	var/open = FALSE
	/// If we're not beating that is not a good sign
	var/beating = TRUE
	/// Whether we've already triggered the failing message this cycle, to avoid spam
	var/failed = FALSE
	///convulsion sounds
	var/convulsion_sound = list('sound/emotes/convulse1.wav', 'sound/emotes/convulse2.wav')

	/// Markings on this heart for the maniac antagonist.
	/// Assoc list using Maniac antag datums as keys. One for each maniac, but not for each wonder.
	var/inscryptions = list()
	/// Assoc list tracking antag datums to 4-letter maniac keys
	var/inscryption_keys = list()
	/// Assoc list tracking antag datums to wonder ID number (1-4)
	var/maniacs2wonder_ids = list()
	/// List of Maniac datums that have inscribed on this heart
	var/maniacs = list()

	var/graggometer = 0

	food_type = /obj/item/reagent_containers/food/snacks/meat/organ/heart

/obj/item/organ/heart/Initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 8 SECONDS)

/obj/item/organ/heart/examine(mob/user)
	. = ..()
	if(IsAdminGhost(user) && inscryptions)
		for(var/datum/antagonist/maniac/maniaque in maniacs)
			var/N = maniaque.owner?.name
			var/W = LAZYACCESS(maniacs2wonder_ids, maniaque)
			var/P = LAZYACCESS(inscryptions, maniaque)
			. += span_notice("Marked by [N ? "[N]'s " : ""]Wonder[W ? " #[W]" : ""]: [P].")
		return .
	var/datum/antagonist/maniac/dreamer = user.mind?.has_antag_datum(/datum/antagonist/maniac)
	if(dreamer)
		if(!maniacs)
			. += "<span class='danger'><b>There is NOTHING on this heart. \
				Should be? Following the TRUTH - not here. I need to keep LOOKING. Keep FOLLOWING my heart.</b></span>"
		else
			if(!(dreamer in maniacs))
				. += "<span class='danger'><b>This heart has INDECIPHERABLE etching. \
					Following the TRUTH - not here. I need to keep LOOKING. Keep FOLLOWING my heart.</b></span>"
				return .
			var/my_inscryption = LAZYACCESS(inscryptions, dreamer)
			. += "<b><span class='warning'>There's something CUT on this HEART.</span>\n\"[my_inscryption]. Add it to the other keys to exit INRL.\"</b>"
			if(!(my_inscryption in dreamer.hearts_seen))
				var/wonder_code = LAZYACCESS(maniacs2wonder_ids, dreamer)
				dreamer.hearts_seen += my_inscryption
				SEND_SOUND(dreamer, 'sound/villain/newheart.ogg')
				user.log_message("got the Maniac inscryption [wonder_code ? " for Wonder #[wonder_code]" : ""][my_inscryption ? ": \"[STRIP_HTML_SIMPLE(my_inscryption, MAX_MESSAGE_LEN)].\"" : ""]", LOG_GAME)
				if(wonder_code == 4)
					message_admins("Maniac [ADMIN_LOOKUPFLW(user)] has obtained the fourth and final heart code.")

/obj/item/organ/heart/is_working()
	if(owner)
		return (..() && beating)
	return ..()

/obj/item/organ/heart/is_failing()
	if(owner)
		return (..() || !beating)
	return ..()

/obj/item/organ/heart/Remove(mob/living/carbon/old_owner, special = FALSE)
	. = ..()
	if(!special)
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 12 SECONDS)

/obj/item/organ/heart/attack_self(mob/user)
	. = ..()
	if(!beating)
		user.visible_message(span_notice("[user] squeezes [src] to make it beat again!"), \
					span_notice("You squeeze [src] to make it beat again!"))
		Restart()
		addtimer(CALLBACK(src, PROC_REF(stop_if_unowned)), 8 SECONDS)

/obj/item/organ/heart/proc/can_stop()
	if(beating)
		return TRUE
	return FALSE

/obj/item/organ/heart/proc/stop_if_unowned()
	if(!owner)
		Stop()

/obj/item/organ/heart/proc/Stop()
	var/old_beating = beating
	beating = FALSE
	update_appearance()
	if(owner && old_beating)
		var/deathsdoor = TRUE
		for(var/thing in (owner.getorganslotlist(ORGAN_SLOT_HEART) - src))
			var/obj/item/organ/heart/heart = thing
			if(heart.beating)
				deathsdoor = FALSE
		if(deathsdoor)
			to_chat(owner, span_danger("I'm knocking on death's door!"))
	return TRUE

/obj/item/organ/heart/proc/Restart()
	var/old_beating = beating
	beating = TRUE
	update_appearance()
	if(owner && !old_beating)
		to_chat(owner, span_userdanger("My [name] beats again!"))
	return TRUE

/obj/item/organ/heart/get_availability(datum/species/S)
	return (!(NOBLOOD in S.species_traits) && !(TRAIT_STABLEHEART in S.inherent_traits))

////////////////////////////////////CURSED HEART////////////////////////////////////////

/obj/item/organ/heart/cursed
	name = "cursed heart"
	desc = ""
	icon_state = "cursedheart-off"
	actions_types = list(/datum/action/item_action/organ_action/cursed_heart)
	var/last_pump = 0
	var/add_colour = TRUE
	var/pump_delay = 30
	var/blood_loss = 100

	var/heal_brute = 0
	var/heal_burn = 0
	var/heal_oxy = 0

/obj/item/organ/heart/cursed/attack(mob/living/carbon/human/H, mob/living/carbon/human/user, list/modifiers)
	if(H == user && istype(H))
		playsound(user, 'sound/blank.ogg', 40, TRUE)
		user.temporarilyRemoveItemFromInventory(src, TRUE)
		Insert(user)
	else
		return ..()

// Cursed heart still uses on_life() since it is a special case not covered by the organ_process system.
/obj/item/organ/heart/cursed/on_life(delta_time, times_fired)
	. = ..()
	if(world.time > (last_pump + pump_delay))
		if(ishuman(owner) && owner.client)
			var/mob/living/carbon/human/H = owner
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = max(H.blood_volume - blood_loss, 0)
				to_chat(H, "<span class='danger'>I have to keep pumping my blood!</span>")
				if(add_colour)
					H.add_client_colour(/datum/client_colour/cursed_heart_blood)
					add_colour = FALSE
		else
			last_pump = world.time

/obj/item/organ/heart/cursed/Insert(mob/living/carbon/M, special = 0, new_zone = null)
	..()
	if(owner)
		to_chat(owner, "<span class='danger'>My heart has been replaced with a cursed one, you have to pump this one manually otherwise you'll die!</span>")

/obj/item/organ/heart/cursed/Remove(mob/living/carbon/M, special = 0)
	..()
	M.remove_client_colour(/datum/client_colour/cursed_heart_blood)

/datum/action/item_action/organ_action/cursed_heart
	name = "Pump my blood"

/datum/action/item_action/organ_action/cursed_heart/Trigger(trigger_flags)
	. = ..()
	if(. && istype(target, /obj/item/organ/heart/cursed))
		var/obj/item/organ/heart/cursed/cursed_heart = target

		if(world.time < (cursed_heart.last_pump + (cursed_heart.pump_delay - 10)))
			to_chat(owner, "<span class='danger'>Too soon!</span>")
			return

		cursed_heart.last_pump = world.time
		playsound(owner, 'sound/blank.ogg', 40, TRUE)
		to_chat(owner, "<span class='notice'>My heart beats.</span>")

		var/mob/living/carbon/human/H = owner
		if(istype(H))
			if(H.dna && !(NOBLOOD in H.dna.species.species_traits))
				H.blood_volume = min(H.blood_volume + cursed_heart.blood_loss * 0.5, BLOOD_VOLUME_MAXIMUM)
				H.remove_client_colour(/datum/client_colour/cursed_heart_blood)
				cursed_heart.add_colour = TRUE
				H.adjustBruteLoss(-cursed_heart.heal_brute)
				H.adjustFireLoss(-cursed_heart.heal_burn)
				H.adjustOxyLoss(-cursed_heart.heal_oxy)

/datum/client_colour/cursed_heart_blood
	priority = 100
	colour = "red"
