
/obj/item/quest_package
	name = "quest parcel"
	desc = "A bundled parcel of quest turn-in items. The originating pledge scroll must be used on it to open it."
	icon = 'icons/obj/ration.dmi'
	icon_state = "ration_small"
	var/quest_title = ""
	/// Weakref to the specific pledge scroll that must be used to open this parcel.
	var/datum/weakref/pledge_ref

/obj/item/quest_package/examine(mob/user)
	. = ..()
	if(quest_title)
		. += "It's labeled: \"[quest_title]\"."
	if(pledge_ref)
		. += span_notice("The seal bears a guild pledge mark. Only the originating pledge scroll can open it.")

/obj/item/quest_package/attackby(obj/item/used_item, mob/living/carbon/human/user, params)
	//must be attacked by the exact pledge scroll if existing
	if(pledge_ref)
		var/obj/item/paper/scroll/quest/pledge/PL = pledge_ref.resolve()
		if(QDELETED(PL) || used_item != PL)
			to_chat(user, span_warning("This parcel is sealed with a pledge mark. Only the originating pledge scroll can open it."))
			return
		do_open(user)
		return

	. = ..()

/obj/item/quest_package/proc/do_open(mob/user)
	if(!length(contents))
		to_chat(user, span_warning("The parcel is empty."))
		return
	to_chat(user, span_notice("You break the seal on [src] and tip out its contents."))
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(user))
	qdel(src)

/obj/item/quest_package/attack_self(mob/user)
	if(pledge_ref)
		return
	if(!length(contents))
		to_chat(user, span_warning("The parcel is empty."))
		return
	to_chat(user, span_notice("You unwrap [src] and tip out its contents."))
	for(var/obj/item/I in contents)
		I.forceMove(get_turf(user))
	qdel(src)
