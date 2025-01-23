/obj/structure/mana_pylon
	name = "mana pylon"
	desc = ""

	icon_state = "standing0"
	icon = 'icons/roguetown/misc/lighting.dmi'
	has_initial_mana_pool = TRUE

	var/obj/structure/mana_pylon/linked_pylon
	var/datum/beam/created_beam

	var/list/transferring_mobs = list()

/obj/structure/mana_pylon/MouseDrop(obj/structure/over, src_location, over_location, src_control, over_control, params)
	. = ..()
	if(!isliving(usr))
		return

	if(!istype(over, type))
		return

	link_pylon(over)

/obj/structure/mana_pylon/get_initial_mana_pool_type()
	return /datum/mana_pool/mana_pylon

/obj/structure/mana_pylon/proc/link_pylon(obj/structure/mana_pylon/pylon_to_link)
	if(pylon_to_link.linked_pylon == src)
		return

	if(linked_pylon)
		unlink_pylon(linked_pylon)

	created_beam = LeyBeam(pylon_to_link, icon_state = "lichbeam", maxdistance = world.maxx, time = INFINITY)
	linked_pylon = pylon_to_link
	mana_pool.start_transfer(pylon_to_link.mana_pool, TRUE)

/obj/structure/mana_pylon/proc/unlink_pylon(obj/structure/pylon_to_unlink)
	QDEL_NULL(created_beam)
	linked_pylon = null
	mana_pool.stop_transfer(pylon_to_unlink.mana_pool)


/obj/structure/mana_pylon/proc/drain_mana(mob/living/user)
	var/datum/beam/transfer_beam = user.Beam(src, icon_state = "drain_life", time = INFINITY)

	var/failed = FALSE
	while(!failed)
		if(!do_after(user, 3 SECONDS, target = src))
			qdel(transfer_beam)
			failed = TRUE
			break
		if(!user.client)
			failed = TRUE
			qdel(transfer_beam)
			break
		var/transfer_amount = min(mana_pool.amount, 20)
		if(!transfer_amount)
			failed = TRUE
			qdel(transfer_beam)
			break
		mana_pool.transfer_specific_mana(user.mana_pool, transfer_amount, decrement_budget = TRUE)

/obj/structure/mana_pylon/attack_right(mob/user)
	. = ..()
	if(user.client)
		drain_mana(user)
