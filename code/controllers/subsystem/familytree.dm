/*
* The familytree subsystem is supposed to be a way to
* assist RP by setting people up as related roundstart.
* This relation can be based on role (IE king and prince
* being father and son) or random chance.
*/
/*
* NOTES: There is some areas of this
* subsystem that can be more fleshed out
* such as how right now a house is just
* a bunch of names. Potentially this system
* can be used to create family curses/boons that
* effect all family members.
* There is also a additional variable i placed
* in human.dna called parent_mix that could be
* used for intrigue but currently it has
* no use and is only changed by the
* heritage datum BloodTies() proc.`
*/
SUBSYSTEM_DEF(familytree)
	name = "familytree"
	flags = SS_NO_FIRE
	lazy_load = FALSE

	/*
	* The family that kings, queens, and princes
	* are automatically placed into. Has no other
	* real function.
	*/
	var/datum/heritage/ruling_family
	/*
	* The other major houses of Rockhill.
	* Id say think Shrouded Isle families but
	* smaller.
	*/
	var/list/families = list()
	/*
	* Bachalors and Bachalorettes
	*/
	var/list/viable_spouses = list()
	//These jobs are excluded from AddLocal()
	var/excluded_jobs = list(
		"Prince",
		"Princess",
		"Consort",
		"Monarch",
		"Hand",
		"Inquisitor",
		"Adept",
		"Jailor",
		"Orphan",
		"Innkeepers Son",
		"Churchling",
		)
	//This creates 2 families for each race roundstart so that siblings dont fail to be added to a family.
	var/list/preset_family_species = list(
		/datum/species/human/northern,
		/datum/species/elf,
		/datum/species/elf/dark,
		/datum/species/human/halfelf,
		/datum/species/dwarf/mountain,
		/datum/species/tieberian,
		/datum/species/aasimar,
		/datum/species/rakshari,
		/datum/species/halforc
		)

/datum/controller/subsystem/familytree/Initialize()
	ruling_family = new /datum/heritage(majority_species = /datum/species/human/northern)
	//Blank starter families that we can customize for players.
	for(var/pioneer_household in preset_family_species)
		for(var/I = 1 to 2)
		families += new /datum/heritage(majority_species = pioneer_household)

	return ..()

/datum/controller/subsystem/familytree/proc/WouldCreateAgeConflict(datum/heritage/house, mob/living/carbon/human/person)
	// Check against parents - person shouldn't be older than parents unless they're uncle/aunt
	if(house.patriarch && !house.CanBeParentOf(house.patriarch.age, person.age))
		// Check if they could be uncle/aunt instead
		if(!house.CanBeUncleAunt(person.age, house.patriarch.age))
			return TRUE

	if(house.matriarch && !house.CanBeParentOf(house.matriarch.age, person.age))
		if(!house.CanBeUncleAunt(person.age, house.matriarch.age))
			return TRUE

	// Check against existing children for sibling compatibility
	for(var/mob/living/carbon/human/family_member in house.family)
		var/role = house.family[family_member]
		if(role == FAMILY_PROGENY || role == FAMILY_ADOPTED)
			if(!house.CanBeSiblings(person.age, family_member.age))
				return TRUE

	return FALSE

/datum/controller/subsystem/familytree/proc/DetermineAppropriateRole(datum/heritage/house, mob/living/carbon/human/person, adopted = FALSE)
	// Children always become progeny/adopted
	if(person.age == AGE_CHILD)
		return adopted ? FAMILY_ADOPTED : FAMILY_PROGENY

	// Check if person should be uncle/aunt based on age relative to parents
	if(house.patriarch || house.matriarch)
		var/should_be_uncle_aunt = FALSE

		if(house.patriarch && house.CanBeUncleAunt(person.age, house.patriarch.age))
			// If person is same age category as parent, make them uncle/aunt
			if(house.GetAgeRank(person.age) >= house.GetAgeRank(house.patriarch.age))
				should_be_uncle_aunt = TRUE

		if(house.matriarch && house.CanBeUncleAunt(person.age, house.matriarch.age))
			if(house.GetAgeRank(person.age) >= house.GetAgeRank(house.matriarch.age))
				should_be_uncle_aunt = TRUE

		if(should_be_uncle_aunt)
			return FAMILY_OMMER

	// Check if person is too old to be sibling with existing children
	var/too_old_for_siblings = FALSE
	for(var/mob/living/carbon/human/family_member in house.family)
		var/role = house.family[family_member]
		if(role == FAMILY_PROGENY || role == FAMILY_ADOPTED)
			if(!house.CanBeSiblings(person.age, family_member.age))
				too_old_for_siblings = TRUE
				break

	if(too_old_for_siblings)
		return FAMILY_OMMER

	// Default to child role if age allows
	return adopted ? FAMILY_ADOPTED : FAMILY_PROGENY

/*
* In order for us to use age in sorting of generations we would need to
* make the king & queen older than the prince.
*/
/datum/controller/subsystem/familytree/proc/AddLocal(mob/living/carbon/human/H, status)
	if(!H || !status || istype(H, /mob/living/carbon/human/dummy))
		return
	//Exclude princes and princesses from having their parentage calculated.
	if(H.job in excluded_jobs)
		return
	switch(status)
		if(FAMILY_PARTIAL)
			AssignToHouse(H)

		if(FAMILY_NEWLYWED)
			if(H.age == AGE_CHILD)
				AssignToHouse(H)
				return
			else
				AssignNewlyWed(H)

		if(FAMILY_FULL)
			if(H.virginity)
				return
			if(H.age == AGE_CHILD)
				AssignToHouse(H)
				return
			AssignToFamily(H)

/*
* Assigns lord and lady to the royal family.
* If they are father or mother they claim the house in their name.
*/
/datum/controller/subsystem/familytree/proc/AddRoyal(mob/living/carbon/human/H, status)
	if(status == FAMILY_FATHER || status == FAMILY_MOTHER)
		if(!ruling_family.housename)
			ruling_family.ClaimHouse(H)
			return
		//If king has already married another, the queen is not added to the royal family by default. Get angry!
		if(ruling_family.matriarch && ruling_family.patriarch)
			return
	ruling_family.addToHouse(H, status)

/*
* Assigns people randomly as heirs to one of the major
* famlies of Rockhill based on their species.
*/
/datum/controller/subsystem/familytree/proc/AssignToHouse(mob/living/carbon/human/H)
	if(!H)
		return

	var/species = H.dna.species.type
	var/adopted = FALSE
	var/datum/heritage/chosen_house
	var/list/low_priority_houses = list()
	var/list/high_priority_houses = list()

	for(var/datum/heritage/I in families)
		if(I.housename && (I.family.len >= 1 && I.family.len < 6))
			high_priority_houses.Add(I)
		else
			low_priority_houses.Add(I)

	for(var/i = 1 to 2)
		var/list/what_we_checkin = high_priority_houses
		if(i == 2)
			what_we_checkin = low_priority_houses
		for(var/datum/heritage/I in what_we_checkin)
			if(I.dominant_species == species && (I.family.len >= 1 && I.family.len < 4))
				if(!WouldCreateAgeConflict(I, H))
					chosen_house = I
					break
			if(prob(20) && (I.family.len > 1 && I.family.len <= 8))
				if(!WouldCreateAgeConflict(I, H))
					chosen_house = I
					adopted = TRUE
					break
		if(chosen_house)
			break

	if(chosen_house)
		var/role = DetermineAppropriateRole(chosen_house, H, adopted)
		chosen_house.addToHouse(H, role)

/*
* Allows players to claim a
* house as patriarch or matriarch.
* Currently roundstart families are
* male and female since it makes
* species calulcation easier on me.
*/
/datum/controller/subsystem/familytree/proc/AssignToFamily(mob/living/carbon/human/H)
	if(!H)
		return
	var/our_species = H.dna.species.type
	var/list/low_priority_houses = list()
	var/list/medium_priority_houses = list()
	var/list/high_priority_houses = list()
	for(var/datum/heritage/I in families)
		//This house is full.
		if(I.matriarch && I.patriarch)
			continue
		//The accursed setspouse code so people can preset their spouses
		var/mob/living/carbon/human/spouse_to_be
		if(ishuman(I.matriarch))
			spouse_to_be = I.matriarch
		if(ishuman(I.patriarch))
			spouse_to_be = I.patriarch
		//There is someone in this house.
		if(spouse_to_be)
			//If this player has the name of the spouse you want.
			if(spouse_to_be.real_name == H.setspouse)
				//You have eachothers names as your setspouse
				if(spouse_to_be.setspouse == H.real_name)
					high_priority_houses.Add(I)
				//They are impartial
				if(!spouse_to_be.setspouse)
					medium_priority_houses.Add(I)
				continue
			//They would like you as their spouse and your impartial to it.
			if(!H.setspouse && spouse_to_be.setspouse == H.real_name)
				medium_priority_houses.Add(I)
				continue
			//They are waiting for someone else.
			if(spouse_to_be.setspouse)
				continue
		//Normal Code
		if(I.dominant_species != our_species)
			continue
		low_priority_houses.Add(I)

	/*
	* Checks 3 lists.
	* 1 High Priority: Houses that have the setspouse player.
	* 2 Medium Priority: Houses without spouses
	* 3 Low Priority: Everything else that applies
	*/
	var/list/what_we_checkin = list()
	for(var/cycle = 1 to 3)
		//If second run then check the other houses.
		switch(cycle)
			if(1)
				what_we_checkin = high_priority_houses
			if(2)
				what_we_checkin = medium_priority_houses
			if(3)
				what_we_checkin = low_priority_houses
		for(var/datum/heritage/eligable_house in what_we_checkin)
			var/mob/living/carbon/human/mat = eligable_house.matriarch
			var/mob/living/carbon/human/pat = eligable_house.patriarch
			if(!eligable_house.housename)
				eligable_house.ClaimHouse(H)
				return
			//Sloppy method to check husband and wife one after another.
			if(!mat && H.gender == FEMALE)
				eligable_house.addToHouse(H, FAMILY_MOTHER)
				return
			if(!pat && H.gender == MALE)
				eligable_house.addToHouse(H, FAMILY_FATHER)
				return
	//None of the above added the person to a family. This means we must add them to a entirely new house.
	if(our_species != /datum/species/aasimar)
		families += new /datum/heritage(H)

/*
* For marrying two people together based on spousename.
*/
/datum/controller/subsystem/familytree/proc/AssignNewlyWed(mob/living/carbon/human/H)
	viable_spouses.Add(H)
	var/list/high_priority_lover = list()
	var/list/mid_priority_lover = list()
	var/list/low_priority_lover = list()
	for(var/vs in viable_spouses)
		//Thats no one.
		if(!vs || !ishuman(vs))
			continue
		var/mob/living/carbon/human/L = vs
		//Thats you dude.
		if(L == H)
			continue
		//They already have a spouse so skip this one.
		if(L.spouse_mob)
			continue
		//True love! They chose you and chose love them!
		if(H.setspouse == L.real_name && L.setspouse == H.real_name)
			high_priority_lover.Add(L)
			break
		/*
		* This person has the name of the
		* spouse you want. But their setspouse is none.
		*/
		if(H.setspouse == L.real_name && !L.setspouse)
			high_priority_lover.Add(L)
			continue
		// This person wants you but you didnt choose them.
		if(L.setspouse == H.real_name)
			mid_priority_lover.Add(L)
			continue
		//Everyone else is placed in the loser pile.
		low_priority_lover.Add(L)

	var/lover
	//Im sorry its convoluted but i think its more COMPRESSED.
	for(var/cycle = 1 to 3)
		//WE FOUND THEM!!!
		if(lover)
			break
		if(cycle > 2 && H.setspouse)
			break
		var/list/what_we_checkin = list()
		switch(cycle)
			if(1)
				what_we_checkin = high_priority_lover
			if(2)
				what_we_checkin = mid_priority_lover
			if(3)
				what_we_checkin = low_priority_lover
		//To avoid runtime errors due to picking from a empty list.
		if(what_we_checkin.len)
			lover = pick(what_we_checkin)
	//Success YOUR MARRIED!!!
	if(ishuman(lover) && lover)
		viable_spouses -= lover
		viable_spouses -= H
		H.MarryTo(lover)

/*
* Assings people as uncles and aunts.
*/
/datum/controller/subsystem/familytree/proc/AssignAuntUncle(mob/living/carbon/human/H)
	var/species = H.dna.species.type
	var/inlaw = FALSE
	var/datum/heritage/chosen_house
	var/list/low_priority_houses = list()
	var/list/high_priority_houses = list()

	for(var/datum/heritage/I in families)
		if(I.housename && I.family.len >= 2 && (I.patriarch || I.matriarch))
			// Check if person can be uncle/aunt based on age
			var/can_be_uncle_aunt = FALSE

			if(I.patriarch && I.CanBeUncleAunt(H.age, I.patriarch.age))
				can_be_uncle_aunt = TRUE
			if(I.matriarch && I.CanBeUncleAunt(H.age, I.matriarch.age))
				can_be_uncle_aunt = TRUE

			if(can_be_uncle_aunt)
				high_priority_houses.Add(I)
		else if(I.family.len >= 1)
			low_priority_houses.Add(I)

	for(var/i = 1 to 2)
		var/list/what_we_checkin = high_priority_houses
		if(i == 2)
			what_we_checkin = low_priority_houses
		for(var/datum/heritage/I in what_we_checkin)
			if(I.dominant_species == species && I.housename)
				chosen_house = I
				break
			if(prob(2) && I.housename)
				chosen_house = I
				inlaw = TRUE
				break
		if(chosen_house)
			break

	if(chosen_house)
		chosen_house.addToHouse(H, inlaw ? FAMILY_INLAW : FAMILY_OMMER)

/*
* For admins to view EVERY FAMILY and see all the
* akward and convoluted coding.
*/
/datum/controller/subsystem/familytree/proc/ReturnAllFamilies()
	. = ""
	if(ruling_family)
		. += ruling_family.FormatFamilyList()
	for(var/datum/heritage/I in families)
		if(!I.housename && !I.family.len)
			continue
		. += I.FormatFamilyList()

/datum/controller/subsystem/familytree/proc/ValidateAllFamilies()
	if(ruling_family)
		ruling_family.ValidateAndFixRelationships()
	for(var/datum/heritage/family in families)
		if(family.family.len)
			family.ValidateAndFixRelationships()

/datum/family_tree_interface
	var/datum/heritage/current_family
	var/mob/viewer

/datum/family_tree_interface/New(datum/heritage/family, mob/user)
	current_family = family
	viewer = user

/datum/family_tree_interface/proc/show_interface()
	var/html = generate_interface_html()
	usr << browse(html, "window=family_tree;size=800x600")

/datum/family_tree_interface/proc/generate_interface_html()
	var/html = {"
	<html>
	<head>
		<style>
			body {
				margin: 0;
				padding: 0;
				background: #000;
				color: #eee;
				font-family: Arial, sans-serif;
				overflow: hidden;
			}

			.family-tree-container {
				position: relative;
				width: 100%;
				height: 100vh;
				overflow: hidden;
				cursor: grab;
			}

			.family-canvas {
				position: absolute;
				transform-origin: 0 0;
			}

			.connection-line {
				position: absolute;
				height: 2px;
				background: linear-gradient(90deg,
					rgba(255,215,0,0.8) 0%,
					rgba(218,165,32,0.6) 50%,
					rgba(255,215,0,0.4) 100%);
				transform-origin: left center;
				z-index: 1;
				border-radius: 1px;
				box-shadow: 0 0 4px rgba(255,215,0,0.3);
			}

			.family-node {
				position: absolute;
				width: 80px;
				height: 100px;
				display: flex;
				flex-direction: column;
				align-items: center;
				cursor: pointer;
				transition: all 0.2s;
				z-index: 2;
			}

			.node-border {
				width: 64px;
				height: 64px;
				border: 3px solid;
				border-radius: 50%;
				overflow: hidden;
				box-shadow: 0 0 10px rgba(0,0,0,0.5);
			}

			.patriarch .node-border { border-color: #4169E1; }
			.matriarch .node-border { border-color: #FF69B4; }
			.progeny .node-border { border-color: #32CD32; }
			.adopted .node-border { border-color: #FFD700; }
			.ommer .node-border { border-color: #9370DB; }

			.family-node img {
				width: 100%;
				height: 100%;
				object-fit: cover;
			}

			.family-node .name {
				margin-top: 5px;
				font-size: 12px;
				text-align: center;
				text-shadow: 1px 1px 2px rgba(0,0,0,0.8);
			}

			.family-node .role {
				font-size: 10px;
				color: #888;
				text-align: center;
			}

			.family-node:hover {
				transform: scale(1.1);
				z-index: 100;
			}

			.tooltip {
				position: absolute;
				background: rgba(0,0,0,0.9);
				border: 1px solid #444;
				padding: 10px;
				border-radius: 5px;
				display: none;
				z-index: 1000;
			}
		</style>
	</head>
	<body>
		<div class="family-tree-container" id="container">
			<div class="family-canvas" id="canvas">
				[generate_family_connections()]
				[generate_family_nodes()]
			</div>
		</div>
		<div class="tooltip" id="tooltip"></div>

		<script>
			let isDragging = false;
			let startX, startY;
			let currentX = 400, currentY = 300;
			let scale = 1;

			const container = document.getElementById('container');
			const canvas = document.getElementById('canvas');
			const tooltip = document.getElementById('tooltip');

			function updateTransform() {
				canvas.style.transform = `translate(${currentX}px, ${currentY}px) scale(${scale})`;
			}

			container.addEventListener('mousedown', function(e) {
				if (e.target === container || e.target === canvas) {
					isDragging = true;
					startX = e.clientX - currentX;
					startY = e.clientY - currentY;
					container.style.cursor = 'grabbing';
				}
			});

			document.addEventListener('mousemove', function(e) {
				if (isDragging) {
					currentX = e.clientX - startX;
					currentY = e.clientY - startY;
					updateTransform();
				}
			});

			document.addEventListener('mouseup', function() {
				isDragging = false;
				container.style.cursor = 'grab';
			});

			container.addEventListener('wheel', function(e) {
				e.preventDefault();
				const delta = e.deltaY > 0 ? -0.1 : 0.1;
				scale = Math.max(0.5, Math.min(2, scale + delta));
				updateTransform();
			});

			updateTransform();
		</script>
	</body>
	</html>
	"}
	return html

/datum/family_tree_interface/proc/generate_family_nodes()
	var/html = ""

	// Position nodes in tree layout
	var/y_level = 0

	// Rulers at top
	if(current_family.patriarch)
		html += generate_node(current_family.patriarch, 100, y_level, "patriarch")
	if(current_family.matriarch)
		html += generate_node(current_family.matriarch, 300, y_level, "matriarch")

	y_level += 100

	// Children below
	var/x = 50
	for(var/mob/living/carbon/human/member in current_family.family)
		var/member_status = current_family.family[member]
		if(member_status == FAMILY_PROGENY || member_status == FAMILY_ADOPTED)
			html += generate_node(member, x, y_level, member_status == FAMILY_PROGENY ? "progeny" : "adopted")
			x += 100

	// Extended family
	y_level += 50
	x = 400
	for(var/mob/living/carbon/human/member in current_family.family)
		var/member_status = current_family.family[member]
		if(member_status == FAMILY_OMMER || member_status == FAMILY_INLAW)
			html += generate_node(member, x, y_level, lowertext(member_status))
			x += 100

	return html

/datum/family_tree_interface/proc/generate_family_connections()
	var/html = ""

	// Store node positions for connection calculations
	var/list/node_positions = list()

	// Map positions for rulers
	if(current_family.patriarch)
		node_positions[current_family.patriarch] = list("x" = 100, "y" = 0)
	if(current_family.matriarch)
		node_positions[current_family.matriarch] = list("x" = 300, "y" = 0)

	// Map positions for children
	var/child_x = 50
	var/child_y = 100
	for(var/mob/living/carbon/human/member in current_family.family)
		var/member_status = current_family.family[member]
		if(member_status == FAMILY_PROGENY || member_status == FAMILY_ADOPTED)
			node_positions[member] = list("x" = child_x, "y" = child_y)
			child_x += 100

	// Draw connections
	for(var/mob/living/carbon/human/member in current_family.family)
		var/member_status = current_family.family[member]
		if(member_status == FAMILY_PROGENY || member_status == FAMILY_ADOPTED)
			// Connect to patriarch
			if(current_family.patriarch && node_positions[current_family.patriarch])
				html += draw_connection(
					node_positions[current_family.patriarch]["x"] + 40,
					node_positions[current_family.patriarch]["y"] + 40,
					node_positions[member]["x"] + 40,
					node_positions[member]["y"] + 40
				)

			// Connect to matriarch
			if(current_family.matriarch && node_positions[current_family.matriarch])
				html += draw_connection(
					node_positions[current_family.matriarch]["x"] + 40,
					node_positions[current_family.matriarch]["y"] + 40,
					node_positions[member]["x"] + 40,
					node_positions[member]["y"] + 40
				)

	return html

/datum/family_tree_interface/proc/draw_connection(start_x, start_y, end_x, end_y)
	var/dx = end_x - start_x
	var/dy = end_y - start_y
	var/distance = sqrt(dx*dx + dy*dy)
	var/angle = arctan(dy/dx)
	if(dx < 0)
		angle += 180

	return {"<div class="connection-line" style="
		left: [start_x]px;
		top: [start_y]px;
		width: [distance]px;
		transform: rotate([angle]deg);
	"></div>"}

/datum/family_tree_interface/proc/generate_node(mob/living/carbon/human/H, x, y, class)
	var/status_color
	switch(class)
		if("patriarch")
			status_color = "#4169E1" // Royal Blue
		if("matriarch")
			status_color = "#FF69B4" // Hot Pink
		if("progeny")
			status_color = "#32CD32" // Lime Green
		if("adopted")
			status_color = "#FFD700" // Gold
		if("ommer", "inlaw")
			status_color = "#9370DB" // Medium Purple
		else
			status_color = "#FFFFFF" // White

	var/role_title = ""
	switch(class)
		if("patriarch")
			role_title = "Patriarch"
		if("matriarch")
			role_title = "Matriarch"
		if("progeny")
			role_title = H.gender == MALE ? "Son" : "Daughter"
		if("adopted")
			role_title = "Adopted [H.gender == MALE ? "Son" : "Daughter"]"
		if("ommer")
			role_title = H.gender == MALE ? "Uncle" : "Aunt"
		if("inlaw")
			role_title = "In-law"

	// Use ma2html for the appearance
	var/image_data = ma2html(H.appearance, usr)

	return {"
	<div class="family-node [class]" style="left: [x]px; top: [y]px"
		 data-name="[H.real_name]"
		 data-role="[role_title]"
		 data-species="[H.dna?.species?.name]"
		 onclick="showMemberDetails(this)">
		<div class="node-border" style="border-color: [status_color]">
			[image_data]
		</div>
		<div class="name" style="color: [status_color]">[H.real_name]</div>
		<div class="role">[role_title]</div>
	</div>
	"}

/datum/family_tree_interface/proc/get_role_title(mob/living/carbon/human/H, class)
	switch(class)
		if("patriarch")
			return "Patriarch"
		if("matriarch")
			return "Matriarch"
		if("progeny")
			return H.gender == MALE ? "Son" : "Daughter"
		if("adopted")
			return "Adopted [H.gender == MALE ? "Son" : "Daughter"]"
		if("ommer")
			return H.gender == MALE ? "Uncle" : "Aunt"
		if("inlaw")
			return "In-law"
	return "Unknown"

/datum/family_tree_interface/proc/get_node_x(mob/living/carbon/human/H)
	// Calculate x position based on role and family structure
	var/status = current_family.family[H]
	var/base_x = 400 // Center point

	switch(status)
		if(FAMILY_FATHER)
			return base_x - 100
		if(FAMILY_MOTHER)
			return base_x + 100
		if(FAMILY_PROGENY, FAMILY_ADOPTED)
			var/child_index = 0
			var/total_children = 0
			for(var/mob/living/carbon/human/child in current_family.family)
				var/child_status = current_family.family[child]
				if(child_status == FAMILY_PROGENY || child_status == FAMILY_ADOPTED)
					total_children++
					if(child == H)
						child_index = total_children

			var/spread = min(total_children * 80, 400)
			return base_x - (spread/2) + (child_index * (spread/(total_children+1)))

		if(FAMILY_OMMER)
			return base_x + rand(-200, 200) // Random offset for extended family

	return base_x

/datum/family_tree_interface/proc/get_node_y(mob/living/carbon/human/H)
	// Calculate y position based on generation/role
	var/status = current_family.family[H]
	var/base_y = 100

	switch(status)
		if(FAMILY_FATHER, FAMILY_MOTHER)
			return base_y
		if(FAMILY_PROGENY, FAMILY_ADOPTED)
			return base_y + 150
		if(FAMILY_OMMER)
			return base_y + 75

	return base_y

// Usage:
/datum/controller/subsystem/familytree/proc/show_family_tree(datum/heritage/family, mob/user)
	var/datum/family_tree_interface/interface = new(family, user)
	var/html = interface.generate_interface_html()
	user << browse(html, "window=family_tree;size=800x600")


/client/proc/family_tree_debug_menu()
	set name = "Family Tree Debug Menu"
	set category = "Debug"

	var/html = {"
	<html>
	<head>
		<style>
			body {
				font-family: Arial, sans-serif;
				margin: 20px;
				background: #1a1a1a;
				color: #eee;
			}
			.container {
				max-width: 1000px;
				margin: 0 auto;
				background: #2a2a2a;
				padding: 20px;
				border-radius: 10px;
				border: 1px solid #444;
			}
			.section {
				margin-bottom: 30px;
				padding: 15px;
				border: 1px solid #444;
				border-radius: 5px;
				background: #333;
			}
			.family-card {
				border: 1px solid #666;
				margin: 10px 0;
				padding: 10px;
				border-radius: 5px;
				background: #3a3a3a;
				cursor: pointer;
				transition: all 0.2s;
			}
			.family-card:hover {
				background: #4a4a4a;
				border-color: #0f0;
			}
			.family-member {
				margin: 5px 0;
				padding: 5px;
				border-left: 3px solid #0f0;
			}
			.button {
				background: #1a472a;
				color: #0f0;
				padding: 10px 15px;
				border: 1px solid #0f0;
				border-radius: 5px;
				cursor: pointer;
				margin: 5px;
				display: inline-block;
				text-decoration: none;
			}
			.button:hover {
				background: #2a573a;
				box-shadow: 0 0 10px #0f0;
			}
		</style>
	</head>
	<body>
		<div class="container">
			<h1>Family Tree Debug Menu</h1>

			<div class="section">
				<h2>Quick Actions</h2>
				<a href="?src=\ref[src];action=view_ruling_tree" class="button">View Ruling Family Tree</a>
				<a href="?src=\ref[src];action=generate_test" class="button">Generate Test Family</a>
				<a href="?src=\ref[src];action=list_all" class="button">List All Families</a>
				<a href="?src=\ref[src];action=clear_all" class="button">Clear All Families</a>
			</div>

			<div class="section">
				<h2>Active Families</h2>
				<div id="family-list">
					[generate_family_list_with_trees()]
				</div>
			</div>
		</div>
	</body>
	</html>
	"}

	usr << browse(html, "window=family_debug;size=1000x800")

/proc/generate_family_list_with_trees()
	var/list/output = list()

	// Ruling family first
	if(SSfamilytree.ruling_family)
		output += generate_family_list_entry(SSfamilytree.ruling_family, TRUE)

	// Then other families
	for(var/datum/heritage/H in SSfamilytree.families)
		if(H == SSfamilytree.ruling_family)
			continue
		output += generate_family_list_entry(H)

	return output.Join()

/proc/generate_family_list_entry(datum/heritage/H, is_ruling = FALSE)
	var/house_ref = "\ref[H]"
	var/html = "<div class='family-card' onclick='window.location=\"?src=\ref[usr.client];action=view_tree;family=[house_ref]\"'>"
	html += "<h3>[H.housename ? H.housename : "Unnamed House"][is_ruling ? " (Ruling Family)" : ""]</h3>"

	// Add basic family info
	var/member_count = H.family.len
	var/adopted_count = 0
	for(var/mob/living/carbon/human/member in H.family)
		if(H.family[member] == FAMILY_ADOPTED)
			adopted_count++

	html += "<div>Members: [member_count] ([adopted_count] adopted)</div>"

	if(H.patriarch)
		html += "<div>Patriarch: [H.patriarch.real_name]</div>"
	if(H.matriarch)
		html += "<div>Matriarch: [H.matriarch.real_name]</div>"

	html += "<div style='text-align: right; font-style: italic;'>Click to view family tree</div>"
	html += "</div>"
	return html

// Then in the client Topic(), change the calls to:
/client/Topic(href, list/href_list)
	. = ..()
	if(!check_rights(R_DEBUG))
		return

	switch(href_list["action"])
		if("view_ruling_tree")
			if(SSfamilytree.ruling_family)
				SSfamilytree.show_family_tree(SSfamilytree.ruling_family, usr)
			else
				to_chat(usr, "No ruling family exists!")

		if("view_tree")
			var/datum/heritage/H = locate(href_list["family"])
			if(H)
				SSfamilytree.show_family_tree(H, usr)
			else
				to_chat(usr, "Could not locate family!")

		if("generate_test")
			var/datum/heritage/test_family = generate_test_family()
			SSfamilytree.show_family_tree(test_family, usr)


/proc/generate_test_family()
	var/datum/heritage/H = new()
	H.housename = "House [pick("Storm", "Fire", "Ice", "Shadow", "Light", "Dawn", "Dusk")]"

	// Create patriarch
	var/mob/living/carbon/human/species/human/northern/father = new()
	var/last_name = pick(GLOB.last_names)
	father.real_name = "Lord [last_name]"
	father.gender = MALE
	father.age = rand(30, 60)
	H.addToHouse(father, FAMILY_FATHER)

	// Create matriarch
	var/mob/living/carbon/human/species/human/northern/mother = new()
	mother.real_name = "Lady [last_name]"
	mother.gender = FEMALE
	mother.age = rand(25, 55)
	H.addToHouse(mother, FAMILY_MOTHER)

	// Add 1-4 children
	var/num_children = rand(1, 4)
	for(var/i in 1 to num_children)
		var/mob/living/carbon/human/species/human/northern/child = new()
		child.gender = prob(50) ? MALE : FEMALE
		child.real_name = "[pick(child.gender == MALE ? GLOB.first_names_male : GLOB.first_names_female)] [last_name]"
		child.age = AGE_CHILD
		H.addToHouse(child, prob(80) ? FAMILY_PROGENY : FAMILY_ADOPTED)
	SSfamilytree.families += H
	return H
