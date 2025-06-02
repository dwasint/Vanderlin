/datum/spell_node/fire_affinity
	name = "Fire Affinity"
	desc = "Deepen your connection to the flames."
	cost = 3
	node_x = -200
	node_y = 150
	prerequisites = list(/datum/spell_node/acid_splash)

/datum/spell_node/fire_affinity/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/fire, 0.15)
	to_chat(user, span_notice("You feel the flames dance within your soul."))

/datum/spell_node/frost_affinity
	name = "Frost Affinity"
	desc = "Embrace the cold within your soul."
	cost = 3
	node_x = -50
	node_y = 150
	prerequisites = list(/datum/spell_node/ray_of_frost)

/datum/spell_node/frost_affinity/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/ice, 0.15)
	to_chat(user, span_notice("Cold seeps into your very essence."))

/datum/spell_node/electric_affinity
	name = "Electric Affinity"
	desc = "Attune yourself to the power of lightning."
	cost = 3
	node_x = 50
	node_y = 150
	prerequisites = list(/datum/spell_node/eldritch_blast)

/datum/spell_node/electric_affinity/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/electric, 0.15)
	to_chat(user, span_notice("Lightning crackles through your veins."))

/datum/spell_node/death_affinity
	name = "Death Affinity"
	desc = "Touch the void and understand mortality."
	cost = 3
	node_x = 150
	node_y = 150
	prerequisites = list(/datum/spell_node/poison_spray)

/datum/spell_node/death_affinity/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/death, 0.15)
	to_chat(user, span_notice("The void whispers secrets to you."))

/datum/spell_node/mana_conservation
	name = "Mana Conservation"
	desc = "Learn to use magic more efficiently."
	cost = 5
	node_x = 400
	node_y = 150
	prerequisites = list(/datum/spell_node/blade_ward)

/datum/spell_node/mana_conservation/on_node_buy(mob/user)
	user.mana_pool?.set_natural_recharge(user.mana_pool.ethereal_recharge_rate + 0.1)
	to_chat(user, span_notice("You learn to channel magic more efficiently."))

/datum/spell_node/expanded_reserves
	name = "Expanded Reserves"
	desc = "Increase your magical capacity."
	cost = 5
	node_x = 300
	node_y = 150
	prerequisites = list(/datum/spell_node/create_bonfire)

/datum/spell_node/expanded_reserves/on_node_buy(mob/user)
	var/current_max = user.mana_pool?.maximum_mana_capacity || 100
	user.mana_pool?.set_max_mana(current_max + 25, TRUE, TRUE)
	to_chat(user, span_notice("Your magical reserves expand."))

/datum/spell_node/elemental_harmony
	name = "Elemental Harmony"
	desc = "Balance fire and ice within yourself."
	cost = 5
	node_x = -75
	node_y = 250
	prerequisites = list(/datum/spell_node/fire_affinity, /datum/spell_node/frost_affinity)

/datum/spell_node/elemental_harmony/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/fire, 0.1)
	user.mana_pool?.adjust_attunement(/datum/attunement/ice, 0.1)
	to_chat(user, span_notice("Fire and ice flow in harmony within you."))

/datum/spell_node/storm_caller
	name = "Storm Caller"
	desc = "Channel the fury of tempests."
	cost = 5
	node_x = 75
	node_y = 250
	prerequisites = list(/datum/spell_node/electric_affinity, /datum/spell_node/frost_affinity)

/datum/spell_node/storm_caller/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/electric, 0.12)
	user.mana_pool?.adjust_attunement(/datum/attunement/ice, 0.08)
	to_chat(user, span_notice("The fury of storms courses through you."))

/datum/spell_node/blood_pact
	name = "Blood Pact"
	desc = "Bind your life force to dark magic."
	cost = 5
	node_x = 175
	node_y = 250
	prerequisites = list(/datum/spell_node/death_affinity, /datum/spell_node/infestation)

/datum/spell_node/blood_pact/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/death, 0.12)
	user.mana_pool?.adjust_attunement(/datum/attunement/blood, 0.12)
	to_chat(user, span_notice("Dark power flows through your lifeblood."))

/datum/spell_node/arcane_focus
	name = "Arcane Focus"
	desc = "Concentrate pure magical energy."
	cost = 5
	node_x = 275
	node_y = 250
	prerequisites = list(/datum/spell_node/mind_sliver, /datum/spell_node/expanded_reserves)

/datum/spell_node/arcane_focus/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/arcyne, 0.2)
	to_chat(user, span_notice("Pure magical energy concentrates within you."))

/datum/spell_node/mana_well
	name = "Mana Well"
	desc = "Dig deeper into your magical reserves."
	node_x = 375
	node_y = 250
	cost = 6
	prerequisites = list(/datum/spell_node/mana_conservation, /datum/spell_node/expanded_reserves)

/datum/spell_node/mana_well/on_node_buy(mob/user)
	var/current_max = user.mana_pool?.maximum_mana_capacity || 100
	user.mana_pool?.set_max_mana(current_max + 50, TRUE, TRUE)
	to_chat(user, span_notice("Your magical well deepens considerably."))

/datum/spell_node/meditation
	name = "Meditation"
	desc = "Improve your natural mana recovery."
	cost = 6
	node_x = 475
	node_y = 250
	prerequisites = list(/datum/spell_node/mana_conservation)

/datum/spell_node/meditation/on_node_buy(mob/user)
	user.mana_pool?.set_natural_recharge(user.mana_pool.ethereal_recharge_rate + 0.25)
	to_chat(user, span_notice("Your mind achieves greater focus and clarity."))

/datum/spell_node/earth_shaper
	name = "Earth Shaper"
	desc = "Command the bones of the world."
	cost = 6
	node_x = -150
	node_y = 350
	prerequisites = list(/datum/spell_node/decompose, /datum/spell_node/elemental_harmony)

/datum/spell_node/earth_shaper/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/earth, 0.25)
	user.mana_pool?.adjust_attunement(/datum/attunement/fire, 0.05)
	to_chat(user, span_notice("The earth's strength becomes your own."))

/datum/spell_node/light_bearer
	name = "Light Bearer"
	desc = "Become a beacon of pure radiance."
	cost = 6
	node_x = -50
	node_y = 350
	prerequisites = list(/datum/spell_node/elemental_harmony)

/datum/spell_node/light_bearer/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/light, 0.25)
	user.mana_pool?.adjust_attunement(/datum/attunement/fire, 0.05)
	user.mana_pool?.adjust_attunement(/datum/attunement/ice, 0.05)
	to_chat(user, span_notice("Radiant light fills your being."))

/datum/spell_node/void_touched
	name = "Void Touched"
	desc = "Embrace the darkness between stars."
	cost = 6
	node_x = 50
	node_y = 350
	prerequisites = list(/datum/spell_node/blood_pact, /datum/spell_node/storm_caller)

/datum/spell_node/void_touched/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/dark, 0.25)
	user.mana_pool?.adjust_attunement(/datum/attunement/death, 0.1)
	to_chat(user, span_notice("Darkness embraces you like an old friend."))

/datum/spell_node/time_walker
	name = "Time Walker"
	desc = "Perceive the flow of temporal currents."
	cost = 6
	node_x = 150
	node_y = 350
	prerequisites = list(/datum/spell_node/encode_thoughts, /datum/spell_node/arcane_focus)

/datum/spell_node/time_walker/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/time, 0.25)
	user.mana_pool?.adjust_attunement(/datum/attunement/arcyne, 0.1)
	to_chat(user, span_notice("Time flows differently around you."))

/datum/spell_node/life_weaver
	name = "Life Weaver"
	desc = "Channel the essence of living things."
	cost = 6
	node_x = 250
	node_y = 350
	prerequisites = list(/datum/spell_node/primal_savagery, /datum/spell_node/find_familiar)

/datum/spell_node/life_weaver/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/life, 0.25)
	user.mana_pool?.adjust_attunement(/datum/attunement/earth, 0.1)
	to_chat(user, span_notice("The essence of life pulses within you."))

/datum/spell_node/deep_reserves
	name = "Deep Reserves"
	desc = "Vastly expand your magical capacity."
	cost = 8
	node_x = 350
	node_y = 350
	prerequisites = list(/datum/spell_node/mana_well, /datum/spell_node/time_walker)

/datum/spell_node/deep_reserves/on_node_buy(mob/user)
	var/current_max = user.mana_pool?.maximum_mana_capacity || 100
	user.mana_pool?.set_max_mana(current_max + 100, TRUE, TRUE)
	to_chat(user, span_notice("Your magical capacity expands dramatically."))

/datum/spell_node/mana_surge
	name = "Mana Surge"
	desc = "Dramatically improve mana regeneration."
	cost = 8
	node_x = 450
	node_y = 350
	prerequisites = list(/datum/spell_node/meditation, /datum/spell_node/mana_well)

/datum/spell_node/mana_surge/on_node_buy(mob/user)
	user.mana_pool?.set_natural_recharge(user.mana_pool.ethereal_recharge_rate + 0.5)
	to_chat(user, span_notice("Mana flows through you like a raging river."))

/datum/spell_node/aeromancer
	name = "Aeromancer"
	desc = "Master the winds and sky."
	cost = 8
	node_x = -100
	node_y = 450
	prerequisites = list(/datum/spell_node/light_bearer, /datum/spell_node/earth_shaper)

/datum/spell_node/aeromancer/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/aeromancy, 0.3)
	user.mana_pool?.adjust_attunement(/datum/attunement/electric, 0.1)
	user.mana_pool?.adjust_attunement(/datum/attunement/light, 0.1)
	to_chat(user, span_notice("The winds themselves answer your call."))

/datum/spell_node/illusionist
	name = "Illusionist"
	desc = "Bend reality with deception and trickery."
	cost = 8
	node_x = 0
	node_y = 450
	prerequisites = list(/datum/spell_node/void_touched, /datum/spell_node/light_bearer)

/datum/spell_node/illusionist/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/illusion, 0.3)
	user.mana_pool?.adjust_attunement(/datum/attunement/dark, 0.1)
	user.mana_pool?.adjust_attunement(/datum/attunement/light, 0.1)
	to_chat(user, span_notice("Reality bends to your whims."))

/datum/spell_node/polymorph_adept
	name = "Polymorph Adept"
	desc = "Master the art of transformation."
	cost = 8
	node_x = 100
	node_y = 450
	prerequisites = list(/datum/spell_node/life_weaver, /datum/spell_node/time_walker)

/datum/spell_node/polymorph_adept/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/polymorph, 0.3)
	user.mana_pool?.adjust_attunement(/datum/attunement/life, 0.1)
	user.mana_pool?.adjust_attunement(/datum/attunement/time, 0.1)
	to_chat(user, span_notice("Your form becomes fluid and malleable."))

/datum/spell_node/arcyne_master
	name = "Arcane Master"
	desc = "Achieve mastery over pure magic."
	cost = 8
	node_x = 200
	node_y = 450
	prerequisites = list(/datum/spell_node/time_walker, /datum/spell_node/void_touched)

/datum/spell_node/arcyne_master/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/arcyne, 0.4)
	user.mana_pool?.adjust_attunement(/datum/attunement/time, 0.1)
	user.mana_pool?.adjust_attunement(/datum/attunement/dark, 0.1)
	to_chat(user, span_notice("Pure magic flows through your very essence."))

/datum/spell_node/omnimancer
	name = "Omnimancer"
	desc = "Transcend the boundaries of magical schools."
	cost = 12
	node_x = 0
	node_y = 550
	prerequisites = list(/datum/spell_node/aeromancer, /datum/spell_node/illusionist, /datum/spell_node/polymorph_adept)

/datum/spell_node/omnimancer/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/fire, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/ice, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/electric, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/blood, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/life, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/death, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/earth, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/light, 0.15)
	user.mana_pool?.adjust_attunement(/datum/attunement/dark, 0.15)
	to_chat(user, span_notice("You transcend the boundaries between magical schools."))

/datum/spell_node/eternal_wellspring
	name = "Eternal Wellspring"
	desc = "Achieve perfect harmony with magical forces."
	cost = 12
	node_x = 300
	node_y = 450
	prerequisites = list(/datum/spell_node/deep_reserves, /datum/spell_node/mana_surge, /datum/spell_node/arcyne_master)

/datum/spell_node/eternal_wellspring/on_node_buy(mob/user)
	var/current_max = user.mana_pool?.maximum_mana_capacity || 100
	user.mana_pool?.set_max_mana(current_max + 200, TRUE, TRUE)
	user.mana_pool?.set_natural_recharge(user.mana_pool.ethereal_recharge_rate + 1.0)
	to_chat(user, span_notice("You become one with the eternal flow of magic."))

/datum/spell_node/reality_anchor
	name = "Reality Anchor"
	desc = "Become a fixed point in the flow of magic."
	cost = 12
	node_x = 150
	node_y = 550
	prerequisites = list(/datum/spell_node/omnimancer, /datum/spell_node/eternal_wellspring)

/datum/spell_node/reality_anchor/on_node_buy(mob/user)
	user.mana_pool?.adjust_attunement(/datum/attunement/time, 0.3)
	user.mana_pool?.adjust_attunement(/datum/attunement/aeromancy, 0.2)
	user.mana_pool?.adjust_attunement(/datum/attunement/arcyne, 0.3)
	user.mana_pool?.adjust_attunement(/datum/attunement/illusion, 0.2)
	user.mana_pool?.adjust_attunement(/datum/attunement/polymorph, 0.2)
	var/current_max = user.mana_pool?.maximum_mana_capacity || 100
	user.mana_pool?.set_max_mana(current_max + 150, TRUE, TRUE)
	user.mana_pool?.set_natural_recharge(user.mana_pool.ethereal_recharge_rate + 0.75)
	to_chat(user, span_notice("You become an immutable anchor in the fabric of reality itself."))
