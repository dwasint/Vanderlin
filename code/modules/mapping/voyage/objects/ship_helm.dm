
/obj/structure/ship_wheel
	name = "ship wheel"
	desc = "A large wooden ship wheel. Use it to navigate and dock at islands."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	density = TRUE
	anchored = TRUE

	var/datum/ship_data/controlled_ship

/obj/structure/ship_wheel/Initialize(mapload)
	. = ..()
	// Find which ship this wheel belongs to
	INVOKE_ASYNC(src, PROC_REF(find_controlled_ship))

/obj/structure/ship_wheel/proc/find_controlled_ship()
	sleep(10) // Wait for subsystem to initialize
	controlled_ship = SSterrain_generation?.get_ship_at_location(loc)
	if(!controlled_ship)
		log_world("WARNING: Ship wheel at ([x], [y], [z]) not in a registered ship area!")

/obj/structure/ship_wheel/attack_hand(mob/user)
	. = ..()
	if(!controlled_ship)
		to_chat(user, span_warning("This wheel isn't connected to a ship!"))
		return

	if(controlled_ship.docked_island)
		// Option to undock
		var/choice = browser_alert(user, "Currently docked to [controlled_ship.docked_island.island_name]. Undock and set sail?", "Ship Wheel", list("Undock", "Cancel"))
		if(choice == "Undock")
			to_chat(user, span_notice("You turn the wheel, pulling up the boat..."))
			if(SSterrain_generation.undock_ship(controlled_ship))
				to_chat(user, span_notice("Ship undocked! The island fades from view as you set sail..."))
			else
				to_chat(user, span_warning("Failed to undock!"))
	else
		// Option to dock
		var/list/available_islands = SSterrain_generation.get_all_islands()
		if(!available_islands.len)
			to_chat(user, span_warning("No islands detected in these waters!"))
			return

		var/list/island_choices = list()
		for(var/datum/island_data/island in available_islands)
			island_choices[island.island_name] = island

		var/choice = input(user, "Select an island to dock to:", "Ship Wheel") as null|anything in island_choices
		if(!choice)
			return

		var/datum/island_data/selected_island = island_choices[choice]

		to_chat(user, span_notice("You turn the wheel, steering toward [selected_island.island_name]..."))

		if(SSterrain_generation.dock_ship_to_island(controlled_ship, selected_island))
			to_chat(user, span_notice("Ship docked at [selected_island.island_name]! A boat has been lowered."))
		else
			to_chat(user, span_warning("Failed to dock! The waters are too turbulent..."))

/obj/structure/ship_wheel/examine(mob/user)
	. = ..()
	if(controlled_ship)
		if(controlled_ship.docked_island)
			. += span_info("The ship is currently docked at <b>[controlled_ship.docked_island.island_name]</b>.")
			. += span_info("Click to undock and set sail.")
		else
			. += span_info("The ship is currently at sea.")
			. += span_info("Click to find an island to dock at.")
	else
		. += span_warning("This wheel doesn't seem to be connected to a ship...")
