/obj/item/building_schematic/thatchwood_hall
	name = "town hall schematic"
	desc = "A rolled construction schematic for Thatchwood's new town hall."

	/// Weakref to the driver so placement can report back
	var/datum/weakref/driver_ref

/obj/item/building_schematic/thatchwood_hall/proc/set_driver(datum/objective_quest_driver/town_objective/area/thatchwood/driver)
	driver_ref = WEAKREF(driver)

// Override equipped to use our spell subtype instead of the base one
/obj/item/building_schematic/thatchwood_hall/equipped(mob/user, slot)
	. = ..()
	if(!(slot & ITEM_SLOT_HANDS))
		return
	if(held_spell)
		return
	if(!building_template)
		return
	held_spell = new /datum/action/cooldown/spell/place_blueprint/thatchwood_hall(user)
	held_spell.schematic = src
	held_spell.Grant(user)


/datum/action/cooldown/spell/place_blueprint/thatchwood_hall

/datum/action/cooldown/spell/place_blueprint/thatchwood_hall/is_valid_target(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	var/obj/item/building_schematic/thatchwood_hall/S = schematic
	var/datum/objective_quest_driver/town_objective/area/thatchwood/driver = S.driver_ref?.resolve()
	if(!driver)
		owner.balloon_alert(owner, "Quest expired!")
		return FALSE

	if(driver.schematic_placed)
		owner.balloon_alert(owner, "Foundation already placed!")
		return FALSE

	var/turf/T = get_turf(cast_on)
	var/area/target_area = get_area(T)
	for(var/area/A in driver.real_areas)
		if(target_area == A)
			return TRUE

	owner.balloon_alert(owner, "Must place within Thatchwood!")
	return FALSE

/datum/action/cooldown/spell/place_blueprint/thatchwood_hall/cast(atom/cast_on)
	var/turf/T = get_turf(cast_on)
	if(!T)
		return

	var/datum/building_preview/preview = schematic?.get_or_build_preview()
	if(!preview)
		return

	unset_click_ability(owner, refund_cooldown = FALSE)

	var/list/placed = preview.place_blueprints(T, owner)
	if(!length(placed))
		return

	var/obj/item/building_schematic/thatchwood_hall/S = schematic
	var/datum/objective_quest_driver/town_objective/area/thatchwood/driver = S.driver_ref?.resolve()
	if(!driver)
		return

	driver.on_schematic_placed(owner, placed)
