/obj/effect/dungeon_loot_spawner
	name = "dungeon loot spawner"
	invisibility = INVISIBILITY_ABSTRACT

	/// Total item value this spawner will hold before it goes inactive
	var/max_value = 5
	/// Only pool items with a value in this range can come from this spawner
	var/min_item_value = 0
	var/max_item_value = 5
	/// Relative chance of being picked while the budget is handed out (before depth scaling)
	var/spawn_weight = 1
	/// Value of the items this spawner has produced so far
	var/used_value = 0
	/// Depth (rooms from the start) of the room this spawner sits in. Set by the generator.
	var/depth = 0

/obj/effect/dungeon_loot_spawner/Initialize(mapload)
	. = ..()
	SSdungeon_generator.loot_spawners |= src

/obj/effect/dungeon_loot_spawner/Destroy()
	SSdungeon_generator?.loot_spawners -= src
	return ..()

/obj/effect/dungeon_loot_spawner/proc/get_remaining_value()
	return max_value - used_value

/obj/effect/dungeon_loot_spawner/proc/can_accept_loot()
	return get_remaining_value() > 0

/// Picks a pool item that fits this spawner's value range and the given cap. Returns a path or null.
/obj/effect/dungeon_loot_spawner/proc/pick_loot(value_cap)
	var/upper = min(max_item_value, value_cap)
	var/list/eligible = list()
	for(var/item_path in GLOB.dungeon_loot_pool)
		var/value = GLOB.dungeon_loot_pool[item_path]
		if(value < min_item_value || value > upper)
			continue
		eligible += item_path
	if(!length(eligible))
		return null
	return pick(eligible)

/// Spawns the item here and returns its value.
/obj/effect/dungeon_loot_spawner/proc/spawn_loot(item_path)
	var/value = GLOB.dungeon_loot_pool[item_path]
	new item_path(get_turf(src))
	used_value += value
	return value

/obj/effect/dungeon_loot_spawner/low
	name = "low value loot spawner"
	max_value = 4
	min_item_value = 0
	max_item_value = 2
	spawn_weight = 3

/obj/effect/dungeon_loot_spawner/medium
	name = "medium value loot spawner"
	max_value = 10
	min_item_value = 3
	max_item_value = 6
	spawn_weight = 2

/obj/effect/dungeon_loot_spawner/high
	name = "high value loot spawner"
	max_value = 20
	min_item_value = 7
	max_item_value = 20
	spawn_weight = 1

/client/proc/regenerate_dungeon_loot()
	set category = "Debug"
	set name = "Regenerate Dungeon Loot"

	if(!check_rights(R_DEBUG))
		return
	var/spent = SSdungeon_generator.regenerate_loot()
	message_admins("[key_name_admin(usr)] regenerated dungeon loot ([spent]/[SSdungeon_generator.loot_budget] value placed).")
