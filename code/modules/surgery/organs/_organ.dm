/obj/item/organ
	name = "organ"
	icon = 'icons/obj/surgery.dmi'
	var/mob/living/carbon/owner = null
	var/status = ORGAN_ORGANIC
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	sellprice = 10

	grid_width = 32
	grid_height = 32

	/// Time we have spent failing
	var/failure_time = 0
	var/zone = BODY_ZONE_CHEST
	/// Body zone we are currently occupying
	var/current_zone = null
	/// Body zones we can be inserted on
	var/list/possible_zones = ALL_BODYPARTS
	var/slot
	// DO NOT add slots with matching names to different zones - it will break internal_organs_slot list!
	var/organ_flags = 0

	/// Damage healed per second
	var/healing_factor = STANDARD_ORGAN_HEALING
	/// Minimum amount of germ_level we gain when rotting
	var/min_decay_factor = MIN_ORGAN_DECAY_INFECTION
	/// Maximum amount of germ_level we gain when rotting
	var/max_decay_factor = MAX_ORGAN_DECAY_INFECTION
	/// Maximum amount of damage we can suffer
	var/maxHealth = STANDARD_ORGAN_THRESHOLD
	/// Total damage this organ has sustained
	var/damage = 0
	/// How much pain this causes in relation to damage (pain_multiplier * damage)
	var/pain_multiplier = 0.75
	/// Modifier for when the parent limb gets damaged, and fucks up the organs inside
	var/internal_damage_modifier = 1
	/// Flat reduction of the damage when the limb gets damaged and fucks us up
	var/internal_damage_reduction = 0
	/// When severe organ damage (broken) occurs
	var/high_threshold = STANDARD_ORGAN_THRESHOLD * 0.8
	/// When medium organ damage occurs (only matters for bones at the moment)
	var/medium_threshold = STANDARD_ORGAN_THRESHOLD * 0.5
	/// When minor organ damage (bruising) occurs
	var/low_threshold = STANDARD_ORGAN_THRESHOLD * 0.2
	/// Cooldown for severe effects, used for synthetic organ emp effects.
	COOLDOWN_DECLARE(severe_cooldown)

	var/prev_damage = 0

	/// Just passed bruise threshold
	var/low_threshold_passed
	/// Just passed medium threshold
	var/medium_threshold_passed
	/// Just passed the broken treshold
	var/high_threshold_passed
	/// Organ is failing
	var/now_failing
	/// Organ has been fixed from failing
	var/now_fixed
	/// Organ has been fixed below broken
	var/high_threshold_cleared
	/// Organ has been fixed below medium
	var/medium_threshold_cleared
	/// Organ has been fixed below bruised
	var/low_threshold_cleared
	dropshrink = 0.85

	/// What food typepath should be used when eaten
	var/food_type = /obj/item/reagent_containers/food/snacks/meat/organ
	/// Original owner of the organ, the one who had it inside them last
	var/mob/living/carbon/last_owner = null

	/// Needs to get processed on next life() tick
	var/needs_processing = TRUE

	/// Efficiency attached to each slot
	var/list/organ_efficiency = list()
	///this is just an easy to access list of modification sources going slot = list(type = val)
	var/list/organ_efficiency_modification

	/// How much blood (percent of BLOOD_VOLUME_NORMAL) an organ takes to funcion
	var/blood_req = 0
	/// If oxygen reqs are not satisfied, get debuffs and brain starts taking damage
	var/oxygen_req = 0
	/// Controls passive nutriment loss
	var/nutriment_req = 0
	/// Controls passive hydration loss
	var/hydration_req = 0

	/// The space we occupy inside a limb - unaffected by w_class for balance reasons
	var/organ_volume = 0
	/// How much blood an organ can store - Base is 5 * blood_req, so the organ can survive without blood for 10 seconds before taking damage (+ blood supply of arteries)
	var/max_blood_storage = 0
	/// How much blood is currently in the organ
	var/current_blood = 0

	/// Types of items that can stitch this organ when severed
	var/list/attaching_items = list(/obj/item/needle)
	/// If this is set, this organ can be healed with item types in this list
	var/list/healing_items
	/// The above, but for tool behaviors
	var/list/healing_tools = list(TOOL_SUTURE)

/obj/item/organ/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	current_zone = zone
	if(use_mob_sprite_as_obj_sprite)
		update_appearance(UPDATE_OVERLAYS)

/obj/item/organ/Destroy()
	if(owner)
		Remove(owner, special=TRUE)
	last_owner = null
	STOP_PROCESSING(SSobj, src)
	LAZYNULL(organ_efficiency_modification)
	return ..()

/obj/item/organ/attack(mob/living/carbon/M, mob/user, list/modifiers)
	if(M == user && ishuman(user))
		var/mob/living/carbon/human/H = user
		if(status == ORGAN_ORGANIC)
			var/obj/item/reagent_containers/food/snacks/S = prepare_eat(H)
			if(S && H.put_in_active_hand(S))
				S.attack(H, H)
	else
		..()

/obj/item/organ/item_action_slot_check(slot,mob/user)
	return //so we don't grant the organ's action to mobs who pick up the organ.


/obj/item/organ/proc/apply_efficiency_modification(value, slot, source)
	organ_efficiency[slot] += value
	LAZYADDASSOC(organ_efficiency_modification, source, value)
	update_organ_efficiency(slot)

/obj/item/organ/proc/remove_efficiency_modification(slot, source)
	var/value = organ_efficiency_modification["[source]"]
	organ_efficiency[slot] -= value
	LAZYREMOVE(organ_efficiency_modification, source)
	update_organ_efficiency(slot)

/obj/item/organ/proc/update_organ_efficiency(slot)
	return

/obj/item/organ/proc/is_working()
	return (!CHECK_BITFIELD(organ_flags, ORGAN_FAILING|ORGAN_DESTROYED|ORGAN_DEAD|ORGAN_CUT_AWAY) && (damage < high_threshold) && (current_blood || !max_blood_storage))

/obj/item/organ/proc/is_working_without_bleedout()
	return (!CHECK_BITFIELD(organ_flags, ORGAN_FAILING|ORGAN_DESTROYED|ORGAN_DEAD|ORGAN_CUT_AWAY) && (damage < high_threshold))

/obj/item/organ/proc/is_failing()
	return (CHECK_BITFIELD(organ_flags, ORGAN_FAILING|ORGAN_DESTROYED|ORGAN_DEAD|ORGAN_CUT_AWAY) || (damage >= high_threshold) || (!current_blood && max_blood_storage))

/obj/item/organ/proc/is_failing_without_bleedout()
	return (CHECK_BITFIELD(organ_flags, ORGAN_FAILING|ORGAN_DESTROYED|ORGAN_DEAD|ORGAN_CUT_AWAY) || (damage >= high_threshold))

/obj/item/organ/proc/is_dead()
	return (CHECK_BITFIELD(organ_flags, ORGAN_DESTROYED|ORGAN_DEAD) || (damage >= maxHealth))

/obj/item/organ/proc/is_bruised()
	return (damage >= low_threshold)

/obj/item/organ/proc/is_broken()
	return (CHECK_BITFIELD(organ_flags, ORGAN_FAILING) || (damage >= high_threshold))

/obj/item/organ/proc/is_destroyed()
	return (CHECK_BITFIELD(organ_flags, ORGAN_DESTROYED))

/obj/item/organ/proc/is_necrotic()
	return (CHECK_BITFIELD(organ_flags, ORGAN_DEAD) || (germ_level >= INFECTION_LEVEL_THREE))

/obj/item/organ/proc/handle_blood(delta_time, times_fired)
	var/arterial_efficiency = get_slot_efficiency(slot) //cute placeholder value
	var/in_bleedout = owner.in_bleedout()
	if(arterial_efficiency && !is_failing() && !in_bleedout)
		// Arteries get an extra flat 5 blood regen
		current_blood = min(current_blood + 5 * (0.5 * delta_time) * (arterial_efficiency/ORGAN_OPTIMAL_EFFICIENCY), max_blood_storage)
		return
	if(!blood_req)
		return
	if(!in_bleedout)
		current_blood = min(current_blood + (blood_req * (0.5 * delta_time)), max_blood_storage)
		return
	current_blood = max(current_blood - (blood_req * (0.5 * delta_time)), 0)
	// When all blood is lost, take blood from blood vessels placeholdered since not yet
	if(!current_blood)
		var/blood_drawn = min(blood_req * 0.5 * delta_time, owner.blood_volume)
		if(owner.blood_volume >= BLOOD_VOLUME_OKAY)
			owner.adjust_bloodpool(-blood_drawn)
			current_blood = min(current_blood + blood_drawn, max_blood_storage)
			current_blood = max(current_blood - (blood_req * delta_time), 0)
		if((current_blood <= 0))
			applyOrganDamage(2 * delta_time)

/obj/item/organ/proc/generate_chimeric_organ(mob/living/source_mob)
	if(!source_mob)
		return
	var/datum/component/chimeric_organ/organ = AddComponent(/datum/component/chimeric_organ, 3)
	var/node_count = rand(3, 5)
	var/list/obj/item/chimeric_node/generated_nodes = list()

	for(var/i in 1 to node_count)
		var/obj/item/chimeric_node/new_node = source_mob.generate_chimeric_node_from_mob()
		if(!new_node)
			continue

		if(!organ.check_node_compatibility(new_node.stored_node))
			qdel(new_node)
			continue

		generated_nodes += new_node

	if(!length(generated_nodes))
		return

	for(var/obj/item/chimeric_node/node as anything in generated_nodes)
		organ.handle_node_injection(node.node_tier, node.node_purity, node.stored_node.slot, node.stored_node, node.icon_state)
		node.forceMove(src)

	update_appearance(UPDATE_OVERLAYS)
	return TRUE

/obj/item/organ/update_overlays()
	. = ..()
	var/datum/component/chimeric_organ/organ = GetComponent(/datum/component/chimeric_organ)

	if(!organ)
		return

	for(var/mutable_appearance/node_overlay in organ.overlay_states)
		. += node_overlay

/obj/item/organ/proc/Insert(mob/living/carbon/M, special = 0, drop_if_replaced = TRUE, new_zone = null)
	if(!iscarbon(M) || owner == M)
		return

	if(!isnull(new_zone))
		current_zone = new_zone
	else
		current_zone = zone

	var/obj/item/organ/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)
		if(drop_if_replaced)
			replaced.forceMove(get_turf(M))
		else
			qdel(replaced)

	SEND_SIGNAL(src, COMSIG_ORGAN_INSERTED, M)
	owner = M
	last_owner = M
	M.internal_organs |= src
	for(var/slot in organ_efficiency)
		LAZYADD(M.internal_organs_slot[slot], src)
		update_organ_efficiency(slot)
	moveToNullspace()
	for(var/datum/action/A as anything in actions)
		A.Grant(M)
	update_accessory_colors()
	STOP_PROCESSING(SSobj, src)

//Special is for instant replacement like autosurgeons
/obj/item/organ/proc/Remove(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	SEND_SIGNAL(src, COMSIG_ORGAN_REMOVED, M)
	owner = null
	if(M)
		M.internal_organs -= src
		for(var/slot in organ_efficiency)
			LAZYREMOVE(M.internal_organs_slot[slot], src)
		if((organ_flags & ORGAN_VITAL) && !special && !(M.status_flags & GODMODE))
			M.death()
	for(var/datum/action/A as anything in actions)
		A.Remove(M)
	if(visible_organ)
		M.update_body_parts(TRUE)
	update_appearance(UPDATE_ICON_STATE)

/obj/item/organ/proc/on_find(mob/living/finder)
	return

/// Runs decay when outside of a person
/obj/item/organ/process(delta_time, times_fired)
	// Kinda hate doing it like this, but I really don't want to call process directly.
	return on_death(delta_time, times_fired)

/// proper decaying
/obj/item/organ/proc/decay(delta_time)
	adjust_germ_level(rand(min_decay_factor,max_decay_factor) * delta_time)

/obj/item/organ/adjust_germ_level(add_germs, minimum_germs = 0, maximum_germs = GERM_LEVEL_MAXIMUM)
	. = ..()
	if((germ_level >= INFECTION_LEVEL_THREE) && !CHECK_BITFIELD(organ_flags, ORGAN_DEAD))
		kill_organ()

/obj/item/organ/proc/kill_organ()
	. = FALSE
	if(damage < maxHealth && !CHECK_BITFIELD(organ_flags, ORGAN_DESTROYED))
		setOrganDamage(maxHealth)
		return TRUE

/// Runs decay both inside and outside a person
/obj/item/organ/proc/on_death(delta_time, times_fired)
	check_cold()
	if(!owner && !isbodypart(loc))
		organ_flags |= ORGAN_CUT_AWAY
	if(can_decay())
		decay(delta_time)
	else
		STOP_PROCESSING(SSobj, src)

/// Infection/rot checks
/obj/item/organ/proc/can_decay()
	check_cold()
	if(CHECK_BITFIELD(organ_flags, ORGAN_FROZEN|ORGAN_DEAD|ORGAN_SYNTHETIC))
		return FALSE
	return TRUE

// Checks to see if the organ is frozen from temperature and adds the ORGAN_FROZEN flag if so
/obj/item/organ/proc/check_cold()
	var/local_temp
	if(!owner)
		//Only concern is adding an organ to a freezer when the area around it is cold.
		if(isturf(loc))
			var/turf/turf_loc = loc
			local_temp = turf_loc?.return_temperature()
		else if(ismob(loc))
			var/mob/holder = loc
			var/turf/turf_loc = holder.loc
			local_temp = turf_loc?.return_temperature()
	else
		local_temp = owner.bodytemperature

	// Shouldn't happen but just in case
	if(isnull(local_temp))
		return (organ_flags & ORGAN_FROZEN)
	//you get some leeway...
	if(local_temp < 15)
		organ_flags |= ORGAN_FROZEN
		return (organ_flags & ORGAN_FROZEN)

	organ_flags &= ~ORGAN_FROZEN
	return (organ_flags & ORGAN_FROZEN)

/obj/item/organ/proc/on_life(delta_time, times_fired)	//repair organ damage if the organ is not failing
	SHOULD_CALL_PARENT(TRUE)
	if(!owner)
		return

	/// Handle blood
	handle_blood(delta_time, times_fired)

	if(is_failing())
		handle_failing_organ(delta_time, times_fired)
		return

	// Decrease failure time while healthy
	if(failure_time > 0)
		failure_time = max(0, failure_time - delta_time)

	// Damage decrements by a percent of maxhealth
	if(can_heal(delta_time, times_fired) && damage)
		handle_healing(delta_time, times_fired)

///Organs don't die instantly, and neither should you when you get fucked up
/obj/item/organ/proc/handle_failing_organ(delta_time, times_fired)
	if(!owner || owner.stat >= DEAD)
		return

	failure_time += delta_time
	organ_failure(delta_time)


/// healing checks
/obj/item/organ/proc/can_heal(delta_time, times_fired)
	. = TRUE
	if(!owner)
		return FALSE
	if(healing_factor <= 0)
		return FALSE
	if((damage > maxHealth/5) && !owner.get_chem_effect(CE_ORGAN_REGEN))
		return FALSE
	if(is_dead())
		return FALSE
	if(current_blood <= 0)
		return FALSE
	if(owner.undergoing_cardiac_arrest())
		return FALSE
	if(owner.get_chem_effect(CE_TOXIN))
		return FALSE

/obj/item/organ/proc/handle_healing(delta_time, times_fired)
	if(damage <= 0)
		return
	applyOrganDamage(-healing_factor * delta_time, damage)
	//this doesn't seem very right at all...
	owner.adjust_nutrition(-nutriment_req/100 * (0.5 * delta_time))
	owner.adjust_hydration(-hydration_req/100 * (0.5 * delta_time))

/** organ_failure
 * generic proc for handling dying organs
 *
 * Arguments:
 * delta_time - seconds since last tick
 */
/obj/item/organ/proc/organ_failure(delta_time)
	return

/obj/item/organ/examine(mob/user)
	. = ..()

	. += span_notice("It should be inserted in the [parse_zone(zone)].")

	if(organ_flags & ORGAN_FAILING)
		if(status == ORGAN_ROBOTIC)
			. += span_warning("[src] seems to be broken.")
			return
		. += span_warning("[src] has decayed for too long, and has turned a sickly color. Only Pestra herself could restore it its functionality.")
		return
	if(damage > high_threshold)
		. += span_warning("[src] is starting to look discolored.")

/obj/item/organ/proc/prepare_eat(mob/living/carbon/human/user)
	var/obj/item/reagent_containers/food/snacks/meat/organ/S = new food_type()
	S.name = name
	S.desc = desc
	S.icon = icon
	S.icon_state = icon_state
	S.w_class = w_class
	S.organ_inside = src
	forceMove(S)
	if(damage > high_threshold)
		S.eat_effect = /datum/status_effect/debuff/rotfood
	S.rotprocess = S.rotprocess * ((high_threshold - damage) / high_threshold)
	return S


/**
 * returns the efficiency for a specific organ slot
 *
 * Arguments:
 * slot - Slot we want to get the efficiency from
 */
/obj/item/organ/proc/get_slot_efficiency(slot)
	var/effective_efficiency = LAZYACCESS(organ_efficiency, slot)
	if(isnull(effective_efficiency))
		return effective_efficiency
	/*
	if(is_failing())
		return 0
	*/
	effective_efficiency = max(0, CEILING(effective_efficiency - (effective_efficiency * (damage/maxHealth)), 1))
	return effective_efficiency

///Adjusts an organ's damage by the amount "d", up to a maximum amount, which is by default max damage
/obj/item/organ/proc/applyOrganDamage(d, maximum = maxHealth)	//use for damaging effects
	if(!d) //Micro-optimization.
		return
	if(maximum < damage)
		return
	damage = CLAMP(damage + d, 0, maximum)
//	var/mess = check_damage_thresholds(owner)
	prev_damage = damage
//	if(mess && owner)
//		to_chat(owner, mess)

///SETS an organ's damage to the amount "d", and in doing so clears or sets the failing flag, good for when you have an effect that should fix an organ if broken
/obj/item/organ/proc/setOrganDamage(d)	//use mostly for admin heals
	applyOrganDamage(d - damage)

/** check_damage_thresholds
 * input: holder (a mob, the owner of the organ we call the proc on)
 * output: returns a message should get displayed.
 * description: By checking our current damage against our previous damage, we can decide whether we've passed an organ threshold.
 *  If we have, send the corresponding threshold message to the owner, if such a message exists.
 */
/obj/item/organ/proc/check_damage_thresholds(mob/living/carbon/holder)
	if(damage == prev_damage)
		return
	var/delta = damage - prev_damage
	if(delta > 0)
		if(damage >= maxHealth && prev_damage < maxHealth)
			organ_flags |= ORGAN_FAILING
			organ_flags |= ORGAN_DESTROYED
			return now_failing
		if(damage >= high_threshold && prev_damage < high_threshold)
			organ_flags |= ORGAN_FAILING
			return high_threshold_passed
		if(damage >= medium_threshold && prev_damage < medium_threshold)
			return medium_threshold_passed
		if(damage >= low_threshold && prev_damage < low_threshold)
			return low_threshold_passed
	if(delta < 0)
		if(prev_damage >= low_threshold && damage < low_threshold)
			organ_flags &= ~ORGAN_FAILING
			return low_threshold_cleared
		if(prev_damage >= medium_threshold && damage < medium_threshold)
			organ_flags &= ~ORGAN_FAILING
			return medium_threshold_cleared
		if(prev_damage >= high_threshold && damage < high_threshold)
			organ_flags &= ~ORGAN_FAILING
			return high_threshold_cleared
		if(prev_damage >= maxHealth && damage < maxHealth)
			return now_fixed

/obj/item/organ/on_enter_storage(datum/component/storage/concrete/S)
	. = ..()
	if(recursive_loc_check(src, /obj/item/storage/backpack/backpack/artibackpack))
		organ_flags |= ORGAN_FROZEN

/obj/item/organ/on_exit_storage(datum/component/storage/concrete/S)
	. = ..()
	if(!recursive_loc_check(src, /obj/item/storage/backpack/backpack/artibackpack))
		organ_flags &= ~ORGAN_FROZEN

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm

/mob/living/proc/regenerate_organs()
	return 0

/mob/living/carbon/regenerate_organs()
	if(dna?.species)
		dna.species.regenerate_organs(src)

		// Species regenerate organs doesn't ALWAYS handle healing the organs because it's dumb
		for(var/obj/item/organ/organ as anything in internal_organs)
			organ.setOrganDamage(0)
		set_heartattack(FALSE)

		// heal ears after healing traits, since ears check TRAIT_DEAF trait
		// when healing.
		restoreEars()

		return

	// Default organ fixing handling
	// May result in kinda cursed stuff for mobs which don't need these organs
	var/obj/item/organ/lungs/lungs = getorganslot(ORGAN_SLOT_LUNGS)
	if(!lungs)
		lungs = new()
		lungs.Insert(src)
	lungs.setOrganDamage(0)

	var/obj/item/organ/heart/heart = getorganslot(ORGAN_SLOT_HEART)
	if(heart)
		set_heartattack(FALSE)
	else
		heart = new()
		heart.Insert(src)
	heart.setOrganDamage(0)

	var/obj/item/organ/tongue/tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(!tongue)
		tongue = new()
		tongue.Insert(src)
	tongue.setOrganDamage(0)

	var/obj/item/organ/eyes/eyes = getorganslot(ORGAN_SLOT_EYES)
	if(!eyes)
		eyes = new()
		eyes.Insert(src)
	eyes.setOrganDamage(0)

	var/obj/item/organ/ears/ears = getorganslot(ORGAN_SLOT_EARS)
	if(!ears)
		ears = new()
		ears.Insert(src)
	// ears.adjustEarDamage(-INFINITY, -INFINITY) // actually do: set_organ_damage(0) and deaf = 0

	// heal ears after healing traits, since ears check TRAIT_DEAF trait
	// when healing.
	restoreEars()

GLOBAL_LIST_INIT(all_organ_slots, get_all_slots())

/// Get all possible organ slots by checking every organ, and then store it and give it whenever needed
/proc/get_all_slots()
	var/list/all_organ_slots = list()

	if(!length(all_organ_slots))
		for(var/obj/item/organ/an_organ as anything in subtypesof(/obj/item/organ))
			if(!initial(an_organ.slot))
				continue
			all_organ_slots |= initial(an_organ.slot)

	return all_organ_slots
