// New unified clan menu interface
/datum/clan_menu_interface
	var/mob/living/carbon/human/user
	var/datum/clan/user_clan
	var/list/datum/coven/user_covens
	var/current_coven // Currently selected coven for research view

/datum/clan_menu_interface/New(mob/living/carbon/human/target_user)
	user = target_user
	user_clan = user.clan
	user_covens = user.covens
	..()

/datum/clan_menu_interface/proc/generate_interface()
	// Send required resources
	user << browse_rsc('html/research_hover.png')
	user << browse_rsc('html/research_base.png')
	user << browse_rsc('html/research_known.png')
	user << browse_rsc('html/research_selected.png')
	user << browse_rsc('html/KettleParallaxBG.png')
	user << browse_rsc('html/KettleParallaxNeb.png')

	var/html = generate_main_html()
	user << browse(html, "window=clan_menu;size=1400x900;can_resize=1")

/datum/clan_menu_interface/proc/generate_main_html()
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

			.clan-header {
				position: fixed;
				top: 0;
				left: 0;
				right: 0;
				height: 80px;
				background: linear-gradient(135deg, rgba(139, 69, 19, 0.95), rgba(160, 82, 45, 0.95));
				border-bottom: 3px solid #8B4513;
				z-index: 1001;
				display: flex;
				align-items: center;
				padding: 0 30px;
				box-shadow: 0 4px 15px rgba(0,0,0,0.6);
			}

			.clan-info {
				display: flex;
				align-items: center;
				gap: 30px;
				flex-grow: 1;
			}

			.clan-name {
				font-size: 28px;
				font-weight: bold;
				color: #FFD700;
				text-shadow: 2px 2px 6px rgba(0,0,0,0.8);
			}

			.clan-desc {
				font-size: 14px;
				color: #DDD;
				max-width: 400px;
				font-style: italic;
			}

			.header-controls {
				display: flex;
				gap: 15px;
			}

			.header-btn {
				background: rgba(0,0,0,0.4);
				border: 2px solid #8B4513;
				color: #FFD700;
				padding: 10px 20px;
				border-radius: 8px;
				cursor: pointer;
				font-weight: bold;
				transition: all 0.3s ease;
			}

			.header-btn:hover {
				background: rgba(160, 82, 45, 0.6);
				transform: translateY(-2px);
			}

			.main-container {
				display: flex;
				margin-top: 80px;
				height: calc(100vh - 80px);
			}

			.sidebar {
				width: 300px;
				background: linear-gradient(180deg, rgba(139, 69, 19, 0.3), rgba(0, 0, 0, 0.8));
				border-right: 2px solid #8B4513;
				padding: 20px;
				overflow-y: auto;
			}

			.sidebar h3 {
				color: #FFD700;
				border-bottom: 2px solid #8B4513;
				padding-bottom: 8px;
				margin-bottom: 15px;
			}

			.coven-list {
				list-style: none;
				padding: 0;
				margin: 0;
			}

			.coven-item {
				background: rgba(0,0,0,0.4);
				border: 1px solid #8B4513;
				border-radius: 8px;
				margin-bottom: 10px;
				padding: 15px;
				cursor: pointer;
				transition: all 0.3s ease;
				position: relative;
			}

			.coven-item:hover {
				background: rgba(139, 69, 19, 0.4);
				transform: translateX(5px);
			}

			.coven-item.selected {
				background: rgba(160, 82, 45, 0.5);
				border-color: #FFD700;
				box-shadow: 0 0 10px rgba(255, 215, 0, 0.3);
			}

			.coven-name {
				font-weight: bold;
				color: #FFD700;
				font-size: 16px;
				margin-bottom: 5px;
			}

			.coven-stats {
				font-size: 12px;
				color: #CCC;
				display: flex;
				justify-content: space-between;
				margin-bottom: 8px;
			}

			.coven-progress {
				width: 100%;
				height: 6px;
				background: rgba(0,0,0,0.5);
				border-radius: 3px;
				overflow: hidden;
				margin-bottom: 5px;
			}

			.coven-progress-fill {
				height: 100%;
				background: linear-gradient(90deg, #FF6B35, #F7931E);
				border-radius: 3px;
				transition: width 0.3s ease;
			}

			.research-points {
				background: rgba(106, 90, 205, 0.3);
				color: #ADD8E6;
				padding: 4px 8px;
				border-radius: 4px;
				font-size: 11px;
				display: inline-block;
			}

			.content-area {
				flex: 1;
				position: relative;
				overflow: hidden;
			}

			.welcome-screen {
				display: flex;
				flex-direction: column;
				align-items: center;
				justify-content: center;
				height: 100%;
				text-align: center;
				padding: 40px;
			}

			.welcome-screen h2 {
				color: #FFD700;
				font-size: 36px;
				margin-bottom: 20px;
				text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
			}

			.welcome-screen p {
				font-size: 18px;
				color: #CCC;
				max-width: 600px;
				line-height: 1.6;
				margin-bottom: 30px;
			}

			.clan-emblem {
				width: 120px;
				height: 120px;
				background: rgba(139, 69, 19, 0.3);
				border: 3px solid #8B4513;
				border-radius: 50%;
				display: flex;
				align-items: center;
				justify-content: center;
				font-size: 48px;
				color: #FFD700;
				margin-bottom: 30px;
			}

			/* Research tree container that will be populated when coven is selected */
			.research-tree-container {
				width: 100%;
				height: 100%;
				position: relative;
			}

			.close-btn {
				position: fixed;
				bottom: 30px;
				right: 30px;
				background: rgba(139, 69, 19, 0.9);
				border: 2px solid #8B4513;
				color: #FFD700;
				padding: 15px 25px;
				border-radius: 8px;
				cursor: pointer;
				font-weight: bold;
				z-index: 1000;
				transition: all 0.3s ease;
			}

			.close-btn:hover {
				background: rgba(160, 82, 45, 0.9);
				transform: translateY(-3px);
			}
		</style>
	</head>
	<body>
		<div class="clan-header">
			<div class="clan-info">
				<div class="clan-name">[user_clan ? user_clan.name : "Unknown Clan"]</div>
				<div class="clan-desc">[user_clan ? user_clan.desc : ""]</div>
			</div>
			<div class="header-controls">
				<a href="?src=[REF(src)];action=refresh_clan_menu" class="header-btn">Refresh</a>
			</div>
		</div>

		<div class="main-container">
			<div class="sidebar">
				<h3>Your Covens</h3>
				<ul class="coven-list">
					[generate_coven_list_html()]
				</ul>
			</div>

			<div class="content-area" id="content-area">
				<div class="welcome-screen">
					<div class="clan-emblem">🗡️</div>
					<h2>Welcome to your Clan</h2>
					<p>Select a coven from the sidebar to view its research tree and manage your powers.
					Each coven represents a different aspect of your vampiric abilities.</p>
					<p>Use your research points to unlock new powers and enhance existing ones.
					Gain experience through using your abilities to level up your covens.</p>
				</div>
			</div>
		</div>

		<a href="byond://?src=[REF(src)];action=close_clan_menu" class="close-btn">Close</a>

		<script>
			function selectCoven(covenName) {
				// Remove previous selection
				document.querySelectorAll('.coven-item').forEach(item => {
					item.classList.remove('selected');
				});

				// Add selection to clicked item
				event.target.closest('.coven-item').classList.add('selected');

				// Load coven research tree via BYOND - use user reference instead of src
				window.location.href = 'byond://?src=[REF(src)];action=load_coven_tree;coven_name=' + encodeURIComponent(covenName);
			}
		</script>
	</body>
	</html>
	"}

	return html

/datum/clan_menu_interface/proc/generate_coven_list_html()
	var/html = ""

	if(!user_covens || !length(user_covens))
		return "<li style='color: #999; padding: 20px; text-align: center;'>No covens available</li>"

	for(var/coven_name in user_covens)
		var/datum/coven/coven = user_covens[coven_name]
		var/experience_percent = coven.experience_needed > 0 ? round((coven.experience / coven.experience_needed) * 100, 1) : 100

		html += {"
		<li class="coven-item" onclick="selectCoven('[coven_name]')">
			<div class="coven-name">[coven.name]</div>
			<div class="coven-stats">
				<span>Level [coven.level]/[coven.max_level]</span>
				<span>[coven.experience]/[coven.experience_needed] XP</span>
			</div>
			<div class="coven-progress">
				<div class="coven-progress-fill" style="width: [experience_percent]%"></div>
			</div>
			<div class="research-points">RP: [coven.research_points]</div>
		</li>
		"}

	return html

/datum/clan_menu_interface/proc/generate_combined_html(research_content)
	// Generate the full interface with the research tree loaded
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

			.clan-header {
				position: fixed;
				top: 0;
				left: 0;
				right: 0;
				height: 80px;
				background: linear-gradient(135deg, rgba(139, 69, 19, 0.95), rgba(160, 82, 45, 0.95));
				border-bottom: 3px solid #8B4513;
				z-index: 1001;
				display: flex;
				align-items: center;
				padding: 0 30px;
				box-shadow: 0 4px 15px rgba(0,0,0,0.6);
			}

			.clan-info {
				display: flex;
				align-items: center;
				gap: 30px;
				flex-grow: 1;
			}

			.clan-name {
				font-size: 28px;
				font-weight: bold;
				color: #FFD700;
				text-shadow: 2px 2px 6px rgba(0,0,0,0.8);
			}

			.clan-desc {
				font-size: 14px;
				color: #DDD;
				max-width: 400px;
				font-style: italic;
			}

			.header-controls {
				display: flex;
				gap: 15px;
			}

			.header-btn {
				background: rgba(0,0,0,0.4);
				border: 2px solid #8B4513;
				color: #FFD700;
				padding: 10px 20px;
				border-radius: 8px;
				cursor: pointer;
				font-weight: bold;
				transition: all 0.3s ease;
			}

			.header-btn:hover {
				background: rgba(160, 82, 45, 0.6);
				transform: translateY(-2px);
			}

			.main-container {
				display: flex;
				margin-top: 80px;
				height: calc(100vh - 80px);
			}

			.sidebar {
				width: 300px;
				background: linear-gradient(180deg, rgba(139, 69, 19, 0.3), rgba(0, 0, 0, 0.8));
				border-right: 2px solid #8B4513;
				padding: 20px;
				overflow-y: auto;
				z-index: 100;
			}

			.sidebar h3 {
				color: #FFD700;
				border-bottom: 2px solid #8B4513;
				padding-bottom: 8px;
				margin-bottom: 15px;
			}

			.coven-list {
				list-style: none;
				padding: 0;
				margin: 0;
			}

			.coven-item {
				background: rgba(0,0,0,0.4);
				border: 1px solid #8B4513;
				border-radius: 8px;
				margin-bottom: 10px;
				padding: 15px;
				cursor: pointer;
				transition: all 0.3s ease;
				position: relative;
			}

			.coven-item:hover {
				background: rgba(139, 69, 19, 0.4);
				transform: translateX(5px);
			}

			.coven-item.selected {
				background: rgba(160, 82, 45, 0.5);
				border-color: #FFD700;
				box-shadow: 0 0 10px rgba(255, 215, 0, 0.3);
			}

			.coven-item .coven-name {
				font-weight: bold;
				color: #FFD700;
				font-size: 16px;
				margin-bottom: 5px;
			}

			.coven-stats {
				font-size: 12px;
				color: #CCC;
				display: flex;
				justify-content: space-between;
				margin-bottom: 8px;
			}

			.coven-progress {
				width: 100%;
				height: 6px;
				background: rgba(0,0,0,0.5);
				border-radius: 3px;
				overflow: hidden;
				margin-bottom: 5px;
			}

			.coven-progress-fill {
				height: 100%;
				background: linear-gradient(90deg, #FF6B35, #F7931E);
				border-radius: 3px;
				transition: width 0.3s ease;
			}

			.research-points {
				background: rgba(106, 90, 205, 0.3);
				color: #ADD8E6;
				padding: 4px 8px;
				border-radius: 4px;
				font-size: 11px;
				display: inline-block;
			}

			.content-area {
				flex: 1;
				position: relative;
				overflow: hidden;
			}

			/* Research tree styles integrated */
			.parallax-container {
				position: absolute;
				top: 0;
				left: 0;
				width: 100%;
				height: 100%;
				overflow: hidden;
				z-index: 1;
			}

			.parallax-layer {
				position: absolute;
				width: 120%;
				height: 120%;
				background-repeat: repeat;
			}

			.parallax-bg {
				background-image: url('KettleParallaxBG.png');
				background-size: cover;
				background-repeat: no-repeat;
				background-position: center;
			}

			.parallax-stars-1 {
				background: radial-gradient(ellipse at center,
					rgba(139, 69, 19, 0.3) 0%,
					rgba(160, 82, 45, 0.2) 40%,
					transparent 70%),
					radial-gradient(circle at 20% 30%, rgba(255, 215, 0, 0.8) 1px, transparent 2px),
					radial-gradient(circle at 80% 20%, rgba(139, 69, 19, 0.6) 1px, transparent 2px),
					radial-gradient(circle at 60% 80%, rgba(160, 82, 45, 0.4) 2px, transparent 4px);
				background-size: 800px 600px, 200px 150px, 300px 200px, 250px 180px;
				opacity: 0.8;
			}

			.parallax-neb {
				background-image: url('KettleParallaxNeb.png');
				background-size: cover;
				background-repeat: no-repeat;
				background-position: center;
				opacity: 0.4;
			}

			.research-container {
				position: relative;
				width: 100%;
				height: 100%;
				overflow: hidden;
				cursor: grab;
				z-index: 10;
			}

			.research-container.dragging { cursor: grabbing; }

			.research-canvas {
				position: absolute;
				transform-origin: 0 0;
			}

			.connection-line {
				position: absolute;
				height: 3px;
				background: linear-gradient(90deg,
					rgba(139, 69, 19, 0.8) 0%,
					rgba(160, 82, 45, 0.6) 50%,
					rgba(139, 69, 19, 0.4) 100%);
				transform-origin: left center;
				z-index: 5;
				border-radius: 1px;
				box-shadow: 0 0 4px rgba(139, 69, 19, 0.3);
			}

			.connection-line.unlocked {
				background: linear-gradient(90deg,
					rgba(255, 215, 0, 0.8) 0%,
					rgba(255, 140, 0, 0.6) 50%,
					rgba(255, 215, 0, 0.4) 100%);
				box-shadow: 0 0 4px rgba(255, 215, 0, 0.3);
			}

			.research-node {
				background: url('research_base.png');
				position: absolute;
				width: 32px;
				height: 32px;
				cursor: pointer;
				transition: all 0.15s ease;
				display: flex;
				align-items: center;
				justify-content: center;
				z-index: 10;
				border-radius: 8px;
				border: 2px solid #8B4513;
			}

			.research-node img {
				width: 40px;
				height: 40px;
				object-fit: contain;
			}

			.research-node.unlocked {
				background: url('research_known.png');
				border-color: #FFD700;
			}

			.research-node.unlocked img {
				filter: hue-rotate(45deg) brightness(1.3) drop-shadow(0 0 6px rgba(255, 215, 0, 0.8));
			}

			.research-node.available {
				border-color: #32CD32;
				box-shadow: 0 0 8px rgba(50, 205, 50, 0.5);
			}

			.research-node.available img {
				filter: hue-rotate(90deg) brightness(1.1) drop-shadow(0 0 4px rgba(50, 205, 50, 0.6));
			}

			.research-node.locked img {
				opacity: 0.4;
				filter: grayscale(100%) brightness(0.7);
			}

			.research-node.power-node {
				border-color: #FF6B35;
			}

			.research-node.enhancement-node {
				border-color: #6a5acd;
				border-radius: 50%;
			}

			.research-node:hover {
				background: url('research_hover.png');
				transform: scale(1.15);
				z-index: 100;
			}

			.power-level {
				position: absolute;
				top: -5px;
				right: -5px;
				background: #8B4513;
				color: #FFD700;
				border-radius: 50%;
				width: 16px;
				height: 16px;
				font-size: 10px;
				font-weight: bold;
				display: flex;
				align-items: center;
				justify-content: center;
				border: 1px solid #FFD700;
			}

			.tooltip {
				position: absolute;
				background: rgba(139, 69, 19, 0.95);
				border: 2px solid #8B4513;
				border-radius: 12px;
				padding: 15px;
				max-width: 350px;
				z-index: 1000;
				pointer-events: none;
				box-shadow: 0 8px 24px rgba(0,0,0,0.7);
				backdrop-filter: blur(5px);
			}

			.tooltip h3 {
				margin: 0 0 10px 0;
				color: #FFD700;
				text-shadow: 0 0 4px rgba(255,215,0,0.5);
			}

			.tooltip p {
				margin: 8px 0;
				font-size: 13px;
				line-height: 1.4;
			}

			.tooltip .power-stats {
				background: rgba(0,0,0,0.3);
				padding: 8px;
				border-radius: 6px;
				margin: 8px 0;
			}

			.tooltip .requirements {
				color: #FF6B6B;
				background: rgba(255, 107, 107, 0.1);
				padding: 6px;
				border-radius: 4px;
				margin: 6px 0;
			}

			.tooltip .research-cost {
				color: #ADD8E6;
				font-weight: bold;
			}

			.close-btn {
				position: fixed;
				bottom: 30px;
				right: 30px;
				background: rgba(139, 69, 19, 0.9);
				border: 2px solid #8B4513;
				color: #FFD700;
				padding: 15px 25px;
				border-radius: 8px;
				cursor: pointer;
				font-weight: bold;
				z-index: 1000;
				transition: all 0.3s ease;
			}

			.close-btn:hover {
				background: rgba(160, 82, 45, 0.9);
				transform: translateY(-3px);
			}

			.welcome-screen {
				display: flex;
				flex-direction: column;
				align-items: center;
				justify-content: center;
				height: 100%;
				text-align: center;
				padding: 40px;
			}

			.welcome-screen h2 {
				color: #FFD700;
				font-size: 36px;
				margin-bottom: 20px;
				text-shadow: 2px 2px 4px rgba(0,0,0,0.8);
			}

			.welcome-screen p {
				font-size: 18px;
				color: #CCC;
				max-width: 600px;
				line-height: 1.6;
				margin-bottom: 30px;
			}

			.clan-emblem {
				width: 120px;
				height: 120px;
				background: rgba(139, 69, 19, 0.3);
				border: 3px solid #8B4513;
				border-radius: 50%;
				display: flex;
				align-items: center;
				justify-content: center;
				font-size: 48px;
				color: #FFD700;
				margin-bottom: 30px;
			}
		</style>
	</head>
	<body>
		<div class="clan-header">
			<div class="clan-info">
				<div class="clan-name">[user_clan ? user_clan.name : "Unknown Clan"]</div>
				<div class="clan-desc">[user_clan ? user_clan.desc : ""]</div>
			</div>
			<div class="header-controls">
				<a href="?src=[REF(src)];action=refresh_clan_menu" class="header-btn">Refresh</a>
			</div>
		</div>

		<div class="main-container">
			<div class="sidebar">
				<h3>Your Covens</h3>
				<ul class="coven-list">
					[generate_coven_list_html()]
				</ul>
			</div>

			<div class="content-area" id="content-area">
				[research_content]
			</div>
		</div>

		<a href="byond://?src=[REF(src)];action=close_clan_menu" class="close-btn">Close</a>

		<script>
			// Coven selection
			function selectCoven(covenName) {
				document.querySelectorAll('.coven-item').forEach(item => {
					item.classList.remove('selected');
				});
				event.target.closest('.coven-item').classList.add('selected');
				window.location.href = 'byond://?src=[REF(src)];action=load_coven_tree;coven_name=' + encodeURIComponent(covenName);
			}

			// Research tree interaction variables
			let isDragging = false;
			let startX, startY;
			let currentX = 400, currentY = 300;
			let scale = 1;

			const container = document.getElementById('container');
			const canvas = document.getElementById('canvas');
			const tooltip = document.getElementById('tooltip');
			const parallaxBg = document.getElementById('parallax-bg');
			const parallaxStars1 = document.getElementById('parallax-stars-1');
			const parallaxNeb = document.getElementById('parallax-neb');

			// Initialize research tree if elements exist
			if (container && canvas) {
				updateCanvasTransform();
				updateParallax();

				// Mouse interaction events
				container.addEventListener('mousedown', function(e) {
					if (e.target === container || e.target === canvas || e.target.classList.contains('connection-line')) {
						isDragging = true;
						startX = e.clientX - currentX;
						startY = e.clientY - currentY;
						container.classList.add('dragging');
						e.preventDefault();
					}
				});

				document.addEventListener('mousemove', function(e) {
					if (isDragging) {
						currentX = e.clientX - startX;
						currentY = e.clientY - startY;
						updateCanvasTransform();
						updateParallax();
					}

					// Tooltip handling
					if (e.target.classList.contains('research-node') || e.target.parentElement.classList.contains('research-node')) {
						const node = e.target.classList.contains('research-node') ? e.target : e.target.parentElement;
						showCovenTooltip(e, node);
					} else {
						hideTooltip();
					}
				});

				document.addEventListener('mouseup', function() {
					isDragging = false;
					container.classList.remove('dragging');
				});

				// Zoom functionality
				container.addEventListener('wheel', function(e) {
					e.preventDefault();
					const zoomSpeed = 0.1;
					const rect = container.getBoundingClientRect();
					const mouseX = e.clientX - rect.left;
					const mouseY = e.clientY - rect.top;
					const oldScale = scale;

					if (e.deltaY < 0) {
						scale = Math.min(scale + zoomSpeed, 2.0);
					} else {
						scale = Math.max(scale - zoomSpeed, 0.3);
					}

					const scaleRatio = scale / oldScale;
					currentX = mouseX - (mouseX - currentX) * scaleRatio;
					currentY = mouseY - (mouseY - currentY) * scaleRatio;

					updateCanvasTransform();
					updateParallax();
				});

				// Node click handling
				document.addEventListener('click', function(e) {
					if (e.target.classList.contains('research-node') || e.target.parentElement.classList.contains('research-node')) {
						const node = e.target.classList.contains('research-node') ? e.target : e.target.parentElement;
						const nodeId = node.dataset.nodeId;
						if (nodeId) {
							window.location.href = '?src=[REF(src)];action=research_node;node_id=' + nodeId;
						}
					}
				});
			}

			function updateCanvasTransform() {
				if (canvas) {
					canvas.style.transform = 'translate(' + currentX + 'px, ' + currentY + 'px) scale(' + scale + ')';
				}
			}

			function updateParallax() {
				if (parallaxBg && parallaxStars1 && parallaxNeb) {
					const parallaxOffset = 0.3;
					const parallaxX = -currentX * parallaxOffset;
					const parallaxY = -currentY * parallaxOffset;

					parallaxBg.style.transform = 'translate(' + (parallaxX * 0.1) + 'px, ' + (parallaxY * 0.1) + 'px)';
					parallaxStars1.style.transform = 'translate(' + (parallaxX * 0.3) + 'px, ' + (parallaxY * 0.3) + 'px)';
					parallaxNeb.style.transform = 'translate(' + (parallaxX * 0.5) + 'px, ' + (parallaxY * 0.5) + 'px)';
				}
			}

			function showCovenTooltip(e, node) {
				if (!tooltip) return;

				const nodeData = JSON.parse(node.dataset.nodeData || '{}');
				let tooltipContent = '<h3>' + (nodeData.name || 'Unknown Power') + '</h3>';

				if (nodeData.desc) {
					tooltipContent += '<p>' + nodeData.desc + '</p>';
				}

				if (nodeData.level && nodeData.level > 0) {
					tooltipContent += '<div class="power-stats">Power Level: ' + nodeData.level + '</div>';
				}

				if (nodeData.vitae_cost && nodeData.vitae_cost > 0) {
					tooltipContent += '<div class="power-stats">Vitae Cost: ' + nodeData.vitae_cost + '</div>';
				}

				if (nodeData.research_cost && nodeData.research_cost > 0) {
					tooltipContent += '<div class="research-cost">Research Cost: ' + nodeData.research_cost + ' RP</div>';
				}

				if (nodeData.prerequisites && nodeData.prerequisites.length > 0) {
					tooltipContent += '<div class="requirements">Requires: ' + nodeData.prerequisites.join(', ') + '</div>';
				}

				if (nodeData.special_effect) {
					tooltipContent += '<div class="power-stats">Special: ' + nodeData.special_effect + '</div>';
				}

				tooltip.innerHTML = tooltipContent;
				tooltip.style.display = 'block';

				// Position tooltip
				const rect = container.getBoundingClientRect();
				let left = e.clientX - rect.left + 15;
				let top = e.clientY - rect.top + 15;

				if (left + tooltip.offsetWidth > container.offsetWidth) {
					left = e.clientX - rect.left - tooltip.offsetWidth - 15;
				}
				if (top + tooltip.offsetHeight > container.offsetHeight) {
					top = e.clientY - rect.top - tooltip.offsetHeight - 15;
				}

				tooltip.style.left = left + 'px';
				tooltip.style.top = top + 'px';
			}

			function hideTooltip() {
				if (tooltip) {
					tooltip.style.display = 'none';
				}
			}
		</script>
	</body>
	</html>
	"}

	return html



/datum/clan_menu_interface/proc/load_coven_research_tree(coven_name)
	if(!(coven_name in user_covens))
		return

	var/datum/coven/selected_coven = user_covens[coven_name]
	current_coven = coven_name

	// Initialize research tree if not already done
	if(!selected_coven.research_interface)
		selected_coven.initialize_research_tree()

	// Generate the research tree content
	var/research_html = {"
	<div class="parallax-container">
		<div class="parallax-layer parallax-bg" id="parallax-bg"></div>
		<div class="parallax-layer parallax-stars-1" id="parallax-stars-1"></div>
		<div class="parallax-layer parallax-neb" id="parallax-neb"></div>
	</div>

	<div class="research-container" id="container">
		<div class="research-canvas" id="canvas">
			[selected_coven.research_interface.generate_coven_connections_html()]
			[selected_coven.research_interface.generate_coven_nodes_html()]
		</div>
	</div>

	<div class="tooltip" id="tooltip" style="display: none;"></div>
	"}

	// Send updated content to the browser
	user << browse(generate_combined_html(research_html), "window=clan_menu")

// Modified topic handling to properly pass through research actions
/datum/clan_menu_interface/Topic(href, href_list)
	if(!user)
		return

	switch(href_list["action"])
		if("load_coven_tree")
			var/coven_name = href_list["coven_name"]
			load_coven_research_tree(coven_name)

		if("refresh_clan_menu")
			generate_interface()

		if("close_clan_menu")
			user << browse(null, "window=clan_menu")

		if("research_node")
			if(current_coven && (current_coven in user_covens))
				var/datum/coven/coven = user_covens[current_coven]
				if(coven.research_interface)
					// Set the user for the research interface
					coven.research_interface.user = user
					coven.research_interface.Topic(href, href_list)
					// Refresh the interface after research
					load_coven_research_tree(current_coven)
