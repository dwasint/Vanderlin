/obj/structure/ship_wheel
	name = "ship wheel"
	desc = "A large wooden ship wheel. Use it to navigate between islands."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	density = TRUE
	anchored = TRUE

	var/datum/ship_data/controlled_ship

	// Navigation state
	var/sailing_direction = 0 // Current direction (NORTH, SOUTH, etc.)
	var/sailing_speed = 0 // Current speed (0-100)
	var/max_sailing_speed = 5 // Maximum speed in tiles/tick

	// Position tracking
	var/nav_x = 0 // Position on navigation map
	var/nav_y = 0

	// UI
	var/const/ui_x = 1200
	var/const/ui_y = 900

/obj/structure/ship_wheel/Initialize(mapload)
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(find_controlled_ship))

/obj/structure/ship_wheel/proc/find_controlled_ship()
	sleep(10)
	controlled_ship = SSterrain_generation?.get_ship_at_location(loc)
	if(!controlled_ship)
		log_world("WARNING: Ship wheel at ([x], [y], [z]) not in a registered ship area!")
		return

	//! TEMPORARY NEED TO RANDOMLY PLACE ISLANDS
	nav_x = controlled_ship.bottom_left.x
	nav_y = controlled_ship.bottom_left.y

/obj/structure/ship_wheel/attack_hand(mob/user)
	if(!controlled_ship)
		to_chat(user, span_warning("This wheel isn't connected to a ship!"))
		return

	ui_interact(user)

/obj/structure/ship_wheel/ui_interact(mob/user)
	user << browse_rsc('html/map.jpg')
	var/datum/browser/popup = new(user, "ship_wheel", "Ship Navigation", ui_x, ui_y)
	popup.set_content(get_ui_html(user))
	popup.open()

/obj/structure/ship_wheel/proc/get_ui_html(mob/user)
	var/dat = {"
		<html>
		<head>
			<style>
				body {
					background: #000000;
					color: #897472;
					font-family: monospace;
					margin: 0;
					padding: 10px;
				}
				.container {
					display: flex;
					gap: 10px;
				}
				.left-panel {
					flex: 1;
				}
				.right-panel {
					flex: 0 0 350px;
				}
				.section {
					background: #202020;
					border: 1px solid #2f1c37;
					padding: 10px;
					margin-bottom: 10px;
				}
				.section-title {
					font-size: 16px;
					font-weight: bold;
					color: #ae3636;
					margin-bottom: 10px;
					border-bottom: 2px solid #161616;
					padding-bottom: 5px;
				}
				.map-container {
					width: 100%;
					height: 100%;
					min-height: 700px;
					background: url('map.jpg') center/cover no-repeat;
					border: 1px solid #2f1c37;
					position: relative;
					overflow: hidden;
				}
				.map-grid {
					position: absolute;
					width: 100%;
					height: 100%;
				}
				.grid-line {
					position: absolute;
					background: #2f1c37;
				}
				.ship-icon {
					position: absolute;
					width: 32px;
					height: 32px;
					transform: translate(-50%, -50%);
					z-index: 100;
				}
				.ship-icon img {
					width: 100%;
					height: 100%;
					image-rendering: pixelated;
				}
				.island-icon {
					position: absolute;
					width: 32px;
					height: 32px;
					transform: translate(-50%, -50%);
					cursor: pointer;
					z-index: 50;
				}
				.island-icon img {
					width: 100%;
					height: 100%;
					image-rendering: pixelated;
				}
				.island-icon:hover {
					filter: brightness(1.3);
				}
				.docked-island {
					filter: hue-rotate(90deg) brightness(1.5);
				}
				.controls {
					display: grid;
					grid-template-columns: repeat(3, 1fr);
					gap: 5px;
					margin: 10px 0;
				}
				.btn {
					background: #000000;
					border: 1px solid #000000;
					color: #7b5353;
					padding: 10px;
					cursor: pointer;
					font-family: monospace;
					font-size: 14px;
					text-align: center;
					text-decoration: none;
				}
				.btn:hover {
					background: #000000;
					border-color: #000000;
					color: #eac0b9;
					text-decoration: underline;
				}
				.btn:active {
					background: #000000;
				}
				.btn-active {
					background: #000000;
					border-color: #7b5353;
					color: #7b5353;
				}
				.btn-disabled {
					opacity: 0.3;
					cursor: not-allowed;
				}
				.btn-center {
					grid-column: 2;
					grid-row: 2;
				}
				.info-row {
					display: flex;
					justify-content: space-between;
					padding: 5px 0;
					border-bottom: 1px solid #2f1c37;
				}
				.info-label {
					color: #897472;
				}
				.info-value {
					color: #7b5353;
					font-weight: bold;
				}
				.speed-bar {
					width: 100%;
					height: 20px;
					background: #000000;
					border: 1px solid #2f1c37;
					position: relative;
					margin: 5px 0;
				}
				.speed-fill {
					height: 100%;
					background: #2f1c37;
					transition: width 0.3s;
				}
				.island-list {
					max-height: 200px;
					overflow-y: auto;
					scrollbar-color: #7b5353 #000000;
					scrollbar-width: thin;
				}
				.island-item {
					padding: 8px;
					margin: 5px 0;
					background: #000000;
					border: 1px solid #2f1c37;
					cursor: pointer;
				}
				.island-item:hover {
					background: #202020;
				}
				.difficulty-0 { color: #00ff00; }
				.difficulty-1 { color: #00ff00; }
				.difficulty-2 { color: #d09000; }
				.difficulty-3 { color: #d09000; }
				.difficulty-4 { color: #ff0000; }
			</style>
		</head>
		<body>
			<div class='container'>
				<div class='left-panel'>
					<div class='section'>
						<div class='section-title'>NAVIGATION MAP</div>
						<div class='map-container' id='navMap'>
							<!-- Map will be drawn here -->
						</div>
					</div>
				</div>

				<div class='right-panel'>
					<div class='section'>
						<div class='section-title'>SHIP STATUS</div>
						<div class='info-row'>
							<span class='info-label'>Heading:</span>
							<span class='info-value'>[dir2text(sailing_direction)]</span>
						</div>
						<div class='info-row'>
							<span class='info-label'>Status:</span>
							<span class='info-value'>[controlled_ship.docked_island ? "DOCKED" : "AT SEA"]</span>
						</div>
						[controlled_ship.docked_island ? "<div class='info-row'><span class='info-label'>Location:</span><span class='info-value'>[controlled_ship.docked_island.island_name]</span></div>" : ""]
						[controlled_ship.docked_island ? "<div style='margin-top: 10px;'><a class='btn' href='?src=[REF(src)];undock=1' style='width: 100%'>UNDOCK</a></div>" : ""]
					</div>

					<div class='section'>
						<div class='section-title'>SHIP CONTROL</div>
						<div class='controls'>
							<a class='btn' href='?src=[REF(src)];set_direction=[NORTHWEST]'>NW</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[NORTH]'>N</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[NORTHEAST]'>NE</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[WEST]'>W</a>
							<a class='btn btn-center' href='?src=[REF(src)];stop=1'>STOP</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[EAST]'>E</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[SOUTHWEST]'>SW</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[SOUTH]'>S</a>
							<a class='btn' href='?src=[REF(src)];set_direction=[SOUTHEAST]'>SE</a>
						</div>
						<div class='info-row'>
							<span class='info-label'>Speed:</span>
							<span class='info-value'>[sailing_speed]%</span>
						</div>
						<div class='speed-bar'>
							<div class='speed-fill' style='width: [sailing_speed]%'></div>
						</div>
						<a class='btn' href='?src=[REF(src)];adjust_speed=10' style='width: 46%; display: inline-block'>SPEED +</a>
						<a class='btn' href='?src=[REF(src)];adjust_speed=-10' style='width: 46%; display: inline-block; float: right'>SPEED -</a>
					</div>

					<div class='section'>
						<div class='section-title'>DISCOVERED ISLANDS</div>
						<div class='island-list'>
							[get_island_list_html()]
						</div>
					</div>
				</div>
			</div>

			<script>
				function drawMap() {
					var map = document.getElementById('navMap');
					var shipX = [nav_x];
					var shipY = [nav_y];

					//! IDK about this tbh
					for(var i = 0; i < 10; i++) {
						var vline = document.createElement('div');
						vline.className = 'grid-line';
						vline.style.left = (i * 10) + '%';
						vline.style.width = '1px';
						vline.style.height = '100%';
						map.appendChild(vline);

						var hline = document.createElement('div');
						hline.className = 'grid-line';
						hline.style.top = (i * 10) + '%';
						hline.style.height = '1px';
						hline.style.width = '100%';
						map.appendChild(hline);
					}

					[get_island_markers_js()]

					var ship = document.createElement('div');
					ship.className = 'ship-icon';
					ship.style.left = ((shipX / [world.maxx]) * 100) + '%';
					ship.style.top = (100 - ((shipY / [world.maxy]) * 100)) + '%';
					ship.innerHTML = "<img src='\ref['icons/obj/overmap.dmi']?state=ship&dir=2' />";
					ship.title = 'Your Ship';
					map.appendChild(ship);
				}

				drawMap();
			</script>
		</body>
		</html>
	"}

	return dat

/obj/structure/ship_wheel/proc/get_island_list_html()
	var/dat = ""
	for(var/datum/island_data/island in SSterrain_generation.island_registry)
		var/distance = get_dist(controlled_ship.bottom_left, island.bottom_left)
		dat += {"<div class='island-item [controlled_ship.docked_island == island ? "docked-island" : ""]'>
			<div><strong class='difficulty-[island.difficulty]'>[island.island_name]</strong></div>
			<div class='info-label'>Difficulty: [island.get_difficulty_text()]</div>
			<div class='info-label'>Distance: ~[distance] leagues</div>
		</div>"}

	if(!length(SSterrain_generation.island_registry))
		dat += "<div class='info-label'>No islands discovered</div>"

	return dat

/obj/structure/ship_wheel/proc/get_island_markers_js()
	var/js = ""
	for(var/datum/island_data/island in SSterrain_generation.island_registry)
		var/x_percent = (island.bottom_left.x / world.maxx) * 100
		var/y_percent = 100 - ((island.bottom_left.y / world.maxy) * 100) // Flip Y
		js += {"
			var island[island.island_id] = document.createElement('div');
			island[island.island_id].className = 'island-icon [controlled_ship.docked_island == island ? "docked-island" : ""]';
			island[island.island_id].style.left = '[x_percent]%';
			island[island.island_id].style.top = '[y_percent]%';
			island[island.island_id].innerHTML = "<img src='\ref['icons/obj/overmap.dmi']?state=event&dir=2' />";
			island[island.island_id].title = '[island.island_name]';
			map.appendChild(island[island.island_id]);
		"}

	return js

/obj/structure/ship_wheel/Topic(href, href_list)
	if(..())
		return

	if(!controlled_ship)
		return

	if(href_list["set_direction"])
		if(controlled_ship.docked_island)
			to_chat(usr, span_warning("The ship must be undocked before sailing!"))
			return

		var/new_dir = text2num(href_list["set_direction"])
		sailing_direction = new_dir

		if(sailing_speed == 0)
			sailing_speed = 50

		START_PROCESSING(SSobj, src)
		notify_crew("Course set to [dir2text(new_dir)]!")

	if(href_list["stop"])
		sailing_direction = 0
		sailing_speed = 0
		STOP_PROCESSING(SSobj, src)
		notify_crew("Ship coming to a stop.")

	if(href_list["adjust_speed"])
		if(controlled_ship.docked_island)
			to_chat(usr, span_warning("The ship must be undocked before adjusting speed!"))
			return

		var/adjustment = text2num(href_list["adjust_speed"])
		sailing_speed = clamp(sailing_speed + adjustment, 0, 100)

		if(sailing_speed == 0)
			STOP_PROCESSING(SSobj, src)
		else if(sailing_direction)
			START_PROCESSING(SSobj, src)

	if(href_list["undock"])
		if(controlled_ship.docked_island)
			if(SSterrain_generation.undock_ship(controlled_ship))
				notify_crew("Ship has undocked and is now at sea!")

	ui_interact(usr)

/obj/structure/ship_wheel/process()
	if(!sailing_direction || sailing_speed == 0)
		STOP_PROCESSING(SSobj, src)
		return

	if(controlled_ship.docked_island)
		STOP_PROCESSING(SSobj, src)
		return

	var/move_speed = (sailing_speed / 100) * max_sailing_speed

	if(sailing_direction & NORTH)
		nav_y += move_speed
	if(sailing_direction & SOUTH)
		nav_y -= move_speed
	if(sailing_direction & EAST)
		nav_x += move_speed
	if(sailing_direction & WEST)
		nav_x -= move_speed

	nav_x = clamp(nav_x, 0, world.maxx)
	nav_y = clamp(nav_y, 0, world.maxy)

	check_island_proximity()

/obj/structure/ship_wheel/proc/check_island_proximity()
	if(controlled_ship.docked_island)
		return

	var/dock_range = 50

	for(var/datum/island_data/island in SSterrain_generation.island_registry)
		if(abs(nav_x - island.bottom_left.x) < 10 && abs(nav_y - island.bottom_left.y) < 10)
			continue

		var/distance = sqrt((nav_x - island.bottom_left.x)**2 + (nav_y - island.bottom_left.y)**2)

		if(distance <= dock_range)
			sailing_direction = 0
			sailing_speed = 0
			STOP_PROCESSING(SSobj, src)

			if(SSterrain_generation.dock_ship_to_island(controlled_ship, island))
				notify_crew("Approaching [island.island_name]... Ship is now docking!")
				nav_x = island.bottom_left.x
				nav_y = island.bottom_left.y

			break

/obj/structure/ship_wheel/proc/notify_crew(message)
	for(var/mob/M in GLOB.player_list)
		if(M.z == controlled_ship.z_level)
			to_chat(M, span_notice("<b>\[Ship Navigation\]</b> [message]"))

/obj/structure/ship_wheel/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/ship_wheel/examine(mob/user)
	. = ..()
	if(controlled_ship)
		if(controlled_ship.docked_island)
			. += span_info("The ship is docked at <b>[controlled_ship.docked_island.island_name]</b>.")
		else
			. += span_info("The ship is sailing at <b>[sailing_speed]%</b> speed.")
			if(sailing_direction)
				. += span_info("Current heading: <b>[dir2text(sailing_direction)]</b>")
		. += span_info("Click to access the navigation console.")
	else
		. += span_warning("This wheel doesn't seem to be connected to a ship...")
