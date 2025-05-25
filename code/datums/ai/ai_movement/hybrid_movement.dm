///Uses Byond's basic obstacle avoidance movement unless the target is on a z-level different to ours
/datum/ai_movement/hybrid_pathing
	requires_processing = TRUE
	max_pathing_attempts = 12
	max_path_distance = 30
	var/fallbacking = FALSE
	var/fallback_fail = 0

	// Variables for asynchronous path generation
	var/repath_anticipation_distance = 5 // Start generating new path when this close to the end
	var/future_path_blackboard_key = BB_FUTURE_MOVEMENT_PATH

/datum/ai_movement/hybrid_pathing/process(delta_time)
	for(var/datum/ai_controller/controller as anything in moving_controllers)
		if(!(future_path_blackboard_key in controller.blackboard))
			controller.add_blackboard_key(future_path_blackboard_key, null)
		if(!COOLDOWN_FINISHED(controller, movement_cooldown))
			continue
		COOLDOWN_START(controller, movement_cooldown, controller.movement_delay)

		if(!controller.can_move())
			continue

		var/atom/movable/movable_pawn = controller.pawn
		var/turf/target_turf = get_step_towards(movable_pawn, controller.current_movement_target)
		var/turf/end_turf = get_turf(controller.current_movement_target)
		var/advanced = TRUE
		var/turf/current_turf = get_turf(movable_pawn)

		var/mob/cliented_mob = controller.current_movement_target
		var/cliented = FALSE
		if(istype(cliented_mob))
			if(cliented_mob.client)
				cliented = TRUE

		// Check if we've been displaced from our expected path position
		if(length(controller.movement_path) && controller.movement_path[1])
			var/turf/next_step = controller.movement_path[1]
			var/path_disrupted = FALSE

			// Check for Z-level displacement requiring stairs
			if(next_step.z > current_turf.z)
				// Check if there's a valid stair to go up
				var/turf/above = get_step_multiz(current_turf, UP)
				var/can_go_up = FALSE

				if(above && !above.density)
					// Look for stairs at current location
					for(var/obj/structure/stairs/S in current_turf.contents)
						var/turf/dest = get_step(above, S.dir)
						if(dest == next_step || get_step(dest, S.dir) == next_step)
							can_go_up = TRUE
							break

				// If we can't go up but our path expects us to, path is disrupted
				if(!can_go_up)
					path_disrupted = TRUE

			// Check for horizontal displacement (dragging on same level)
			else if(next_step.z == current_turf.z)
				// If we're more than 1 tile away from our next step, we might have been dragged
				if(get_dist(current_turf, next_step) > 1)
					// Only consider it disrupted if we're significantly off course
					// and not just slightly misaligned due to movement timing
					var/dist_to_target = get_dist(current_turf, end_turf)
					var/path_length = length(controller.movement_path)

					// If we're much closer to target than our path suggests, or much further,
					// we've likely been displaced
					if(path_length > 0 && (dist_to_target < (path_length * 0.5) || dist_to_target > (path_length * 1.5)))
						path_disrupted = TRUE

			// Clear path if disrupted, but only after a brief delay to avoid flicker from normal movement
			if(path_disrupted)
				// Use a small delay to prevent constant re-pathing from minor displacement
				if(!controller.movement_displacement_time)
					controller.movement_displacement_time = world.time
				else if(world.time - controller.movement_displacement_time > 0.5 SECONDS)
					controller.movement_path = null
					controller.clear_blackboard_key(future_path_blackboard_key)
					controller.movement_displacement_time = null
					fallbacking = FALSE
					fallback_fail = 0
					continue
			else
				// Reset displacement timer if we're back on track
				controller.movement_displacement_time = null

		// Basic movement for targets on the same z-level with no existing path
		if(end_turf?.z == movable_pawn?.z && !length(controller.movement_path) && !cliented)
			advanced = FALSE
			var/can_move = controller.can_move()

			var/current_loc = get_turf(movable_pawn)

			if(!is_type_in_typecache(target_turf, GLOB.dangerous_turfs) && can_move)
				step_to(movable_pawn, target_turf, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE], controller.movement_delay)

				if(current_loc == get_turf(movable_pawn))
					advanced = TRUE
					controller.movement_path = null
					controller.clear_blackboard_key(future_path_blackboard_key)
					fallbacking = TRUE
					SEND_SIGNAL(movable_pawn, COMSIG_AI_GENERAL_CHANGE, "Unable to Basic Move swapping to AStar.")

			if(!advanced)
				if(current_loc == get_turf(movable_pawn)) // Did we even move after trying to move?
					controller.pathing_attempts++
					if(controller.pathing_attempts >= max_pathing_attempts)
						controller.CancelActions()
						SEND_SIGNAL(movable_pawn, COMSIG_AI_GENERAL_CHANGE, "Failed pathfinding cancelling.")

		if(advanced)
			var/minimum_distance = controller.max_target_distance
			// Get the minimum distance required by current behaviors
			for(var/datum/ai_behavior/iter_behavior as anything in controller.current_behaviors)
				if(iter_behavior.required_distance < minimum_distance)
					minimum_distance = iter_behavior.required_distance

			if(get_dist(movable_pawn, controller.current_movement_target) <= minimum_distance)
				continue

			var/generate_path = FALSE
			var/list/future_path = controller.blackboard[future_path_blackboard_key]

			// Path following logic
			if(length(controller.movement_path))
				var/turf/last_turf = controller.movement_path[length(controller.movement_path)]
				var/turf/next_step = controller.movement_path[1]
				var/remaining_path_length = length(controller.movement_path)

				// Move to the next step in the path
				if(next_step.z != movable_pawn.z)
					movable_pawn.Move(next_step)
				else
					step_to(movable_pawn, next_step, controller.blackboard[BB_CURRENT_MIN_MOVE_DISTANCE], controller.movement_delay)

				// Check if target has moved significantly from the end of our path
				if(last_turf != get_turf(controller.current_movement_target))
					// If we have a pre-generated future path and it's relevant, use it
					if(future_path && length(future_path) && future_path[length(future_path)] == get_turf(controller.current_movement_target))
						controller.movement_path = future_path.Copy()
						controller.clear_blackboard_key(future_path_blackboard_key)
						SEND_SIGNAL(controller.pawn, COMSIG_AI_PATH_SWAPPED, controller.movement_path)
					else
						generate_path = TRUE
						controller.clear_blackboard_key(future_path_blackboard_key)

				// Update current path - remove steps we've completed
				if(get_turf(movable_pawn) == next_step || (istype(next_step, /turf/open/transparent) && get_turf(movable_pawn) == GET_TURF_BELOW(next_step)))
					controller.movement_path.Cut(1,2)
					if(length(controller.movement_path))
						var/turf/double_checked = controller.movement_path[1]

						if(get_turf(movable_pawn) == double_checked) // Handle z-level stack issues
							controller.movement_path.Cut(1,2)

					if(!length(controller.movement_path) && fallbacking)
						fallbacking = FALSE
				else
					if(!fallbacking)
						generate_path = TRUE
						controller.clear_blackboard_key(future_path_blackboard_key)
					else
						fallback_fail++
						if(fallback_fail >= 2)
							generate_path = TRUE
							fallbacking = FALSE
							controller.clear_blackboard_key(future_path_blackboard_key)

				// If we're nearing the end of our path, preemptively generate the next path
				// Only do this if we have a valid current path and aren't already generating a future path
				if(!generate_path && remaining_path_length <= repath_anticipation_distance && !future_path && COOLDOWN_FINISHED(controller, repath_cooldown))
					// Target doesnt exist anymore or we picked it up already
					if(QDELETED(controller.current_movement_target) || controller.current_movement_target.loc == movable_pawn)
						continue
					COOLDOWN_START(controller, repath_cooldown, 1 SECONDS) // Shorter cooldown for anticipatory pathing
					// Generate the future path and store it in the controller's blackboard
					var/list/new_future_path = get_path_to(movable_pawn, controller.current_movement_target, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d),
						max_path_distance + 1, 250, minimum_distance, id=controller.get_access())
					controller.set_blackboard_key(future_path_blackboard_key, new_future_path)
					SEND_SIGNAL(controller.pawn, COMSIG_AI_FUTURE_PATH_GENERATED, new_future_path)
			else
				generate_path = TRUE

			// Generate a new primary path if needed
			if(generate_path)
				if(!COOLDOWN_FINISHED(controller, repath_cooldown))
					continue
				controller.pathing_attempts++
				if(controller.pathing_attempts >= max_pathing_attempts)
					controller.CancelActions()
					continue
				// Target doesnt exist anymore or we picked it up already
				if(QDELETED(controller.current_movement_target) || controller.current_movement_target.loc == movable_pawn)
					continue
				COOLDOWN_START(controller, repath_cooldown, 1.5 SECONDS) // Reduced from 2 seconds
				controller.movement_path = get_path_to(movable_pawn, controller.current_movement_target, TYPE_PROC_REF(/turf, Heuristic_cardinal_3d),
					max_path_distance + 1, 250, minimum_distance, id=controller.get_access())
				controller.clear_blackboard_key(future_path_blackboard_key) // Clear any future path as we have a fresh main path
				SEND_SIGNAL(controller.pawn, COMSIG_AI_PATH_GENERATED, controller.movement_path)
