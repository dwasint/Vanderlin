GLOBAL_LIST_EMPTY(bounty_locations)
GLOBAL_LIST_EMPTY(bounty_boards)
/obj/structure/bounty_board
	name = "bounty board"
	desc = "A weathered wooden board covered in various contracts and notices. Dark stains suggest not all jobs end well."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	anchored = TRUE
	density = FALSE
	var/list/active_contracts = list()
	var/list/completed_contracts = list()
	var/total_bounty_pool = 0
	var/list/delivery_locations = list() // Populated from landmarks
	var/list/contraband_packs = list() // Available contraband supply packs
	var/static/list/harlequinn_reputation = list() // ckey -> reputation score

/obj/structure/bounty_board/Initialize()
	. = ..()
	LAZYADD(GLOB.bounty_boards, src)
	populate_delivery_locations()
	populate_contraband_packs()

/obj/structure/bounty_board/proc/populate_delivery_locations()
	delivery_locations = list()
	for(var/obj/effect/landmark/bounty_location/loc in GLOB.bounty_locations)
		delivery_locations[loc.location_name] = loc

/obj/structure/bounty_board/proc/populate_contraband_packs()
	contraband_packs = list()
	// Find all supply packs with contraband = TRUE
	for(var/pack_type in subtypesof(/datum/supply_pack))
		var/datum/supply_pack/pack = new pack_type()
		if(pack.contraband)
			contraband_packs[pack.name] = pack_type
		qdel(pack)

/obj/structure/bounty_board/proc/get_reputation(mob/user)
	if(!user.ckey)
		return 0
	return harlequinn_reputation[user.ckey] || 0

/obj/structure/bounty_board/proc/modify_reputation(mob/user, amount)
	if(!user.ckey)
		return
	var/current = get_reputation(user)
	harlequinn_reputation[user.ckey] = current + amount

	var/new_rep = harlequinn_reputation[user.ckey]
	var/rep_text = get_reputation_text(new_rep)
	to_chat(user, span_notice("Your reputation has [amount > 0 ? "increased" : "decreased"] to [new_rep] ([rep_text])"))

/obj/structure/bounty_board/proc/get_reputation_text(rep_value)
	switch(rep_value)
		if(-INFINITY to -50)
			return "Pariah"
		if(-49 to -20)
			return "Untrustworthy"
		if(-19 to -5)
			return "Questionable"
		if(-4 to 4)
			return "Unknown"
		if(5 to 19)
			return "Reliable"
		if(20 to 49)
			return "Respected"
		if(50 to INFINITY)
			return "Legendary"

/obj/structure/bounty_board/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/structure/bounty_board/ui_interact(mob/user)
	var/html = get_bounty_board_html(user)
	user << browse(html, "window=bounty_board;size=900x700;titlebar=1;can_minimize=1;can_resize=1")
	onclose(user, "bounty_board")
/obj/structure/bounty_board/proc/get_bounty_board_html(mob/user)
	var/is_bountyhunter = is_bounty_hunter(user)
	var/location_options = ""
	var/contraband_options = ""

	for(var/location_name in delivery_locations)
		location_options += "<option value=\"[location_name]\">[location_name]</option>"

	for(var/pack_name in contraband_packs)
		contraband_options += "<option value=\"[pack_name]\">[pack_name]</option>"

	user << browse_rsc('html/book.png')
	var/html = {"
<!DOCTYPE html>
<html>
<head>
	<title>Bounty Board</title>
	<style>
		@import url('https://fonts.googleapis.com/css2?family=Cinzel:wght@400;600;700&family=Cinzel+Decorative:wght@700&display=swap');

		body {
			background: linear-gradient(135deg, #2d1810 0%, #1a0e08 100%);
			color: #d4c4a0;
			font-family: 'Cinzel', serif;
			margin: 0;
			padding: 15px;
			min-height: 100vh;
			overflow-x: hidden;
		}

		.container {
			max-width: 1000px;
			margin: 0 auto;
		}

		.board-frame {
			background: linear-gradient(145deg, #8B4513 0%, #654321 50%, #3e2723 100%);
			border: 6px solid #5d4e37;
			border-radius: 12px;
			padding: 20px;
			box-shadow: inset 0 0 15px rgba(0,0,0,0.5), 0 8px 25px rgba(0,0,0,0.8);
			position: relative;
			height: 90vh;
			display: flex;
			flex-direction: column;
		}

		.header {
			text-align: center;
			margin-bottom: 15px;
		}

		.title {
			font-family: 'Cinzel Decorative', serif;
			color: #ffd700;
			font-size: 2.2em;
			margin: 0;
			text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
			letter-spacing: 2px;
		}

		.subtitle {
			color: #d4c4a0;
			font-style: italic;
			margin: 5px 0;
			font-size: 0.9em;
		}

		.stats-scroll {
			background: linear-gradient(145deg, #f4e4bc 0%, #e6d7b8 100%);
			border: 2px solid #8B4513;
			border-radius: 8px;
			padding: 12px;
			margin-bottom: 15px;
			color: #3e2723;
			box-shadow: inset 0 2px 5px rgba(0,0,0,0.2);
		}

		.stats-bar {
			display: flex;
			justify-content: space-around;
		}

		.stat {
			text-align: center;
		}

		.stat-value {
			font-size: 1.3em;
			font-weight: bold;
			color: #8B4513;
		}

		.stat-label {
			font-size: 0.7em;
			color: #5d4e37;
			text-transform: uppercase;
			letter-spacing: 1px;
		}

		.reputation-badge {
			background: linear-gradient(145deg, #ffd700 0%, #ffed4a 100%);
			color: #3e2723;
			padding: 2px 8px;
			border-radius: 10px;
			font-size: 0.7em;
			font-weight: bold;
			border: 1px solid #8B4513;
			text-transform: uppercase;
			margin-top: 2px;
		}

		.main-content {
			display: flex;
			gap: 20px;
			flex: 1;
			min-height: 0;
		}

		.contracts-section {
			flex: 2;
			display: flex;
			flex-direction: column;
			min-height: 0;
		}

		.sidebar {
			flex: 1;
			min-height: 0;
		}

		.section-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			margin-bottom: 10px;
		}

		.section-title {
			color: #ffd700;
			margin: 0;
			font-size: 1.4em;
			font-weight: 600;
			text-shadow: 2px 2px 4px rgba(0,0,0,0.6);
		}

		.btn {
			background: linear-gradient(145deg, #8B4513 0%, #654321 100%);
			color: #ffd700;
			border: 2px solid #5d4e37;
			padding: 8px 16px;
			border-radius: 6px;
			cursor: pointer;
			font-family: 'Cinzel', serif;
			font-weight: 600;
			text-transform: uppercase;
			letter-spacing: 1px;
			transition: all 0.3s ease;
			box-shadow: 0 3px 6px rgba(0,0,0,0.3);
			font-size: 0.8em;
		}

		.btn:hover {
			background: linear-gradient(145deg, #a0522d 0%, #8B4513 100%);
			transform: translateY(-1px);
			box-shadow: 0 4px 8px rgba(0,0,0,0.4);
		}

		.btn-small {
			padding: 4px 8px;
			font-size: 0.7em;
		}

		.btn-accept { background: linear-gradient(145deg, #228B22 0%, #006400 100%); }
		.btn-accept:hover { background: linear-gradient(145deg, #32CD32 0%, #228B22 100%); }

		.btn-verify { background: linear-gradient(145deg, #4169E1 0%, #0000CD 100%); }
		.btn-verify:hover { background: linear-gradient(145deg, #6495ED 0%, #4169E1 100%); }

		.btn-reject { background: linear-gradient(145deg, #DC143C 0%, #8B0000 100%); }
		.btn-reject:hover { background: linear-gradient(145deg, #FF6347 0%, #DC143C 100%); }

		#contracts-list {
			flex: 1;
			overflow-y: auto;
			padding-right: 10px;
			display: grid;
			grid-template-columns: 1fr 1fr;
			gap: 12px;
			align-content: start;
		}

		#contracts-list::-webkit-scrollbar {
			width: 8px;
		}

		#contracts-list::-webkit-scrollbar-track {
			background: rgba(139, 69, 19, 0.2);
			border-radius: 4px;
		}

		#contracts-list::-webkit-scrollbar-thumb {
			background: linear-gradient(145deg, #8B4513, #654321);
			border-radius: 4px;
		}

		.bounty-note {
			background: url('book.png');
			border: 2px solid #8B4513;
			border-radius: 8px;
			padding: 12px;
			color: #3e2723;
			box-shadow: 0 4px 8px rgba(0,0,0,0.3), inset 0 1px 3px rgba(255,255,255,0.2);
			position: relative;
			transform: rotate(-0.3deg);
			height: fit-content;

			/* Ripped paper effect */
			clip-path: polygon(
				0% 5px,
				5px 0%,
				15px 9px,
				25px 0%,
				35px 6px,
				45px 0%,
				55px 12px,
				65px 0%,
				75px 6px,
				85px 0%,
				95% 9px,
				100% 0%,
				100% calc(100% - 5px),
				calc(100% - 5px) 100%,
				calc(100% - 15px) calc(100% - 9px),
				calc(100% - 25px) 100%,
				calc(100% - 35px) calc(100% - 6px),
				calc(100% - 45px) 100%,
				calc(100% - 55px) calc(100% - 12px),
				calc(100% - 65px) 100%,
				calc(100% - 75px) calc(100% - 6px),
				calc(100% - 85px) 100%,
				5px 100%,
				0% calc(100% - 15px)
			);
		}

		.bounty-note:nth-child(even) {
			transform: rotate(0.3deg);
		}

		.bounty-note:hover {
			transform: rotate(0deg) scale(1.02);
			z-index: 10;
		}

		.contract-header {
			display: flex;
			justify-content: space-between;
			align-items: center;
			margin-bottom: 8px;
		}

		.contract-type {
			background: linear-gradient(145deg, #8B0000 0%, #DC143C 100%);
			color: #ffd700;
			padding: 3px 8px;
			border-radius: 12px;
			font-size: 0.7em;
			text-transform: uppercase;
			font-weight: bold;
			letter-spacing: 1px;
			border: 1px solid #654321;
		}

		.contract-payment {
			font-size: 1em;
			font-weight: bold;
			color: #8B4513;
		}

		.contract-target {
			font-size: 0.9em;
			font-weight: bold;
			margin-bottom: 6px;
			color: #5d4e37;
		}

		.contract-details {
			color: #6b5b47;
			margin-bottom: 6px;
			line-height: 1.3;
			font-size: 0.8em;
		}

		.contract-instructions {
			background: rgba(139, 69, 19, 0.1);
			border-left: 3px solid #8B4513;
			padding: 6px;
			margin: 8px 0;
			font-style: italic;
			border-radius: 0 3px 3px 0;
			font-size: 0.8em;
		}

		.contract-footer {
			display: flex;
			justify-content: space-between;
			align-items: center;
			margin-top: 8px;
			font-size: 0.8em;
		}

		.contract-actions {
			display: flex;
			gap: 4px;
			margin-top: 8px;
			flex-wrap: wrap;
		}

		.status-available { color: #228B22; font-weight: bold; }
		.status-progress { color: #FF8C00; font-weight: bold; }
		.status-completed { color: #4169E1; font-weight: bold; }
		.status-failed { color: #DC143C; font-weight: bold; }
		.status-pending { color: #8B4513; font-weight: bold; }

		.time-remaining {
			color: #8B4513;
			font-style: italic;
			}

		.scratched-out {
			filter: blur(2px) brightness(0.6);
			user-select: none;
			pointer-events: none;
		}

		.scratched-out::before {
			content: "██████████████████████████████████████████████";
			white-space: pre-wrap;
			color: #3e2723;
			text-decoration: line-through;
			position: absolute;
			top: 0; left: 0;
			width: 100%;
			height: 100%;
			background: repeating-linear-gradient(
				-45deg,
				transparent,
				transparent 2px,
				rgba(0,0,0,0.1) 2px,
				rgba(0,0,0,0.1) 4px
			);
			pointer-events: none;
		}

		.waiting-indicator {
			background: rgba(255, 140, 0, 0.2);
			border-left: 3px solid #FF8C00;
			padding: 6px;
			border-radius: 0 3px 3px 0;
			margin: 8px 0;
			color: #8B4513;
			font-size: 0.8em;
		}

		.contraband-spawned {
			background: rgba(34, 139, 34, 0.2);
			border-left: 3px solid #228B22;
			padding: 6px;
			border-radius: 0 3px 3px 0;
			margin: 8px 0;
			color: #228B22;
			font-size: 0.8em;
		}

		.no-contracts {
			grid-column: 1 / -1;
			text-align: center;
			color: #8B4513;
			padding: 40px;
			font-size: 1.1em;
			font-style: italic;
		}

		.hidden {
			display: none;
		}

		.parchment-form {
			background: linear-gradient(135deg, #f4e4bc 0%, #e6d7b8 100%);
			border: 3px solid #8B4513;
			border-radius: 8px;
			padding: 15px;
			color: #3e2723;
			box-shadow: 0 6px 12px rgba(0,0,0,0.3);
			height: fit-content;
			overflow-y: auto;
		}

		.form-group {
			margin-bottom: 12px;
		}

		.form-label {
			display: block;
			margin-bottom: 4px;
			color: #5d4e37;
			font-weight: 600;
			text-transform: uppercase;
			letter-spacing: 1px;
			font-size: 0.8em;
		}

		.form-input, .form-select, .form-textarea {
			width: 100%;
			padding: 8px;
			background: rgba(255, 255, 255, 0.8);
			border: 2px solid #8B4513;
			border-radius: 4px;
			color: #3e2723;
			font-family: 'Cinzel', serif;
			font-size: 0.9em;
			box-sizing: border-box;
		}

		.form-input:focus, .form-select:focus, .form-textarea:focus {
			outline: none;
			border-color: #ffd700;
			box-shadow: 0 0 6px rgba(255, 215, 0, 0.3);
		}

		.form-textarea {
			resize: vertical;
			min-height: 60px;
		}

		.rules-scroll {
			background: linear-gradient(135deg, #f4e4bc 0%, #e6d7b8 100%);
			border: 3px solid #8B4513;
			border-radius: 8px;
			padding: 15px;
			color: #3e2723;
			box-shadow: 0 6px 12px rgba(0,0,0,0.3);
			height: fit-content;
			overflow-y: auto;
		}

		.rules-scroll p {
			margin: 4px 0;
			line-height: 1.4;
			font-size: 0.85em;
		}

		.nail {
			position: absolute;
			width: 10px;
			height: 10px;
			background: radial-gradient(circle, #654321 0%, #3e2723 100%);
			border-radius: 50%;
			box-shadow: inset 0 2px 4px rgba(0,0,0,0.5);
		}

		.nail-1 { top: 15px; left: 15px; }
		.nail-2 { top: 15px; right: 15px; }
		.nail-3 { bottom: 15px; left: 15px; }
		.nail-4 { bottom: 15px; right: 15px; }

		@media (max-width: 768px) {
			#contracts-list {
				grid-template-columns: 1fr;
			}

			.main-content {
				flex-direction: column;
			}
		}
	</style>
</head>
<body>
	<div class="container">
		<div class="board-frame">
			<div class="nail nail-1"></div>
			<div class="nail nail-2"></div>
			<div class="nail nail-3"></div>
			<div class="nail nail-4"></div>

			<div class="main-content">
				<div class="contracts-section">
					<div class="section-header">
						<h2 class="section-title">Posted Bounties</h2>
						<button class="btn" onclick="toggleCreateForm()">Post Bounty</button>
					</div>

					<div id="contracts-list">
"}

	if(active_contracts.len == 0)
		html += {"
						<div class="no-contracts">
							<p>No bounties currently posted</p>
							<p>Be the first to seek the guilds aid...</p>
						</div>
		"}
	else
		for(var/datum/bounty_contract/contract in active_contracts)
			var/time_remaining = max(0, (contract.creation_time + contract.time_limit - world.time) / 10)
			var/minutes = round(time_remaining / 60)
			var/status_class = "status-available"
			var/status_text = "AVAILABLE"
			var/can_accept = FALSE
			var/can_complete = FALSE
			var/can_verify = FALSE
			var/is_contractor = (user.real_name == contract.contractor_name)

			if(contract.completed)
				status_class = "status-completed"
				status_text = "COMPLETED"
			else if(contract.failed)
				status_class = "status-failed"
				status_text = "FAILED"
			else if(contract.pending_verification)
				status_class = "status-pending"
				status_text = "PENDING"
				if(is_contractor)
					can_verify = TRUE
			else if(contract.assigned_to_harlequinn)
				status_class = "status-progress"
				status_text = "IN PROGRESS"
				if(contract.harlequinn_ckey == user.ckey)
					can_complete = TRUE
			else if(is_bountyhunter && !is_contractor)
				can_accept = TRUE

			var/should_obscure = !is_contractor && !is_bountyhunter
			var/obscure_class = should_obscure ? "scratched-out" : ""
			var/click_handler = (can_accept ? "onclick=\"acceptContract('[contract.contract_id]')\"" : "")
			html += {"<div class=\"bounty-note [obscure_class]\" [click_handler]>"}
			html += {"
							<div class="contract-header">
								<span class="contract-type">[contract.contract_type]</span>
								<span class="contract-payment">[contract.payment] Mammons</span>
							</div>
							<div class="contract-target">Target: [contract.target_name]</div>
							<div class="contract-details">
								By: [should_obscure ? "" : contract.contractor_name]<br>
								Time: [minutes]m
							</div>
			"}

			if(contract.special_instructions)
				html += {"
							<div class="contract-instructions">
								<strong>Instructions:</strong> [contract.special_instructions]
							</div>
				"}

			if(contract.delivery_location)
				html += {"
							<div class="contract-instructions">
								<strong>Location:</strong> [contract.delivery_location]
							</div>
				"}

			if(contract.contract_type == "smuggling" && contract.contraband_type)
				html += {"
							<div class="contract-instructions">
								<strong>Contraband:</strong> [contract.contraband_type]
							</div>
				"}

			if(contract.waiting_for_area_completion)
				html += {"
							<div class="waiting-indicator">
								Awaiting completion at [contract.delivery_location]...
							</div>
				"}

			if(contract.contraband_spawned && !contract.completed)
				html += {"
							<div class="contraband-spawned">
								Goods ready at [contract.spawn_location]
							</div>
				"}

			html += {"
							<div class="contract-footer">
								<span class="[status_class]">[status_text]</span>
								<span class="time-remaining">[minutes]m left</span>
							</div>
			"}

			if(can_accept || can_complete || can_verify)
				html += "<div class=\"contract-actions\">"
				if(can_complete && !contract.is_verification_based())
					html += {"
						<button class="btn btn-small" onclick="completeContract('[contract.contract_id]')">
							Complete
						</button>
					"}

				if(can_complete && contract.is_verification_based())
					html += {"
						<button class="btn btn-small" onclick="requestVerification('[contract.contract_id]')">
							Verify
						</button>
					"}

				if(can_verify)
					html += {"
						<button class="btn btn-verify btn-small" onclick="verifyContract('[contract.contract_id]', true)">
							✓
						</button>
						<button class="btn btn-reject btn-small" onclick="verifyContract('[contract.contract_id]', false)">
							✗
						</button>
					"}

				html += "</div>"

			html += "</div>"

	html += {"
					</div>
				</div>

				<div class="sidebar">
					<div id="create-form" class="hidden">
						<div class="parchment-form">
							<h3 class="section-title">Post New Bounty</h3>
							<form onsubmit="submitContract(event)">
								<div class="form-group">
									<label class="form-label">Bounty Type</label>
									<select class="form-select" id="contract-type" required>
										<option value="">Choose your task...</option>
										<option value="theft">Theft</option>
										<option value="kidnapping">Kidnapping</option>
										<option value="assassination">Assassination</option>
										<option value="smuggling">Smuggling</option>
										<option value="sabotage">Sabotage</option>
										<option value="impersonation">Impersonation</option>
										<option value="burial">Burial Job</option>
									</select>
								</div>
								<div class="form-group" id="target-group">
									<label class="form-label">Target/Description</label>
									<input type="text" class="form-input" id="target-name" required>
								</div>
								<div class="form-group" id="contraband-group" style="display:none;">
									<label class="form-label">Contraband Type</label>
									<select class="form-select" id="contraband-type">
										<option value="">Select contraband...</option>
										[contraband_options]
									</select>
								</div>
								<div class="form-group">
									<label class="form-label">Mammons</label>
									<input type="number" class="form-input" id="payment" min="1" required>
								</div>
								<div class="form-group">
									<label class="form-label">Time Limit (minutes)</label>
									<input type="number" class="form-input" id="time-limit" value="60" min="1" required>
								</div>
								<div class="form-group">
									<label class="form-label">Special Instructions</label>
									<textarea class="form-textarea" id="instructions" placeholder="Additional details..."></textarea>
								</div>
								<div class="form-group" id="location-group" style="display:none;">
									<label class="form-label">Location</label>
									<select class="form-select" id="location">
										<option value="">Select location...</option>
										[location_options]
									</select>
								</div>
								<div class="form-group">
									<button type="submit" class="btn" style="width: 100%; margin-bottom: 8px;">Post Bounty</button>
									<button type="button" class="btn" onclick="toggleCreateForm()" style="width: 100%; background: linear-gradient(145deg, #696969 0%, #2F4F4F 100%);">Cancel</button>
								</div>
							</form>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>

	<script>
		function toggleCreateForm() {
			const form = document.getElementById('create-form');
			const info = document.getElementById('sidebar-info');
			if (form.classList.contains('hidden')) {
				form.classList.remove('hidden');
				info.classList.add('hidden');
			} else {
				form.classList.add('hidden');
				info.classList.remove('hidden');
			}
		}

		document.getElementById('contract-type').addEventListener('change', function() {
			const locationGroup = document.getElementById('location-group');
			const contrabandGroup = document.getElementById('contraband-group');
			const targetGroup = document.getElementById('target-group');

			const needsLocation = \['kidnapping', 'smuggling', 'burial', 'theft'\].includes(this.value);
			const isSmuggling = this.value === 'smuggling';

			locationGroup.style.display = needsLocation ? 'block' : 'none';
			contrabandGroup.style.display = isSmuggling ? 'block' : 'none';

			if (needsLocation) {
				document.getElementById('location').required = true;
			} else {
				document.getElementById('location').required = false;
			}

			if (isSmuggling) {
				document.getElementById('contraband-type').required = true;
				document.getElementById('target-name').required = false;
				document.getElementById('target-name').value = 'Contraband Delivery';
				targetGroup.style.display = 'none';
			} else {
				document.getElementById('contraband-type').required = false;
				document.getElementById('target-name').required = true;
				targetGroup.style.display = 'block';
			}
		});

		function submitContract(event) {
			event.preventDefault();

			const formData = {
				type: document.getElementById('contract-type').value,
				target: document.getElementById('target-name').value,
				payment: parseInt(document.getElementById('payment').value),
				time_limit: parseInt(document.getElementById('time-limit').value),
				instructions: document.getElementById('instructions').value,
				location: document.getElementById('location').value,
				contraband: document.getElementById('contraband-type').value
			};

			window.location.href = 'byond://?src=' + encodeURIComponent('[REF(src)]') + '&action=create_contract&' +
				Object.keys(formData).map(key => key + '=' + encodeURIComponent(formData\[key\])).join('&');
		}

		function acceptContract(contractId) {
			window.location.href = 'byond://?src=' + encodeURIComponent('[REF(src)]') + '&action=accept_contract&contract_id=' + encodeURIComponent(contractId);
		}

		function completeContract(contractId) {
			window.location.href = 'byond://?src=' + encodeURIComponent('[REF(src)]') + '&action=complete_contract&contract_id=' + encodeURIComponent(contractId);
		}

		function requestVerification(contractId) {
			window.location.href = 'byond://?src=' + encodeURIComponent('[REF(src)]') + '&action=request_verification&contract_id=' + encodeURIComponent(contractId);
		}

		function verifyContract(contractId, success) {
			window.location.href = 'byond://?src=' + encodeURIComponent('[REF(src)]') + '&action=verify_contract&contract_id=' + encodeURIComponent(contractId) + '&success=' + (success ? '1' : '0');
		}
	</script>
</body>
</html>
	"}
	return html

/obj/structure/bounty_board/Topic(href, href_list)
	if(!usr || !usr.client)
		return

	if(href_list["action"])
		switch(href_list["action"])
			if("create_contract")
				create_contract_from_form(usr, href_list)
			if("accept_contract")
				accept_contract(usr, href_list["contract_id"])
			if("complete_contract")
				complete_contract_manual(usr, href_list["contract_id"])
			if("request_verification")
				request_contract_verification(usr, href_list["contract_id"])
			if("verify_contract")
				verify_contract_completion(usr, href_list["contract_id"], text2num(href_list["success"]))

/obj/structure/bounty_board/proc/create_contract_from_form(mob/user, list/params)
	var/contract_type = params["type"]
	var/target_name = params["target"]
	var/payment = text2num(params["payment"])
	var/time_limit = text2num(params["time_limit"])
	var/special_instructions = params["instructions"]
	var/delivery_location = params["location"]
	var/contraband_type = params["contraband"]

	if(!contract_type || !payment || payment <= 0)
		to_chat(user, span_warning("Invalid contract parameters!"))
		return

	// Special validation for smuggling contracts
	if(contract_type == "smuggling")
		if(!contraband_type || !delivery_location)
			to_chat(user, span_warning("Smuggling contracts require contraband type and delivery location!"))
			return
		target_name = "Contraband Delivery: [contraband_type]"
	else if(!target_name)
		to_chat(user, span_warning("Target name is required!"))
		return

	// Verify user has funds
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(get_mammons_in_atom(H) < payment)
			to_chat(user, span_warning("Insufficient funds!"))
			return
		// Deduct payment and hold in escrow
		remove_mammons_from_atom(H, payment)

	// Create the contract
	var/datum/bounty_contract/new_contract = new()
	new_contract.contract_type = contract_type
	new_contract.target_name = target_name
	new_contract.payment = payment
	new_contract.time_limit = time_limit * 60 * 10 // Convert to deciseconds
	new_contract.special_instructions = special_instructions
	new_contract.delivery_location = delivery_location
	new_contract.contraband_type = contraband_type
	new_contract.contractor_name = user.real_name
	new_contract.contractor_ckey = user.ckey
	new_contract.creation_time = world.time
	new_contract.contract_id = "[new_contract.contract_type]_[world.time]_[rand(1000,9999)]"

	active_contracts += new_contract
	total_bounty_pool += payment

	to_chat(user, span_notice("Contract posted successfully! Payment held in escrow."))

	// Refresh the interface
	ui_interact(user)

/obj/structure/bounty_board/proc/accept_contract(mob/user, contract_id)
	if(!is_bounty_hunter(user))
		to_chat(user, span_warning("Only bounty hunters can accept contracts!"))
		return

	var/datum/bounty_contract/contract = find_contract_by_id(contract_id)
	if(!contract)
		to_chat(user, span_warning("Contract not found!"))
		return

	if(contract.assigned_to_harlequinn)
		to_chat(user, span_warning("This contract is already assigned!"))
		return

	if(contract.contractor_ckey == user.ckey)
		to_chat(user, span_warning("You cannot accept your own contract!"))
		return

	// Check reputation requirements
	var/required_rep = get_required_reputation(contract.contract_type)
	if(get_reputation(user) < required_rep)
		to_chat(user, span_warning("Your reputation is too low for this type of contract! (Required: [required_rep])"))
		return

	contract.assign_to_harlequinn(user)

	// If it's a smuggling contract, spawn the contraband
	if(contract.contract_type == "smuggling" && contract.contraband_type)
		spawn_contraband_for_contract(contract, user)

	to_chat(user, span_notice("Contract accepted! Good hunting."))
	ui_interact(user)

/obj/structure/bounty_board/proc/get_required_reputation(contract_type)
	switch(contract_type)
		if("theft", "burial")
			return -10 // Even low rep can do these
		if("smuggling", "kidnapping")
			return 0 // Neutral reputation required
		if("sabotage", "impersonation")
			return 10 // Good reputation required
		if("assassination")
			return 25 // High reputation required
		else
			return 0

/obj/structure/bounty_board/proc/complete_contract_manual(mob/user, contract_id)
	var/datum/bounty_contract/contract = find_contract_by_id(contract_id)
	if(!contract)
		return

	if(contract.harlequinn_ckey != user.ckey)
		to_chat(user, span_warning("This is not your contract!"))
		return

	if(contract.is_area_based())
		to_chat(user, span_warning("This contract will complete automatically when the task is done at the specified location!"))
		return

	if(contract.is_verification_based())
		to_chat(user, span_warning("This contract requires verification from the contractor!"))
		return

	contract.complete_contract(src)
	modify_reputation(user, 5) // Gain reputation for completing contracts
	to_chat(user, span_notice("Contract completed!"))
	ui_interact(user)

/obj/structure/bounty_board/proc/request_contract_verification(mob/user, contract_id)
	var/datum/bounty_contract/contract = find_contract_by_id(contract_id)
	if(!contract)
		return

	if(contract.harlequinn_ckey != user.ckey)
		to_chat(user, span_warning("This is not your contract!"))
		return

	contract.pending_verification = TRUE
	to_chat(user, span_notice("Verification requested! The contractor will need to confirm completion."))

	// Notify the contractor if they're online
	for(var/mob/M in GLOB.player_list)
		if(M.ckey == contract.contractor_ckey)
			to_chat(M, span_notice("Contract verification requested for '[contract.target_name]'. Check the bounty board to verify."))
			break

	ui_interact(user)

/obj/structure/bounty_board/proc/verify_contract_completion(mob/user, contract_id, success)
	var/datum/bounty_contract/contract = find_contract_by_id(contract_id)
	if(!contract)
		return

	if(contract.contractor_ckey != user.ckey)
		to_chat(user, span_warning("You are not the contractor for this job!"))
		return

	if(!contract.pending_verification)
		to_chat(user, span_warning("This contract is not pending verification!"))
		return

	if(success)
		contract.complete_contract(src)
		// Find the harlequinn and give them reputation
		for(var/mob/M in GLOB.player_list)
			if(M.ckey == contract.harlequinn_ckey)
				modify_reputation(M, 10) // More reputation for verified completion
				to_chat(M, span_notice("Your contract has been verified as successful!"))
				break
		to_chat(user, span_notice("Contract verified as successful!"))
	else
		contract.fail_contract(src)
		// Find the harlequinn and reduce their reputation
		for(var/mob/M in GLOB.player_list)
			if(M.ckey == contract.harlequinn_ckey)
				modify_reputation(M, -15) // Penalty for failed contracts
				to_chat(M, span_warning("Your contract has been marked as failed!"))
				break
		to_chat(user, span_notice("Contract marked as failed."))

	ui_interact(user)

/obj/structure/bounty_board/proc/find_contract_by_id(contract_id)
	for(var/datum/bounty_contract/contract in active_contracts)
		if(contract.contract_id == contract_id)
			return contract
	return null

/obj/structure/bounty_board/proc/is_bounty_hunter(mob/user)
	return user.mind?.has_antag_datum(/datum/antagonist/harlequinn) || user.mind?.has_antag_datum(/datum/antagonist/bandit) || user.mind?.has_antag_datum(/datum/antagonist/assassin)

/obj/structure/bounty_board/proc/spawn_contraband_for_contract(datum/bounty_contract/contract, mob/harlequinn)
	if(!contract.contraband_type || contract.contraband_spawned)
		return

	// Get the supply pack type
	var/pack_type = contraband_packs[contract.contraband_type]
	if(!pack_type)
		to_chat(harlequinn, span_warning("Error: Contraband type not found!"))
		return

	// Choose a random spawn location (excluding the delivery location)
	var/list/available_locations = list()
	for(var/location_name in delivery_locations)
		if(location_name != contract.delivery_location)
			available_locations += delivery_locations[location_name]

	if(!available_locations.len)
		to_chat(harlequinn, span_warning("Error: No spawn locations available!"))
		return

	var/obj/effect/landmark/bounty_location/spawn_location = pick(available_locations)

	// Create the smuggling pouch with contraband
	var/obj/item/storage/smuggling_pouch/pouch = new(spawn_location.loc)
	pouch.contract_id = contract.contract_id
	pouch.delivery_location = contract.delivery_location

	// Create the supply pack and add its contents to the pouch
	var/datum/supply_pack/pack = new pack_type()

	for(var/item_type in pack.contains)
		var/obj/item = new item_type(pouch)
		SEND_SIGNAL(pouch, COMSIG_TRY_STORAGE_INSERT, item, null, TRUE, TRUE)

	// Mark contract as having contraband spawned
	contract.contraband_spawned = TRUE
	contract.spawn_location = spawn_location.location_name

	// Notify Harlequinn
	to_chat(harlequinn, span_notice("A smuggling pouch containing [contract.contraband_type] has been placed at [spawn_location.location_name]. Deliver it to [contract.delivery_location] to complete the contract."))

	// Clean up the pack datum
	qdel(pack)

// Called by external systems when area-based actions occur
/obj/structure/bounty_board/proc/check_area_completion(mob/harlequinn, obj/effect/landmark/bounty_location/location)
	for(var/datum/bounty_contract/contract in active_contracts)
		if(!contract.assigned_to_harlequinn || contract.completed || contract.failed)
			continue

		if(contract.harlequinn_ckey != harlequinn.ckey)
			continue

		if(contract.delivery_location == location.location_name)
			if(get_dist(harlequinn, location) <= location.completion_range)
				// Different completion logic based on contract type
				switch(contract.contract_type)
					if("smuggling")
						// Check if they have the smuggling pouch
						var/obj/item/storage/smuggling_pouch/pouch = locate() in harlequinn.get_contents()
						if(pouch && pouch.contract_id == contract.contract_id)
							contract.complete_contract(src)
							modify_reputation(harlequinn, 8)
							to_chat(harlequinn, span_notice("Smuggling contract completed! Contraband delivered successfully."))
							qdel(pouch)
						else
							to_chat(harlequinn, span_warning("You need to bring the smuggling pouch to complete this contract!"))

					if("kidnapping")
						// Start kidnapping timer
						if(!contract.kidnapping_timer_active)
							contract.start_kidnapping_timer(harlequinn, location, src)

					if("burial")
						// Check if they're carrying a corpse or have burial tools
						var/has_corpse = FALSE
						var/has_shovel = FALSE
						for(var/obj/item in harlequinn.get_contents())
							if(istype(item, /obj/item/weapon/shovel))
								has_shovel = TRUE
							// Add corpse checking logic here based on your game's corpse types

						if(has_shovel) // Simplified for now
							contract.complete_contract(src)
							modify_reputation(harlequinn, 6)
							to_chat(harlequinn, span_notice("Burial contract completed at [location.location_name]!"))
						else
							to_chat(harlequinn, span_warning("You need proper burial tools to complete this contract!"))

					if("theft")
						// Generic area completion for theft
						contract.complete_contract(src)
						modify_reputation(harlequinn, 5)
						to_chat(harlequinn, span_notice("Theft contract completed at [location.location_name]!"))

// Process contract timeouts and kidnapping timers
/obj/structure/bounty_board/proc/process_contracts()
	for(var/datum/bounty_contract/contract in active_contracts)
		// Check for timeouts
		if(world.time > contract.creation_time + contract.time_limit)
			if(!contract.completed && !contract.failed)
				contract.fail_contract(src)
				// Reduce reputation for timeout
				if(contract.assigned_to_harlequinn)
					for(var/mob/M in GLOB.player_list)
						if(M.ckey == contract.harlequinn_ckey)
							modify_reputation(M, -10)
							to_chat(M, span_warning("Contract '[contract.target_name]' has timed out!"))
							break

		// Process kidnapping timers
		if(contract.kidnapping_timer_active && world.time > contract.kidnapping_completion_time)
			contract.complete_kidnapping(src)

/datum/bounty_contract
	var/contract_id
	var/contract_type // theft, kidnapping, assassination, etc.
	var/target_name
	var/payment
	var/time_limit
	var/special_instructions
	var/delivery_location
	var/contraband_type // For smuggling contracts
	var/contractor_name
	var/contractor_ckey
	var/creation_time
	var/completed = FALSE
	var/failed = FALSE
	var/assigned_to_harlequinn = FALSE
	var/harlequinn_ckey
	var/waiting_for_area_completion = FALSE
	var/contraband_spawned = FALSE // For smuggling contracts
	var/spawn_location // Where contraband was spawned
	var/pending_verification = FALSE
	// Kidnapping timer variables
	var/kidnapping_timer_active = FALSE
	var/kidnapping_completion_time = 0
	var/kidnapping_target_location

/datum/bounty_contract/proc/is_area_based()
	return contract_type in list("kidnapping", "smuggling", "burial", "theft")

/datum/bounty_contract/proc/is_verification_based()
	return contract_type in list("assassination", "sabotage", "impersonation")

/datum/bounty_contract/proc/assign_to_harlequinn(mob/harlequinn)
	assigned_to_harlequinn = TRUE
	harlequinn_ckey = harlequinn.ckey
	if(is_area_based() && delivery_location)
		waiting_for_area_completion = TRUE

/datum/bounty_contract/proc/complete_contract(obj/structure/bounty_board/board)
	completed = TRUE
	waiting_for_area_completion = FALSE
	pending_verification = FALSE
	kidnapping_timer_active = FALSE

	// Pay the harlequinn
	if(harlequinn_ckey)
		for(var/mob/M in GLOB.player_list)
			if(M.ckey == harlequinn_ckey && ishuman(M))
				var/mob/living/carbon/human/H = M
				add_mammons_to_atom(H, payment)
				to_chat(H, span_notice("You have been paid [payment] Mammons for completing the contract!"))
				break

	// Remove from active contracts and add to completed
	if(board)
		board.active_contracts -= src
		board.completed_contracts += src
		board.total_bounty_pool -= payment

/datum/bounty_contract/proc/fail_contract(obj/structure/bounty_board/board)
	failed = TRUE
	waiting_for_area_completion = FALSE
	pending_verification = FALSE
	kidnapping_timer_active = FALSE

	// Return payment to contractor
	if(contractor_ckey)
		for(var/mob/M in GLOB.player_list)
			if(M.ckey == contractor_ckey && ishuman(M))
				var/mob/living/carbon/human/H = M
				add_mammons_to_atom(H, payment)
				to_chat(H, span_notice("Your contract has failed. [payment] Mammons have been returned."))
				break

	// Remove from active contracts
	if(board)
		board.active_contracts -= src
		board.total_bounty_pool -= payment

/datum/bounty_contract/proc/start_kidnapping_timer(mob/harlequinn, obj/effect/landmark/bounty_location/location, obj/structure/bounty_board/board)
	kidnapping_timer_active = TRUE
	kidnapping_completion_time = world.time + 300 // 30 seconds
	kidnapping_target_location = location

	to_chat(harlequinn, span_notice("Kidnapping in progress... Stay in the area for 30 seconds to complete the contract."))

	// Start a timer to check if they stay in the area
	spawn(50) // Check every 5 seconds
		while(kidnapping_timer_active && world.time < kidnapping_completion_time)
			if(get_dist(harlequinn, location) > location.completion_range)
				kidnapping_timer_active = FALSE
				to_chat(harlequinn, span_warning("You moved too far from the target area! Kidnapping contract failed."))
				return
			sleep(50)

/datum/bounty_contract/proc/complete_kidnapping(obj/structure/bounty_board/board)
	if(!kidnapping_timer_active)
		return

	kidnapping_timer_active = FALSE
	complete_contract(board)

	// Find the harlequinn and notify them
	for(var/mob/M in GLOB.player_list)
		if(M.ckey == harlequinn_ckey)
			board.modify_reputation(M, 7)
			to_chat(M, span_notice("Kidnapping contract completed! Target successfully acquired."))
			break

// Smuggling pouch item
/obj/item/storage/smuggling_pouch
	name = "smuggling pouch"
	desc = "A discrete pouch containing contraband goods. Handle with care."
	icon = 'icons/roguetown/clothing/storage.dmi'
	icon_state = "pouch"
	w_class = WEIGHT_CLASS_NORMAL
	var/contract_id
	var/delivery_location
	var/dropped_at_location = FALSE

/obj/item/storage/smuggling_pouch/dropped(mob/user)
	. = ..()
	if(!contract_id || dropped_at_location)
		return

	// Check if dropped at the correct delivery location
	for(var/obj/effect/landmark/bounty_location/location in range(6, src))
		if(location.location_name == delivery_location)
			dropped_at_location = TRUE
			visible_message(span_notice("[src] has been delivered to [delivery_location]."))

			for(var/obj/structure/bounty_board/board in GLOB.bounty_boards)
				var/datum/bounty_contract/contract = board.find_contract_by_id(contract_id)
				if(contract && contract.assigned_to_harlequinn)
					contract.complete_contract(board)
					for(var/mob/M in GLOB.player_list)
						if(M.ckey == contract.harlequinn_ckey)
							board.modify_reputation(M, 8)
							to_chat(M, span_notice("Smuggling contract auto-completed! Pouch delivered successfully."))
							break

			break

// Landmark for bounty locations
/obj/effect/landmark/bounty_location
	name = "bounty location"
	var/location_name = "Unknown Location"
	var/completion_range = 3 // Tiles within this range count as "at the location"

/obj/effect/landmark/bounty_location/Initialize()
	. = ..()
	LAZYADD(GLOB.bounty_locations, src)
	if(!location_name || location_name == "Unknown Location")
		location_name = name

// Example locations - add these around your map
/obj/effect/landmark/bounty_location/bathhouse
	name = "Behind the Bathhouse"
	location_name = "Behind the Bathhouse"
	completion_range = 5

/obj/effect/landmark/bounty_location/graveyard
	name = "Old Graveyard"
	location_name = "Old Graveyard"
	completion_range = 4

/obj/effect/landmark/bounty_location/warehouse
	name = "Abandoned Warehouse"
	location_name = "Abandoned Warehouse"
	completion_range = 6

/obj/effect/landmark/bounty_location/docks
	name = "Harbor Docks"
	location_name = "Harbor Docks"
	completion_range = 8

/obj/effect/landmark/bounty_location/alley
	name = "Dark Alley"
	location_name = "Dark Alley"
	completion_range = 3

/proc/process_bounty_system()
	for(var/obj/structure/bounty_board/board in GLOB.bounty_boards)
		board.process_contracts()

		// Check area completions for all harlequinns
		for(var/mob/living/harlequinn in GLOB.player_list)
			if(!board.is_bounty_hunter(harlequinn))
				continue
			for(var/obj/effect/landmark/bounty_location/location in GLOB.bounty_locations)
				board.check_area_completion(harlequinn, location)


/proc/remove_mammons_from_atom(atom/A, amount)
	return

/proc/add_mammons_to_atom(atom/A, amount)
	return
