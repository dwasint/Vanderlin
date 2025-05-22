// BuildMode Constants
#define BM_SWITCHSTATE_NONE 0
#define BM_SWITCHSTATE_MODE 1
#define BM_SWITCHSTATE_DIR 2
#define BM_SWITCHSTATE_CATEGORY 3 // New state for category selection
#define BM_SWITCHSTATE_ITEMS 4 // New state for item selection
#define BM_SWITCHSTATE_PIXEL_MODE 5

// Category Types
#define BM_CATEGORY_TURF 1
#define BM_CATEGORY_OBJ 2
#define BM_CATEGORY_MOB 3
#define BM_CATEGORY_ITEM 4
#define BM_CATEGORY_WEAPON 5
#define BM_CATEGORY_CLOTHING 6

// Global cache for appearance objects
GLOBAL_LIST_EMPTY(buildmode_appearance_cache)

GLOBAL_LIST_EMPTY(cached_buildmode_html)

/**
 * Enhanced BuildMode Datum
 *
 * Improved buildmode system with categorized selections,
 * embedded HTML interfaces, preview functionality, and grid-based building.
 */
/datum/buildmode
	var/build_dir = SOUTH
	var/datum/buildmode_mode/mode
	var/client/holder

	// Login callback
	var/li_cb

	// UI elements
	var/list/buttons
	var/list/selected_item // Currently selected item to place
	var/mutable_appearance/preview_appearance // Appearance for preview
	var/image/preview_image // Image shown to the user
	var/pixel_x_offset = 0
	var/pixel_y_offset = 0

	// Switching management
	var/switch_state = BM_SWITCHSTATE_NONE
	var/switch_width = 5

	// Mode switch UI
	var/atom/movable/screen/buildmode/mode/modebutton
	var/list/modeswitch_buttons = list()

	// Direction switch UI
	var/atom/movable/screen/buildmode/bdir/dirbutton
	var/list/dirswitch_buttons = list()

	// Category selection UI
	var/atom/movable/screen/buildmode/category/categorybutton
	var/list/category_buttons = list()
	var/current_category = null

	// Item browser interface
	var/datum/browser/item_browser = null
	var/list/cached_icons = list() // Cache for item icons

	// Pixel positioning mode
	var/pixel_positioning_mode = FALSE
	var/atom/movable/buildmode_pixel_dummy/pixel_positioning_dummy = null

/**
 * Creates a new buildmode instance
 *
 * @param {client} c - The client who will use this buildmode
 */
/datum/buildmode/New(client/c)
	mode = new /datum/buildmode_mode/basic(src)
	holder = c
	buttons = list()
	li_cb = CALLBACK(src, PROC_REF(post_login))
	holder.player_details.post_login_callbacks += li_cb
	create_buttons()
	holder.screen += buttons
	holder.click_intercept = src
	mode.enter_mode(src)
	current_category = BM_CATEGORY_TURF
	open_item_browser()
	RegisterSignal(holder.mob, COMSIG_MOUSE_ENTERED, PROC_REF(on_mouse_moved))
	RegisterSignal(holder.mob, COMSIG_ATOM_MOUSE_ENTERED, PROC_REF(on_mouse_moved_pre))

/**
 * Clean up and exit buildmode
 */
/datum/buildmode/proc/quit()
	mode.exit_mode(src)
	holder.screen -= buttons
	holder.click_intercept = null
	clear_preview()
	if(item_browser)
		item_browser.close()
		item_browser = null
	if(holder?.mob)
		UnregisterSignal(holder.mob, COMSIG_MOUSE_ENTERED)
		UnregisterSignal(holder.mob, COMSIG_ATOM_MOUSE_ENTERED)

	qdel(src)

/**
 * Clean up resources when deleted
 */
/datum/buildmode/Destroy()
	clear_pixel_positioning_dummy()
	close_switchstates()
	holder.player_details.post_login_callbacks -= li_cb
	holder = null
	QDEL_NULL(mode)
	QDEL_LIST(modeswitch_buttons)
	QDEL_LIST(dirswitch_buttons)
	QDEL_LIST(category_buttons)
	clear_preview()

	if(item_browser)
		item_browser.close()
		item_browser = null

	cached_icons.Cut()
	return ..()

/**
 * Reset UI after client login
 */
/datum/buildmode/proc/post_login()
	if(QDELETED(holder))
		return
	holder.screen += buttons

	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			open_modeswitch()
		if(BM_SWITCHSTATE_DIR)
			open_dirswitch()
		if(BM_SWITCHSTATE_CATEGORY)
			open_categoryswitch()
		if(BM_SWITCHSTATE_ITEMS)
			open_item_browser()

/**
 * Create the buildmode UI buttons
 */
/datum/buildmode/proc/create_buttons()
	modebutton = new /atom/movable/screen/buildmode/mode(src)
	buttons += modebutton
	buttons += new /atom/movable/screen/buildmode/help(src)
	dirbutton = new /atom/movable/screen/buildmode/bdir(src)
	buttons += dirbutton

	categorybutton = new /atom/movable/screen/buildmode/category(src)
	buttons += categorybutton
	buttons += new /atom/movable/screen/buildmode/quit(src)
	build_options_grid(subtypesof(/datum/buildmode_mode), modeswitch_buttons, /atom/movable/screen/buildmode/modeswitch)
	build_options_grid(list(SOUTH, EAST, WEST, NORTH, NORTHWEST), dirswitch_buttons, /atom/movable/screen/buildmode/dirswitch)
	build_options_grid(list(
		BM_CATEGORY_TURF,
		BM_CATEGORY_OBJ,
		BM_CATEGORY_MOB,
		BM_CATEGORY_ITEM,
		BM_CATEGORY_WEAPON,
		BM_CATEGORY_CLOTHING,
	), category_buttons, /atom/movable/screen/buildmode/categoryswitch)

/**
 * Build a grid of option buttons
 *
 * @param {list} elements - List of options to create buttons for
 * @param {list} buttonslist - List to store created buttons
 * @param {path} buttontype - Type of button to create
 */
/datum/buildmode/proc/build_options_grid(list/elements, list/buttonslist, buttontype)
	var/pos_idx = 0
	for(var/thing in elements)
		var/x = pos_idx % switch_width
		var/y = FLOOR(pos_idx / switch_width, 1)
		var/atom/movable/screen/buildmode/B = new buttontype(src, thing)
		// Extra .5 for a nice offset look
		B.screen_loc = "NORTH-[(1 + 0.5 + y*1.5)],WEST+[0.5 + x*1.5]"
		buttonslist += B
		pos_idx++

/**
 * Close all open switchstates
 */
/datum/buildmode/proc/close_switchstates()
	switch(switch_state)
		if(BM_SWITCHSTATE_MODE)
			close_modeswitch()
		if(BM_SWITCHSTATE_DIR)
			close_dirswitch()
		if(BM_SWITCHSTATE_CATEGORY)
			close_categoryswitch()
		if(BM_SWITCHSTATE_ITEMS)
			close_item_browser()

/**
 * Toggle the mode selection UI
 */
/datum/buildmode/proc/toggle_modeswitch()
	if(switch_state == BM_SWITCHSTATE_MODE)
		close_modeswitch()
	else
		close_switchstates()
		open_modeswitch()

/**
 * Open the mode selection UI
 */
/datum/buildmode/proc/open_modeswitch()
	switch_state = BM_SWITCHSTATE_MODE
	holder.screen += modeswitch_buttons

/**
 * Close the mode selection UI
 */
/datum/buildmode/proc/close_modeswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= modeswitch_buttons

/**
 * Toggle the direction selection UI
 */
/datum/buildmode/proc/toggle_dirswitch()
	if(switch_state == BM_SWITCHSTATE_DIR)
		close_dirswitch()
	else
		close_switchstates()
		open_dirswitch()

/**
 * Open the direction selection UI
 */
/datum/buildmode/proc/open_dirswitch()
	switch_state = BM_SWITCHSTATE_DIR
	holder.screen += dirswitch_buttons

/**
 * Close the direction selection UI
 */
/datum/buildmode/proc/close_dirswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= dirswitch_buttons

/**
 * Toggle the category selection UI
 */
/datum/buildmode/proc/toggle_categoryswitch()
	if(switch_state == BM_SWITCHSTATE_CATEGORY)
		close_categoryswitch()
	else
		close_switchstates()
		open_categoryswitch()

/**
 * Open the category selection UI
 */
/datum/buildmode/proc/open_categoryswitch()
	switch_state = BM_SWITCHSTATE_CATEGORY
	holder.screen += category_buttons

/**
 * Close the category selection UI
 */
/datum/buildmode/proc/close_categoryswitch()
	switch_state = BM_SWITCHSTATE_NONE
	holder.screen -= category_buttons

/**
 * Change the current buildmode
 *
 * @param {path} newmode - The new mode to switch to
 */
/datum/buildmode/proc/change_mode(newmode)
	mode.exit_mode(src)
	QDEL_NULL(mode)
	close_switchstates()
	mode = new newmode(src)
	mode.enter_mode(src)
	modebutton.update_icon()

/**
 * Change the build direction
 *
 * @param {int} newdir - The new direction to use
 * @return {bool} - Success
 */
/datum/buildmode/proc/change_dir(newdir)
	build_dir = newdir
	close_dirswitch()
	dirbutton.update_icon()
	update_preview_position()
	return 1

/**
 * Change the current category
 *
 * @param {int} new_category - The new category to select
 */
/datum/buildmode/proc/change_category(new_category)
	close_categoryswitch()
	current_category = new_category
	categorybutton.update_icon()
	open_item_browser()

/**
 * Open the item browser with the current category
 */
/datum/buildmode/proc/open_item_browser()
	switch_state = BM_SWITCHSTATE_ITEMS
	if(item_browser)
		item_browser.close()

	var/list/dat = list()
	dat += "<div class='buildmode-browser'>"
	dat += "<h3>BuildMode Item Selection</h3>"

	// Add category tabs
	dat += "<div class='tabs'>"
	dat += "<a class='tab [current_category == BM_CATEGORY_TURF ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_TURF]'>Turfs</a>"
	dat += "<a class='tab [current_category == BM_CATEGORY_OBJ ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_OBJ]'>Objects</a>"
	dat += "<a class='tab [current_category == BM_CATEGORY_MOB ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_MOB]'>Mobs</a>"
	dat += "<a class='tab [current_category == BM_CATEGORY_ITEM ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_ITEM]'>Items</a>"
	dat += "<a class='tab [current_category == BM_CATEGORY_WEAPON ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_WEAPON]'>Weapons</a>"
	dat += "<a class='tab [current_category == BM_CATEGORY_CLOTHING ? "active" : ""]' href='?src=[REF(src)];category=[BM_CATEGORY_CLOTHING]'>Clothing</a>"
	dat += "</div>"

	dat += "<div class='search-container'>"
	dat += "<input type='text' class='search-bar' id='item-search' placeholder='Search items...'>"
	dat += "</div>"

	dat += {"
	<script type='text/javascript'>
	(function setupListeners() {
		if (window.buildmodeScriptLoaded) return;
		window.buildmodeScriptLoaded = true;

		var input = document.getElementById('item-search');
		if (input) {
			input.addEventListener('keyup', function() {
				var filter = input.value.toUpperCase();
				var grid = document.getElementById('item-grid');
				if (!grid) return;

				var items = grid.getElementsByClassName('item');
				for (var i = 0; i < items.length; i++) {
					var itemName = items\[i\].getElementsByClassName('item-name')\[0\];
					if (itemName) {
						if (itemName.innerHTML.toUpperCase().indexOf(filter) > -1) {
							items\[i\].style.display = '';
						} else {
							items\[i\].style.display = 'none';
						}
					}
				}
			});
		}

		let shiftWasDown = false;

		function sendTogglePixel(toggled) {
			var a = document.createElement('a');
			a.href = '?src=[REF(src)]&toggle_pixel=' + toggled;
			document.body.appendChild(a);
			a.click();
			document.body.removeChild(a);
		}

		document.addEventListener('keydown', function(event) {
			if (event.key === 'Shift' && !shiftWasDown) {
				shiftWasDown = true;
				sendTogglePixel(1);
			}
		});

		document.addEventListener('keyup', function(event) {
			if (event.key === 'Shift') {
				shiftWasDown = false;
				sendTogglePixel(0);
			}
		});
	})();
	</script>
	"}



	dat += "<div class='item-grid' id='item-grid'>"

	switch(current_category)
		if(BM_CATEGORY_TURF)
			dat += generate_turf_list()
		if(BM_CATEGORY_OBJ)
			dat += generate_obj_list()
		if(BM_CATEGORY_MOB)
			dat += generate_mob_list()
		if(BM_CATEGORY_ITEM)
			dat += generate_item_list()
		if(BM_CATEGORY_WEAPON)
			dat += generate_weapon_list()
		if(BM_CATEGORY_CLOTHING)
			dat += generate_clothing_list()
		else
			current_category = BM_CATEGORY_TURF
			dat += generate_turf_list()

	dat += "</div>"

	dat += "</div>"

	var/datum/browser/popup = new(holder.mob, "buildmode_browser", "BuildMode Items", 600, 800)
	popup.set_content(dat.Join())
	popup.add_stylesheet("buildmodestyle", 'html/browser/buildmode.css')
	popup.set_window_options("can_close=1;can_minimize=0;can_maximize=0;can_resize=1")
	popup.open()

	item_browser = popup

/**
 * Generate HTML for turf selections
 *
 * @return {string} - HTML for the turf list
 */
/datum/buildmode/proc/generate_turf_list()
	var/list/dat = list()

	var/list/turf_types = subtypesof(/turf)
	var/list/filtered_types = list()
	for(var/turf_path in turf_types)
		var/turf/T = turf_path
		if(initial(T.icon) && !ispath(turf_path, /turf/template_noop))
			filtered_types += turf_path
	filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)

	var/list/mob_html = list()
	if("[BM_CATEGORY_TURF]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_TURF]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			var/turf/O = obj_path
			var/name_display = initial(O.name) || "Unknown"
			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_TURF]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_TURF]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()

/**
 * Generate HTML for object selections
 *
 * @return {string} - HTML for the object list
 */
/datum/buildmode/proc/generate_obj_list()
	var/list/dat = list()
	var/list/obj_types = subtypesof(/obj)
	var/static/list/filtered_types = list()

	if(!length(filtered_types))
		for(var/obj_path in obj_types)
			var/obj/O = obj_path
			if(is_abstract(O))
				continue
			if(ispath(O, /obj/item))
				continue
			if(ispath(O, /obj/abstract))
				continue

			if(initial(O.icon) && !ispath(obj_path, /obj/effect))
				filtered_types += obj_path
		filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)
	var/limit = 100
	var/count = 0

	var/list/mob_html = list()
	if("[BM_CATEGORY_OBJ]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_OBJ]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			if(count >= limit)
				dat += "<div class='item more'>More items available. Please use search.</div>"
				break

			var/obj/O = obj_path
			var/name_display = initial(O.name) || "Unknown"

			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_OBJ]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_OBJ]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()

/**
 * Generate HTML for mob selections
 *
 * @return {string} - HTML for the mob list
 */
/datum/buildmode/proc/generate_mob_list()
	var/list/dat = list()
	var/list/mob_types = subtypesof(/mob)
	var/static/list/filtered_types = list()

	if(!length(filtered_types))
		for(var/mob_path in mob_types)
			var/mob/M = mob_path
			if(initial(M.icon) && !ispath(mob_path, /mob/dead) && !ispath(mob_path, /mob/camera))
				filtered_types += mob_path
		filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)

	var/limit = 100
	var/count = 0

	var/list/mob_html = list()
	if("[BM_CATEGORY_MOB]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_MOB]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			if(count >= limit)
				dat += "<div class='item more'>More items available. Please use search.</div>"
				break

			var/mob/O = obj_path
			var/name_display = initial(O.name) || "Unknown"

			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_MOB]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_MOB]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()

/**
 * Generate HTML for item selections
 *
 * @return {string} - HTML for the item list
 */
/datum/buildmode/proc/generate_item_list()
	var/list/dat = list()

	var/list/item_types = subtypesof(/obj/item)
	var/static/list/filtered_types = list()

	if(!length(filtered_types))
		for(var/item_path in item_types)
			var/obj/item/I = item_path
			if(ispath(I, /obj/item/clothing) || ispath(I, /obj/item/weapon))
				continue
			if(initial(I.icon))
				filtered_types += item_path
		filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)
	var/limit = 100
	var/count = 0

	var/list/mob_html = list()
	if("[BM_CATEGORY_ITEM]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_ITEM]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			if(count >= limit)
				dat += "<div class='item more'>More items available. Please use search.</div>"
				break

			var/obj/O = obj_path
			var/name_display = initial(O.name) || "Unknown"
			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_ITEM]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_ITEM]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()


/**
 * Generate HTML for item selections
 *
 * @return {string} - HTML for the item list
 */
/datum/buildmode/proc/generate_clothing_list()
	var/list/dat = list()
	var/list/item_types = subtypesof(/obj/item/clothing)
	var/static/list/filtered_types = list()

	if(!length(filtered_types))
		for(var/item_path in item_types)
			var/obj/item/I = item_path
			if(initial(I.icon))
				filtered_types += item_path
		filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)
	var/limit = 100
	var/count = 0

	var/list/mob_html = list()
	if("[BM_CATEGORY_CLOTHING]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_CLOTHING]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			if(count >= limit)
				dat += "<div class='item more'>More items available. Please use search.</div>"
				break

			var/obj/O = obj_path
			var/name_display = initial(O.name) || "Unknown"
			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_CLOTHING]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_CLOTHING]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()


/**
 * Generate HTML for item selections
 *
 * @return {string} - HTML for the item list
 */
/datum/buildmode/proc/generate_weapon_list()
	var/list/dat = list()
	var/list/item_types = subtypesof(/obj/item/weapon)
	var/static/list/filtered_types = list()

	if(!length(filtered_types))
		for(var/item_path in item_types)
			var/obj/item/I = item_path
			if(initial(I.icon))
				filtered_types += item_path
		filtered_types = sortTim(filtered_types, /proc/cmp_typepaths_asc)
	var/limit = 100
	var/count = 0

	var/list/mob_html = list()
	if("[BM_CATEGORY_WEAPON]" in GLOB.cached_buildmode_html)
		mob_html = GLOB.cached_buildmode_html["[BM_CATEGORY_WEAPON]"]

	if(!length(mob_html))
		for(var/obj_path in filtered_types)
			if(count >= limit)
				dat += "<div class='item more'>More items available. Please use search.</div>"
				break

			var/obj/O = obj_path
			var/name_display = initial(O.name) || "Unknown"
			dat += "<div class='item' data-path='[obj_path]' onclick='window.location=\"?src=[REF(src)];item=[obj_path]\"'>"
			dat += "<div class='item-icon'><img src='\ref[O.icon]?state=[O.icon_state]&dir=[O.dir]'/></div>"
			dat += "<div class='item-name'>[name_display]</div>"
			dat += "</div>"
		GLOB.cached_buildmode_html |= "[BM_CATEGORY_WEAPON]"
		GLOB.cached_buildmode_html["[BM_CATEGORY_WEAPON]"] = dat.Copy()

	else
		dat += mob_html

	return dat.Join()
/**
 * Close the item browser
 */
/datum/buildmode/proc/close_item_browser()
	switch_state = BM_SWITCHSTATE_NONE
	if(item_browser)
		item_browser.close()
		item_browser = null

/**
 * Handle Topic calls from the item browser
 *
 * @param {datum} href_list - The href list from the browser
 */
/datum/buildmode/Topic(href, href_list)
	if(!holder || !holder.mob || QDELETED(holder.mob))
		return

	if(href_list["category"])
		var/new_category = text2num(href_list["category"])
		if(new_category)
			change_category(new_category)
			return TRUE

	if(href_list["item"])
		var/path = text2path(href_list["item"])
		if(ispath(path))
			select_item(path)
			return TRUE

	if(href_list["toggle_pixel"])
		var/toggled = text2num(href_list["toggle_pixel"])
		toggle_pixel_positioning_mode(toggled)
		return TRUE

	return FALSE

/**
 * Select an item to build with
 *
 * @param {path} item_path - The path of the item to select
 */
/datum/buildmode/proc/select_item(item_path)
	if(!ispath(item_path))
		return
	selected_item = item_path
	create_preview_appearance(item_path)

	var/name_to_show = ""
	if(ispath(item_path, /turf))
		var/turf/T = item_path
		name_to_show = initial(T.name)
	else if(ispath(item_path, /obj))
		var/obj/O = item_path
		name_to_show = initial(O.name)
	else if(ispath(item_path, /mob))
		var/mob/M = item_path
		name_to_show = initial(M.name)

	to_chat(holder.mob, "<span class='notice'>Selected [name_to_show] for building.</span>")

/**
 * Create or update the preview appearance that follows the cursor
 *
 * @param {path} item_path - The path of the item to preview
 */
/datum/buildmode/proc/create_preview_appearance(item_path)
	clear_preview()
	if(GLOB.buildmode_appearance_cache[item_path])
		preview_appearance = new
		preview_appearance.appearance = GLOB.buildmode_appearance_cache[item_path]
	else
		preview_appearance = new

		if(ispath(item_path, /turf))
			var/turf/T = item_path
			preview_appearance.icon = initial(T.icon)
			preview_appearance.icon_state = initial(T.icon_state)
			preview_appearance.dir = build_dir
		else
			var/atom/movable/temp_atom
			temp_atom = new item_path(null) // Create in nullspace
			preview_appearance.appearance = temp_atom.appearance
			preview_appearance.dir = build_dir
			qdel(temp_atom) // Clean up

		GLOB.buildmode_appearance_cache[item_path] = preview_appearance.appearance

	preview_image = new
	preview_image.appearance = preview_appearance
	preview_image.alpha = 150
	preview_image.plane = ABOVE_LIGHTING_PLANE
	preview_image.layer = FLOAT_LAYER
	preview_image.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	holder.images += preview_image

	update_preview_position()

/**
 * Handle mouse movement to update preview position
 *
 * @param {datum} source - Source of the signal
 * @param {turf} turf - The turf the mouse moved to
 */
/datum/buildmode/proc/on_mouse_moved_pre(datum/source, atom/atom, params)
	on_mouse_moved(source, get_turf(atom))

/datum/buildmode/proc/on_mouse_moved(datum/source, turf/turf, params)
	if(!preview_image || !turf)
		return

	// Update the image's location
	preview_image.loc = turf
	pixel_positioning_dummy?.forceMove(turf)

	if(pixel_positioning_dummy && params)
		var/list/pa = params2list(params)
		if(pa["icon-x"] && pa["icon-y"])
			var/x_offset = text2num(pa["icon-x"]) - 16
			var/y_offset = text2num(pa["icon-y"]) - 16

			pixel_x_offset = x_offset
			pixel_y_offset = y_offset

	preview_image.pixel_x = pixel_x_offset
	preview_image.pixel_y = pixel_y_offset

	if(preview_appearance)
		preview_appearance.dir = build_dir
		preview_image.appearance = preview_appearance
	update_preview_position()

/**
 * Update the preview object's position and appearance
 */
/datum/buildmode/proc/update_preview_position()
	if(!preview_image)
		return
	if(preview_appearance)
		preview_appearance.dir = build_dir
		preview_image.appearance = preview_appearance
	preview_image.pixel_x = pixel_x_offset
	preview_image.pixel_y = pixel_y_offset

/**
 * Clear the current preview
 */
/datum/buildmode/proc/clear_preview()
	if(preview_image)
		holder.images -= preview_image
		qdel(preview_image)
		preview_image = null

	preview_appearance = null

/**
 * Toggle pixel positioning mode
 */
/datum/buildmode/proc/toggle_pixel_positioning_mode(toggled)
	pixel_positioning_mode = toggled


	if(pixel_positioning_mode)
		to_chat(holder.mob, "<span class='notice'>Pixel positioning mode enabled. Move mouse to adjust pixel position.</span>")
		create_pixel_positioning_dummy()
	else
		to_chat(holder.mob, "<span class='notice'>Pixel positioning mode disabled.</span>")
		clear_pixel_positioning_dummy()
		pixel_y_offset = 0
		pixel_x_offset = 0
		update_preview_position()

/**
 * Create dummy object for pixel positioning
 */
/datum/buildmode/proc/create_pixel_positioning_dummy()
	clear_pixel_positioning_dummy()
	pixel_positioning_dummy = new /atom/movable/buildmode_pixel_dummy(get_turf(preview_image.loc), src)

/**
 * Clear pixel positioning dummy
 */
/datum/buildmode/proc/clear_pixel_positioning_dummy()
	if(pixel_positioning_dummy)
		qdel(pixel_positioning_dummy)
		pixel_positioning_dummy = null

/**
 * Intercept clicks to handle buildmode functionality
 *
 * @param {mob} user - The user clicking
 * @param {string} params - Click parameters
 * @param {atom} object - The object clicked on
 * @return {bool} - Whether the click was handled
 */
/datum/buildmode/proc/InterceptClickOn(mob/user, params, atom/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")

	if(selected_item && !istype(mode, /datum/buildmode_mode/advanced))
		if(left_click)
			place_object(get_turf(object), user, params)
			return TRUE

		if(right_click)
			clear_selection()
			return TRUE
	return mode.handle_click(user.client, params, object)

/**
 * Place an object at the specified location
 *
 * @param {turf} location - Where to place the object
 * @param {mob} user - Who is placing the object
 * @param {string} params - Click parameters
 */
/datum/buildmode/proc/place_object(turf/location, mob/user, params)
	if(!selected_item || !location)
		return

	var/path = selected_item

	if(ispath(path, /turf))
		var/turf/T = location
		T.ChangeTurf(path)
		log_admin("[key_name(user)] placed [path] at [AREACOORD(location)]")
	else
		var/atom/A = new path(location)
		if(build_dir)
			A.setDir(build_dir)
		A.pixel_x = pixel_x_offset
		A.pixel_y = pixel_y_offset
		log_admin("[key_name(user)] placed [path] at [AREACOORD(location)]")

/**
 * Clear the current item selection
 */
/datum/buildmode/proc/clear_selection()
	selected_item = null
	clear_preview()
	to_chat(holder.mob, "<span class='notice'>Selection cleared.</span>")

/**
 * New buildmode category button
 */
/atom/movable/screen/buildmode/category/update_icon()
	var/category_name = "None"

	switch(bd.current_category)
		if(BM_CATEGORY_TURF)
			category_name = "Turfs"
		if(BM_CATEGORY_OBJ)
			category_name = "Objects"
		if(BM_CATEGORY_MOB)
			category_name = "Mobs"
		if(BM_CATEGORY_ITEM)
			category_name = "Items"

	name = "Build Category: [category_name]"
	icon_state = "buildcategory"

/**
 * Category switch button
 */
/atom/movable/screen/buildmode/categoryswitch
	var/category_type

/atom/movable/screen/buildmode/categoryswitch/New(datum/buildmode/bm, category)
	. = ..()
	category_type = category
	update_icon()

/atom/movable/screen/buildmode/categoryswitch/update_icon()
	var/category_name = "Unknown"

	switch(category_type)
		if(BM_CATEGORY_TURF)
			category_name = "Turfs"
			icon_state = "cat_turf"
		if(BM_CATEGORY_OBJ)
			category_name = "Objects"
			icon_state = "cat_obj"
		if(BM_CATEGORY_MOB)
			category_name = "Mobs"
			icon_state = "cat_mob"
		if(BM_CATEGORY_ITEM)
			category_name = "Items"
			icon_state = "cat_item"

	name = category_name

/atom/movable/screen/buildmode/categoryswitch/Click()
	bd.change_category(category_type)

/datum/buildmode_mode
	var/key = "oops"
	var/datum/buildmode/BM

	// Corner selection component
	var/use_corner_selection = FALSE
	var/list/preview
	var/turf/cornerA
	var/turf/cornerB

/**
 * Create a new buildmode mode
 *
 * @param {datum/buildmode} BM - The buildmode datum this mode belongs to
 */
/datum/buildmode_mode/New(datum/buildmode/BM)
	src.BM = BM
	preview = list()
	return ..()

/**
 * Clean up resources when deleted
 */
/datum/buildmode_mode/Destroy()
	cornerA = null
	cornerB = null
	QDEL_LIST(preview)
	preview = null
	return ..()

/**
 * Called when entering this mode
 *
 * @param {datum/buildmode} BM - The buildmode datum
 */
/datum/buildmode_mode/proc/enter_mode(datum/buildmode/BM)
	return

/**
 * Called when exiting this mode
 *
 * @param {datum/buildmode} BM - The buildmode datum
 */
/datum/buildmode_mode/proc/exit_mode(datum/buildmode/BM)
	return

/**
 * Get the icon state for the mode button
 *
 * @return {string} - The icon state to use
 */
/datum/buildmode_mode/proc/get_button_iconstate()
	return "buildmode_[key]"

/**
 * Show help for this mode
 *
 * @param {client} c - The client to show help to
 */
/datum/buildmode_mode/proc/show_help(client/c)
	CRASH("No help defined for [src.type], yell at a coder")

/**
 * Change mode settings
 *
 * @param {client} c - The client changing settings
 */
/datum/buildmode_mode/proc/change_settings(client/c)
	to_chat(c, "<span class='warning'>There is no configuration available for this mode</span>")
	return

/**
 * Basic buildmode mode
 */
/datum/buildmode_mode/basic
	key = "basic"

/**
 * Enter mode callback
 */
/datum/buildmode_mode/basic/enter_mode(datum/buildmode/bm)
	to_chat(BM.holder.mob, "<span class='notice'>Basic Build Mode</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Left Mouse Button = Place selected object</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Right Mouse Button = Clear selection</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Shift + Left Mouse Button = Set pixel offset</span>")

/**
 * Exit mode callback
 */
/datum/buildmode_mode/basic/exit_mode(datum/buildmode/bm)
	return

/**
 * Handle click in this mode
 */
/datum/buildmode_mode/basic/handle_click(client/c, params, obj/object)
	return FALSE

/**
 * Advanced buildmode mode
 */
/datum/buildmode_mode/advanced
	key = "advanced"

/**
 * Enter mode callback
 */
/datum/buildmode_mode/advanced/enter_mode(datum/buildmode/bm)
	to_chat(BM.holder.mob, "<span class='notice'>Advanced Build Mode</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Left Mouse Button = Create/Delete/Modify objects</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Right Mouse Button = Copy object type</span>")
	to_chat(BM.holder.mob, "<span class='notice'>Middle Mouse Button = Select object to modify</span>")

/**
 * Exit mode callback
 */
/datum/buildmode_mode/advanced/exit_mode(datum/buildmode/bm)
	return

/**
 * Handle click in this mode
 */
/datum/buildmode_mode/advanced/handle_click(client/c, params, obj/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")
	var/right_click = pa.Find("right")
	var/middle_click = pa.Find("middle")

	if(left_click)
		if(isturf(object))
			var/turf/T = object
			if(ispath(BM.selected_item, /turf))
				T.ChangeTurf(BM.selected_item)
			else if(ispath(BM.selected_item, /obj) || ispath(BM.selected_item, /mob))
				var/atom/A = new BM.selected_item(T)
				A.setDir(BM.build_dir)
				A.pixel_x = BM.pixel_x_offset
				A.pixel_y = BM.pixel_y_offset
		else if(isobj(object))
			qdel(object)
		return TRUE

	if(right_click)
		if(istype(object))
			BM.select_item(object.type)
		return TRUE

	if(middle_click)
		if(istype(object))
			to_chat(c.mob, "<span class='notice'>Selected [object] for modification.</span>")
		return TRUE

	return FALSE

/**
 * Core buildmode mode buttons
 */
/atom/movable/screen/buildmode
	icon = 'icons/misc/buildmode.dmi'

/atom/movable/screen/buildmode/New(datum/buildmode/bm)
	bd = bm
	return ..()

/atom/movable/screen/buildmode/Destroy()
	bd = null
	return ..()

/atom/movable/screen/buildmode/mode
	icon_state = "buildmode1"
	name = "Toggle Mode"
	screen_loc = "NORTH,WEST"

/atom/movable/screen/buildmode/mode/Click()
	bd.toggle_modeswitch()

/atom/movable/screen/buildmode/mode/update_icon()
	icon_state = "buildmode[bd.mode.key ? bd.mode.key : 1]"

/atom/movable/screen/buildmode/help
	icon_state = "buildhelp"
	name = "Buildmode Help"
	screen_loc = "NORTH,WEST+1"

/atom/movable/screen/buildmode/help/Click()
	bd.mode.show_help(bd.holder.mob)

/atom/movable/screen/buildmode/bdir
	icon_state = "builddir"
	name = "Change Direction"
	screen_loc = "NORTH,WEST+2"

/atom/movable/screen/buildmode/bdir/update_icon()
	dir = bd.build_dir

/atom/movable/screen/buildmode/bdir/Click()
	bd.toggle_dirswitch()

/atom/movable/screen/buildmode/quit
	icon_state = "buildquit"
	name = "Quit Buildmode"
	screen_loc = "NORTH,WEST+3"

/atom/movable/screen/buildmode/quit/Click()
	bd.quit()

/atom/movable/screen/buildmode/modeswitch/Click()
	bd.change_mode(modetype)

/atom/movable/screen/buildmode/dirswitch
	var/dir_type

/atom/movable/screen/buildmode/dirswitch/New(datum/buildmode/bm, dir)
	dir_type = dir
	setDir(dir_type)
	return ..()

/atom/movable/screen/buildmode/dirswitch/Click()
	bd.change_dir(dir_type)


/**
 * Handle clicks in this mode
 *
 * @param {client} c - The client who clicked
 * @param {string} params - Click parameters
 * @param {atom} object - The object clicked on
 * @return {bool} - Whether the click was handled
 */
/datum/buildmode_mode/proc/handle_click(client/c, params, atom/object)
	var/list/pa = params2list(params)
	var/left_click = pa.Find("left")

	if(use_corner_selection)
		if(left_click)
			if(!cornerA)
				cornerA = select_tile(get_turf(object), AREASELECT_CORNERA)
				return TRUE

			if(cornerA && !cornerB)
				cornerB = select_tile(get_turf(object), AREASELECT_CORNERB)
				to_chat(c, "<span class='boldwarning'>Region selected, if you're happy with your selection left click again, otherwise right click.</span>")
				return TRUE

			if(cornerA && cornerB)
				handle_selected_area(c, params)
				deselect_region()
				return TRUE
		else
			to_chat(c, "<span class='notice'>Region selection canceled!</span>")
			deselect_region()
			return TRUE

	return FALSE


/**
 * Select a tile as part of region selection
 *
 * @param {turf} T - The turf to select
 * @param {int} corner_to_select - Which corner this is (A or B)
 * @return {turf} - The selected turf
 */
/datum/buildmode_mode/proc/select_tile(turf/T, corner_to_select)
	var/overlaystate
	BM.holder.images -= preview

	switch(corner_to_select)
		if(AREASELECT_CORNERA)
			overlaystate = "greenOverlay"
		if(AREASELECT_CORNERB)
			overlaystate = "blueOverlay"

	var/image/I = image('icons/turf/overlays.dmi', T, overlaystate)
	I.plane = ABOVE_LIGHTING_PLANE
	preview += I
	BM.holder.images += preview
	return T


/**
 * Highlight a region in the preview
 *
 * @param {list} region - The region to highlight
 */
/datum/buildmode_mode/proc/highlight_region(region)
	BM.holder.images -= preview
	for(var/turf/T in region)
		var/image/I = image('icons/turf/overlays.dmi', T, "redOverlay")
		I.plane = ABOVE_LIGHTING_PLANE
		preview += I
	BM.holder.images += preview

/**
 * Deselect the current region
 */
/datum/buildmode_mode/proc/deselect_region()
	BM.holder.images -= preview
	preview.Cut()
	cornerA = null
	cornerB = null


/**
 * Handle operations on the selected area
 *
 * @param {client} c - The client selecting the area
 * @param {string} params - Click parameters
 */
/datum/buildmode_mode/proc/handle_selected_area(client/c, params)
	return


/**
 * Toggle BuildMode admin command
 *
 * @param {mob} M - The mob to toggle buildmode for
 */
/proc/togglebuildmode(mob/M as mob in GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = "Event"

	if(M.client)
		if(istype(M.client.click_intercept, /datum/buildmode))
			var/datum/buildmode/B = M.client.click_intercept
			B.quit()
			log_admin("[key_name(usr)] has left build mode.")
		else
			new /datum/buildmode(M.client)
			log_admin("[key_name(usr)] has entered build mode.")

/**
 * Dummy object for tracking mouse movement in pixel positioning mode
 */
/atom/movable/buildmode_pixel_dummy
	name = "pixel positioning tracker"
	icon = 'icons/effects/alphacolors.dmi'
	alpha = 1
	glide_size = 1000
	var/datum/buildmode/parent_buildmode
	var/skip = FALSE

/atom/movable/buildmode_pixel_dummy/New(loc, datum/buildmode/bm)
	. = ..()
	parent_buildmode = bm

/atom/movable/buildmode_pixel_dummy/Destroy()
	parent_buildmode = null
	return ..()

/atom/movable/buildmode_pixel_dummy/MouseMove(location, control, params)
	if(skip)
		skip--
		return
	if(!parent_buildmode || !parent_buildmode.pixel_positioning_mode)
		return

	var/list/pa = params2list(params)
	if(pa["icon-x"] && pa["icon-y"])
		var/x_offset = text2num(pa["icon-x"]) - 16
		var/y_offset = text2num(pa["icon-y"]) - 16
		parent_buildmode.pixel_x_offset = x_offset
		parent_buildmode.pixel_y_offset = y_offset
		parent_buildmode.update_preview_position()



/atom/movable/buildmode_pixel_dummy/MouseEntered(location, control, params)
	if(skip)
		skip--
		return
	if(!parent_buildmode || !parent_buildmode.pixel_positioning_mode)
		return

	var/list/pa = params2list(params)
	if(pa["icon-x"] && pa["icon-y"])
		var/x_offset = text2num(pa["icon-x"]) - 16
		var/y_offset = text2num(pa["icon-y"]) - 16
		parent_buildmode.pixel_x_offset = x_offset
		parent_buildmode.pixel_y_offset = y_offset
		parent_buildmode.update_preview_position()
