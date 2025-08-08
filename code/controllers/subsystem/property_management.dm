//Bits to save
#define SAVE_OBJECTS (1 << 1) //! Save objects?
#define SAVE_MOBS (1 << 2) //! Save Mobs?
#define SAVE_TURFS (1 << 3) //! Save turfs?
#define SAVE_AREAS (1 << 4) //! Save areas?
#define SAVE_OBJECT_PROPERTIES (1 << 5) //! Save custom properties of objects (obj.on_object_saved() output)

//Ignore turf if it contains
#define SAVE_SHUTTLEAREA_DONTCARE 0
#define SAVE_SHUTTLEAREA_IGNORE 1
#define SAVE_SHUTTLEAREA_ONLY 2

#define DMM2TGM_MESSAGE "MAP CONVERTED BY dmm2tgm.py THIS HEADER COMMENT PREVENTS RECONVERSION, DO NOT REMOVE"

/**
 * A procedure for saving DMM text to a file and then sending it to the user.
 * Arguments:
 * * user - a user which get map
 * * name - name of file + .dmm
 * * map - text with DMM format
 */
/proc/send_exported_map(user, name, map)
	var/file_path = "data/[name].dmm"
	rustg_file_write(map, file_path)
	DIRECT_OUTPUT(user, ftp(file_path, "[name].dmm"))
	var/file_to_delete = file(file_path)
	fdel(file_to_delete)

/proc/sanitize_mapfile(text)
	return hashtag_newlines_and_tabs(text, list("\n"="", "\t"="", "/"="", "\\"="", "?"="", "%"="", "*"="", ":"="", "|"="", "\""="", "<"="", ">"=""))

/proc/hashtag_newlines_and_tabs(text, list/repl_chars = list("\n"="#","\t"="#"))
	for(var/char in repl_chars)
		var/index = findtext(text, char)
		while(index)
			text = copytext(text, 1, index) + repl_chars[char] + copytext(text, index + length(char))
			index = findtext(text, char, index + length(char))
	return text

/**
 * A procedure for saving non-standard properties of an object.
 * For example, saving items in vault.
 */
/obj/proc/on_object_saved()
	return null

/**Map exporter
* Inputting a list of turfs into convert_map_to_tgm() will output a string
* with the turfs and their objects / areas on said turf into the TGM mapping format
* for .dmm files. This file can then be opened in the map editor or imported
* back into the game.
* ============================
* This has been made semi-modular so you should be able to use these functions
* elsewhere in code if you ever need to get a file in the .dmm format
**/


/atom/proc/get_save_vars()
	. = list()
	. += NAMEOF(src, color)
	. += NAMEOF(src, dir)
	. += NAMEOF(src, icon)
	. += NAMEOF(src, icon_state)
	. += NAMEOF(src, name)
	. += NAMEOF(src, pixel_x)
	. += NAMEOF(src, pixel_y)
	. += NAMEOF(src, density)
	. += NAMEOF(src, opacity)

	return .

/atom/movable/get_save_vars()
	. = ..()
	. += NAMEOF(src, anchored)
	return .

/obj/get_save_vars()
	. = ..()
	return .

GLOBAL_LIST_INIT(save_file_chars, list(
	"a","b","c","d","e",
	"f","g","h","i","j",
	"k","l","m","n","o",
	"p","q","r","s","t",
	"u","v","w","x","y",
	"z","A","B","C","D",
	"E","F","G","H","I",
	"J","K","L","M","N",
	"O","P","Q","R","S",
	"T","U","V","W","X",
	"Y","Z",
))

/proc/to_list_string(list/build_from)
	var/list/build_into = list()
	build_into += "list("
	var/first_entry = TRUE
	for(var/item in build_from)
		CHECK_TICK
		if(!first_entry)
			build_into += ", "
		if(isnum(item) || !build_from[item])
			build_into += "[tgm_encode(item)]"
		else
			build_into += "[tgm_encode(item)] = [tgm_encode(build_from[item])]"
		first_entry = FALSE
	build_into += ")"
	return build_into.Join("")

/// Takes a constant, encodes it into a TGM valid string
/proc/tgm_encode(value)
	if(istext(value))
		//Prevent symbols from being because otherwise you can name something
		// [";},/obj/item/gun/energy/laser/instakill{name="da epic gun] and spawn yourself an instakill gun.
		return "\"[hashtag_newlines_and_tabs("[value]", list("{"="", "}"="", "\""="", ";"="", ","=""))]\""
	if(isnum(value) || ispath(value))
		return "[value]"
	if(islist(value))
		return to_list_string(value)
	if(isnull(value))
		return "null"
	if(isicon(value) || isfile(value))
		return "'[value]'"
	// not handled:
	// - pops: /obj{name="foo"}
	// - new(), newlist(), icon(), matrix(), sound()

	// fallback: string
	return tgm_encode("[value]")

/**
 *Procedure for converting a coordinate-selected part of the map into text for the .dmi format
 */
/proc/write_map(
	minx,
	miny,
	minz,
	maxx,
	maxy,
	maxz,
	save_flag = ALL,
	shuttle_area_flag = SAVE_SHUTTLEAREA_DONTCARE,
	list/obj_blacklist = typesof(/obj/effect),
)
	var/width = maxx - minx
	var/height = maxy - miny
	var/depth = maxz - minz

	if(!islist(obj_blacklist))
		CRASH("Non-list being used as object blacklist for map writing")

	// we want to keep crayon writings, blood splatters, cobwebs, etc.
	obj_blacklist -= typesof(/obj/effect/decal)
	obj_blacklist -= typesof(/obj/effect/turf_decal)
	obj_blacklist -= typesof(/obj/effect/landmark) // most landmarks get deleted except for latejoin arrivals shuttle
	obj_blacklist += /obj/effect/landmark/house_spot
	obj_blacklist += /obj/effect/fog_parter

	//Step 0: Calculate the amount of letters we need (26 ^ n > turf count)
	var/turfs_needed = width * height
	var/layers = FLOOR(log(GLOB.save_file_chars.len, turfs_needed) + 0.999,1)

	//Step 1: Run through the area and generate file data
	var/list/header_data = list() //holds the data of a header -> to its key
	var/list/header = list() //The actual header in text
	var/list/contents = list() //The contents in text (bit at the end)
	var/key_index = 1 // How many keys we've generated so far
	for(var/z in 0 to depth)
		for(var/x in 0 to width)
			contents += "\n([x + 1],1,[z + 1]) = {\"\n"
			for(var/y in height to 0 step -1)
				CHECK_TICK
				//====Get turfs Data====
				var/turf/place
				var/area/location
				var/turf/pull_from = locate((minx + x), (miny + y), (minz + z))
				//If there is nothing there, save as a noop (For odd shapes)
				if(isnull(pull_from))
					place = /turf/template_noop
					location = /area/template_noop
				//Stuff to add
				else
					var/area/place_area = get_area(pull_from)
					location = place_area.type
					place = pull_from.type

				//====For toggling not saving areas and turfs====
				if(!(save_flag & SAVE_AREAS))
					location = /area/template_noop
				if(!(save_flag & SAVE_TURFS))
					place = /turf/template_noop
				//====Generate Header Character====
				// Info that describes this turf and all its contents
				// Unique, will be checked for existing later
				var/list/current_header = list()
				current_header += "(\n"
				//Add objects to the header file
				var/empty = TRUE
				//====SAVING OBJECTS====
				if(save_flag & SAVE_OBJECTS)
					for(var/obj/thing in pull_from)
						CHECK_TICK
						if(thing.type in obj_blacklist)
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
						//====SAVING SPECIAL DATA====
						//This is what causes lockers and machines to save stuff inside of them
						if(save_flag & SAVE_OBJECT_PROPERTIES)
							var/custom_data = thing.on_object_saved()
							current_header += "[custom_data ? ",\n[custom_data]" : ""]"
				//====SAVING MOBS====
				if(save_flag & SAVE_MOBS)
					for(var/mob/living/thing in pull_from)
						CHECK_TICK
						if(istype(thing, /mob/living/carbon)) //Ignore people, but not animals
							continue
						var/metadata = generate_tgm_metadata(thing)
						current_header += "[empty ? "" : ",\n"][thing.type][metadata]"
						empty = FALSE
				current_header += "[empty ? "" : ",\n"][place],\n[location])\n"
				//====Fill the contents file====
				var/textiftied_header = current_header.Join()
				// If we already know this header just use its key, otherwise we gotta make a new one
				var/key = header_data[textiftied_header]
				if(!key)
					key = calculate_tgm_header_index(key_index, layers)
					key_index++
					header += "\"[key]\" = [textiftied_header]"
					header_data[textiftied_header] = key
				contents += "[key]\n"
			contents += "\"}"
	return "//[DMM2TGM_MESSAGE]\n[header.Join()][contents.Join()]"

/proc/generate_tgm_metadata(atom/object)
	var/list/data_to_add = list()

	var/list/vars_to_save = object.get_save_vars()
	for(var/variable in vars_to_save)
		CHECK_TICK
		var/value = object.vars[variable]
		if(value == initial(object.vars[variable]) || !issaved(object.vars[variable]))
			continue
		if(variable == "icon_state" && object.smoothing_flags)
			continue
		if(variable == "icon" && object.smoothing_flags)
			continue

		var/text_value = tgm_encode(value)
		if(!text_value)
			continue
		data_to_add += "[variable] = [text_value]"

	if(!length(data_to_add))
		return
	return "{\n\t[data_to_add.Join(";\n\t")]\n\t}"

// Could be inlined, not a massive cost tho so it's fine
/// Generates a key matching our index
/proc/calculate_tgm_header_index(index, key_length)
	var/list/output = list()
	// We want to stick the first one last, so we walk backwards
	var/list/pull_from = GLOB.save_file_chars
	var/length = length(pull_from)
	for(var/i in key_length to 1 step -1)
		var/calculated = FLOOR((index-1) / (length ** (i - 1)), 1)
		calculated = (calculated % length) + 1
		output += pull_from[calculated]
	return output.Join()

/obj/effect/landmark/house_spot
	var/rent_cost = 1
	///this is the id we check inside of a players save data for them
	var/house_id = ""
	var/datum/map_template/default_template
	var/owner_ckey

	var/template_x
	var/template_y
	var/template_z

/obj/effect/landmark/house_spot/New(loc, ...)
	. = ..()
	SShousing.properties |= src

SUBSYSTEM_DEF(housing)
	name = "Housing"
	flags = SS_NO_FIRE
	init_order = INIT_ORDER_HOUSING

	var/list/properties = list() // List of all property landmarks
	var/list/property_owners = list()
	var/list/owned_properties = list()
	var/list/property_controllers = list()
	var/rent_collection_enabled = TRUE

/datum/controller/subsystem/housing/Initialize()
	populate_property_owners()
	return ..()

/datum/controller/subsystem/housing/proc/populate_property_owners()
	if(fexists("data/property_owners.json"))
		var/list/unlocated_properties = properties.Copy()
		var/list/owners = json_decode(file2text("data/property_owners.json"))
		for(var/owner as anything in owners)
			var/property_id = owners[owner]
			var/obj/effect/landmark/house_spot/spot
			for(var/obj/effect/landmark/house_spot/potential as anything in unlocated_properties)
				if(property_id != potential.house_id)
					continue
				spot = potential
				break
			if(!spot)
				continue
			var/datum/save_manager/SM = get_save_manager(owner)
			var/current_balance = SM.get_data("banking", "persistent_balance", 0)
			if(current_balance < spot.rent_cost)
				owners -= owner
				continue
			SM.set_data("banking", "persistent_balance", max(0, current_balance - spot.rent_cost))
			load_property_from_data(owner, get_turf(spot))
			unlocated_properties -= spot
			spot.owner_ckey = owner
			var/datum/property_controller/new_controller = new(spot)
			property_controllers |= new_controller
			owned_properties |= spot
		if(length(unlocated_properties))
			for(var/obj/effect/landmark/house_spot/property as anything in unlocated_properties)
				var/datum/map_template/template = new property.default_template
				template.load(get_turf(property))
				var/list/turfs = template.get_affected_turfs(get_turf(property))

				for(var/turf/turf as anything in turfs)
					for(var/obj/structure/sign/property_for_sale/sale in turf.contents)
						sale.linked_property = property
				var/datum/property_controller/new_controller = new(property)
				property_controllers |= new_controller


/datum/controller/subsystem/housing/proc/save_properties()
	for(var/obj/effect/landmark/house_spot/property as anything in owned_properties)
		save_property_to_data(property.owner_ckey, property)

/datum/controller/subsystem/housing/proc/save_property_to_data(ckey, obj/effect/landmark/house_spot/property)
	if(!property)
		return FALSE

	var/turf/start_turf = get_turf(property)
	if(!start_turf)
		return FALSE

	// Calculate the area to save based on the template dimensions
	var/minx = start_turf.x
	var/miny = start_turf.y
	var/minz = start_turf.z
	var/maxx = minx + property.template_x - 1
	var/maxy = miny + property.template_y - 1
	var/maxz = minz + property.template_z - 1

	// Generate the map data (save objects and turfs, but not mobs)
	var/save_flags = SAVE_OBJECTS | SAVE_TURFS | SAVE_AREAS | SAVE_OBJECT_PROPERTIES
	var/map_data = write_map(minx, miny, minz, maxx, maxy, maxz, save_flags, SAVE_SHUTTLEAREA_DONTCARE)

	if(!map_data)
		log_admin("Property Save: Failed to generate map data for [ckey]'s property [property.house_id]")
		return FALSE

	// Create the property file path
	var/property_file = "data/properties/[ckey]_[property.house_id].dmm"
	if(fexists(property_file))
		fdel(property_file)
	// Save using file handle method (same as auto save)
	var/file_handle = file(property_file)
	file_handle << map_data

	log_admin("Property Save: Successfully saved property [property.house_id] for [ckey] ([length(map_data)] characters)")
	return TRUE

/datum/controller/subsystem/housing/proc/load_property_from_data(ckey, turf/template_spot)
	var/obj/effect/landmark/house_spot/property

	// Find the property landmark at this location
	for(var/obj/effect/landmark/house_spot/spot as anything in properties)
		if(get_turf(spot) == template_spot)
			property = spot
			break

	if(!property)
		return FALSE

	// Check if we have saved property data
	var/property_file = "data/properties/[ckey]_[property.house_id].dmm"
	if(fexists(property_file))
		// Load from saved data
		var/datum/map_template/saved_template = new /datum/map_template(property_file, "[ckey]_[property.house_id]", TRUE)
		if(saved_template.cached_map)
			saved_template.load(template_spot)
			property_owners[ckey] = property.house_id
			return TRUE

	// Fallback to default template if no saved data exists
	if(property.default_template)
		var/datum/map_template/template = new property.default_template
		template.load(template_spot)
		var/list/turfs = template.get_affected_turfs(template_spot)

		for(var/turf/turf as anything in turfs)
			for(var/obj/structure/sign/property_for_sale/sale in turf.contents)
				sale.linked_property = property

		property_owners[ckey] = property.house_id
		return TRUE

	return FALSE

/datum/controller/subsystem/housing/proc/check_access(ckey)
	for(var/datum/property_controller/controller as anything in property_controllers)
		if(controller.check_access(ckey))
			return TRUE
	return FALSE

/datum/controller/subsystem/housing/proc/save_property_owners()
	var/json_data = json_encode(property_owners)
	rustg_file_write(json_data, "data/property_owners.json")

/obj/structure/sign/property_for_sale
	name = "Property For Sale"
	desc = "Click to purchase this property. Rent will be automatically deducted from your bank account."
	icon = 'icons/roguetown/misc/structure.dmi'
	icon_state = "questnoti" // Adjust icon state as needed

	var/sold = FALSE
	var/obj/effect/landmark/house_spot/linked_property

/obj/structure/sign/property_for_sale/attack_hand(mob/user)
	. = ..()
	if(!user.client)
		return

	if(sold)
		to_chat(user, "<span class='warning'>This property has already been sold!</span>")
		return

	if(!linked_property)
		to_chat(user, "<span class='warning'>No property found linked to this sign!</span>")
		return

	// Check if user already owns this property
	if(SShousing.property_owners[user.ckey] == linked_property.house_id)
		to_chat(user, "<span class='notice'>You already own this property!</span>")
		return

	// Check if someone else owns this property
	for(var/owner_ckey in SShousing.property_owners)
		if(SShousing.property_owners[owner_ckey] == linked_property.house_id)
			to_chat(user, "<span class='warning'>This property is already owned by someone else!</span>")
			return

	var/datum/save_manager/SM = get_save_manager(user.ckey)
	var/current_balance = SM.get_data("banking", "persistent_balance", 0)

	if(current_balance < linked_property.rent_cost)
		to_chat(user, "<span class='warning'>You don't have enough money! You need [linked_property.rent_cost] credits, but only have [current_balance].</span>")
		return

	var/confirm = alert(user, "Purchase this property for [linked_property.rent_cost] credits?\n\nRent will be automatically deducted each round.", "Property Purchase", "Yes", "No")
	if(confirm != "Yes")
		return

	// Double-check balance in case it changed
	current_balance = SM.get_data("banking", "persistent_balance", 0)
	if(current_balance < linked_property.rent_cost)
		to_chat(user, "<span class='warning'>Transaction failed - insufficient funds!</span>")
		return

	// Purchase the property
	SM.set_data("banking", "persistent_balance", current_balance - linked_property.rent_cost)
	SShousing.property_owners[user.ckey] = linked_property.house_id
	SShousing.owned_properties |= linked_property
	SShousing.save_property_owners()
	linked_property.owner_ckey = user.client.key

	to_chat(user, "<span class='notice'>Congratulations! You have successfully purchased this property for [linked_property.rent_cost] credits.</span>")

	// Remove the for sale sign
	sold = TRUE
	qdel(src)

/datum/map_template/basic_house
	name = "Roguetest House"
	mappath = "_maps/templates/delver/basic_house.dmm"
	width = 15
	height = 17

/datum/map_template/basic_nine
	name = "Basic 9x9 House"
	mappath = "_maps/templates/delver/9x9.dmm"
	width = 9
	height = 9

/datum/property_controller
	var/obj/effect/landmark/house_spot/linked_property
	var/list/allowed_list = list()
	var/property_bounds_minx
	var/property_bounds_miny
	var/property_bounds_maxx
	var/property_bounds_maxy
	var/property_bounds_z
	var/property_bounds_zmax

/datum/property_controller/New(obj/effect/landmark/house_spot/property)
	linked_property = property
	if(!property)
		return

	var/turf/start_turf = get_turf(property)
	if(!start_turf)
		return

	property_bounds_minx = start_turf.x
	property_bounds_miny = start_turf.y
	property_bounds_maxx = start_turf.x + property.template_x - 1
	property_bounds_maxy = start_turf.y + property.template_y - 1
	property_bounds_z = start_turf.z
	property_bounds_zmax = start_turf.z + property.template_z - 1

/datum/property_controller/proc/check_access(mob/user)
	if(!linked_property)
		return TRUE

	if(!user || !user.client)
		return FALSE

	// Owner always has access
	if(user.ckey == linked_property.owner_ckey)
		return TRUE

	// Check allow list
	if(user.ckey in allowed_list)
		return TRUE

	return FALSE

/datum/property_controller/proc/is_in_property_bounds(atom/A)
	if(!linked_property)
		return FALSE

	var/turf/T = get_turf(A)
	if(!T)
		return FALSE

	// Fallback to coordinate checking
	return (T.x >= property_bounds_minx && T.x <= property_bounds_maxx && T.y >= property_bounds_miny && T.y <= property_bounds_maxy && T.z >= property_bounds_z && T.z <= property_bounds_zmax)
