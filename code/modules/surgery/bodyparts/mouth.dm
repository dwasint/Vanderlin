/// Teeth stack object, used by the jaw limb to do teeth stuff
/obj/item/natural/bundle/teeth
	name = "pile of teeth"
	desc = "A digusting pile of bleeding teeth."
	icon = 'icons/obj/surgery.dmi'
	stackname = "teeth"
	bundle_verb = "pile"
	icon_state = "tooth1"
	icon1 = "tooth1"
	icon1step = 5
	icon2 = "tooth2"
	icon2step = 10
	w_class = WEIGHT_CLASS_TINY
	maxamount = 32
	stacktype = /obj/item/natural/teeth
	items_per_increase = 16
	item_flags = SURGICAL_TOOL

/obj/item/natural/teeth
	name = "tooth"
	desc = "A tooth."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tooth_4"
	base_icon_state = "tooth"
	throwforce = 0
	force = 0
	item_flags = SURGICAL_TOOL
	bundletype = /obj/item/natural/bundle/teeth
	var/icon_state_variation = 4
	var/fang_bonus = 0

/obj/item/natural/teeth/Initialize(mapload, new_amount, merge)
	. = ..()
	if(icon_state_variation >= 1)
		icon_state = "[base_icon_state]_[rand(1, icon_state_variation)]"

/obj/item/natural/bundle/teeth/gold
	name = "pile of gold teeth"
	desc = "A digusting pile of bleeding gold teeth."
	icon = 'icons/obj/surgery.dmi'
	stackname = "teeth"
	bundle_verb = "pile"
	icon_state = "tooth1"
	icon1 = "tooth1"
	icon1step = 5
	icon2 = "tooth2"
	icon2step = 10
	w_class = WEIGHT_CLASS_TINY
	maxamount = 32
	stacktype = /obj/item/natural/teeth/gold
	color = COLOR_ASSEMBLY_GOLD

/obj/item/natural/teeth/gold
	name = "gold tooth"
	desc = "A golden tooth."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "tooth_4"
	base_icon_state = "tooth"
	throwforce = 0
	force = 0
	color = COLOR_ASSEMBLY_GOLD
	bundletype = /obj/item/natural/bundle/teeth/gold
	melting_material = /datum/material/gold
	melt_amount = 10

/obj/item/natural/bundle/teeth/fang
	name = "pile of fangs"
	desc = "A digusting pile of bleeding fangs."
	icon = 'icons/obj/surgery.dmi'
	stackname = "fangs"
	bundle_verb = "pile"
	icon_state = "fang1"
	icon1 = "fang1"
	icon1step = 5
	icon2 = "fang2"
	icon2step = 10
	w_class = WEIGHT_CLASS_TINY
	maxamount = 32
	stacktype = /obj/item/natural/teeth/fang

/obj/item/natural/teeth/fang
	name = "fang"
	desc = "A bloody fang."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "fang_1"
	base_icon_state = "fang"
	icon_state_variation = 1
	throwforce = DAMAGE_DAGGER + 13
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 30, "embedded_fall_chance" = 20)
	force = 10
	bundletype = /obj/item/natural/bundle/teeth/fang
	fang_bonus = 0.25


/obj/item/natural/teeth/proc/do_knock_out_animation(shrink_time = 5)
	var/old_transform = matrix(transform)
	transform = transform.Scale(2, 2)
	transform = transform.Turn(rand(0, 360))
	animate(src, transform = old_transform, time = shrink_time)

/obj/item/bodypart/mouth
	name = "jaw"
	desc = "I have no mouth and i must scream."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "jaw"
	base_icon_state = "jaw"
	body_zone = BODY_ZONE_PRECISE_MOUTH
	body_part = MOUTH
	max_damage = 50
	max_teeth = 32
	should_render = TRUE

/obj/item/bodypart/mouth/Initialize(mapload)
	. = ..()
	fill_teeth()

/obj/item/bodypart/mouth/proc/replace_teeth(teeth_type)
    if(teeth)
        for(var/obj/item/natural/bundle/teeth/bundle in teeth)
            qdel(bundle)
        teeth = null

    var/obj/item/natural/bundle/teeth/new_bundle = new teeth_type(null)
    new_bundle.amount = max_teeth
    teeth = list(new_bundle)
    update_teeth()

/obj/item/bodypart/mouth/get_limb_icon(dropped, hideaux = FALSE)
	if(dropped && !isbodypart(loc))
		. = list()
		var/image/jaw_image = image('icons/mob/human_parts.dmi', src, base_icon_state, BELOW_MOB_LAYER)
		jaw_image.plane = plane
		. += jaw_image
		return
	return ..()

/obj/item/bodypart/mouth/get_teeth_amount()
	var/count = 0
	if(teeth)
		for(var/obj/item/natural/bundle/teeth/bundle in teeth)
			count += bundle.amount
	return count


/obj/item/bodypart/mouth/update_teeth()
	if(teeth_mod)
		teeth_mod.update_lisp()
	else
		if(get_teeth_amount() < max_teeth)
			teeth_mod = new()
			if(owner)
				teeth_mod.add_speech_modifier(owner)
	update_limb_efficiency()
	return TRUE


/obj/item/bodypart/mouth/knock_out_teeth(amount = 1, throw_dir = NONE, throw_range = -1)
	if(SSticker.current_state < GAME_STATE_PLAYING)
		return
	var/total = get_teeth_amount()
	if(!amount || !total)
		return
	amount = clamp(amount, 0, total)
	var/dropped = 0
	var/turf/T = get_turf(owner)

	for(var/i in 1 to amount)
		total = get_teeth_amount()
		if(!total)
			break
		// Build weighted list from bundles
		var/list/weighted = list()
		for(var/obj/item/natural/bundle/teeth/bundle in teeth)
			if(bundle.amount > 0)
				weighted[bundle] = bundle.amount
		var/obj/item/natural/bundle/teeth/chosen = pickweight(weighted)
		chosen.amount--
		if(!chosen.amount)
			teeth -= chosen
			qdel(chosen)
		var/obj/item/natural/teeth/tooth = new chosen.stacktype(T)
		var/final_throw_dir = throw_dir == NONE ? pick(GLOB.alldirs) : throw_dir
		var/final_throw_range = throw_range == -1 ? rand(1, 2) : throw_range
		var/turf/target_turf = get_ranged_target_turf(T, final_throw_dir, final_throw_range)
		INVOKE_ASYNC(tooth, TYPE_PROC_REF(/atom/movable, throw_at), target_turf, final_throw_range, rand(1,3))
		dropped++

	if(!dropped)
		return

	if(teeth_mod)
		teeth_mod.update_lisp()
	else
		teeth_mod = new()
		if(owner)
			teeth_mod.add_speech_modifier(owner)
	if(owner)
		owner.Stun(2 SECONDS)
	update_limb_efficiency()
	return dropped

/obj/item/bodypart/mouth/proc/get_fang_bonus()
	var/bonus = 0
	if(!teeth)
		return bonus
	for(var/obj/item/natural/bundle/teeth/bundle in teeth)
		if(bundle.stacktype)
			var/obj/item/natural/teeth/tooth_template = bundle.stacktype
			bonus += initial(tooth_template.fang_bonus) * bundle.amount
	return bonus

/obj/item/bodypart/mouth/proc/get_bite_damage(mob/living/user)
	if(!ishuman(user))
		return user.get_punch_dmg() * (HAS_TRAIT(user, TRAIT_STRONGBITE) ? 2 : 1)

	var/mob/living/carbon/human/human = user
	var/damage
	var/used_con = GET_MOB_ATTRIBUTE_VALUE(human, STAT_CONSTITUTION)

	if(used_con > 12 || used_con < 10)
		damage = used_con
	else
		damage = 12

	if(human.mind?.has_antag_datum(/datum/antagonist/werewolf))
		damage *= 2

	if(used_con >= 11)
		damage = max(damage * (1 + ((used_con - 10) * 0.03)), 1)
	if(used_con <= 9)
		damage = max(damage * (1 - ((10 - used_con) * 0.05)), 1)

	if(HAS_TRAIT(user, TRAIT_STRONGBITE))
		damage *= 2

	damage += human.dna.species.punch_damage
	damage *= (limb_efficiency / LIMB_EFFICIENCY_OPTIMAL)
	damage += get_fang_bonus()

	return damage
