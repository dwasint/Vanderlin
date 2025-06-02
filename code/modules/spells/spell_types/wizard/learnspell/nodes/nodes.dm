/datum/spell_node/prestidigitation
	name = "Prestidigitation"
	desc = "Simple magical tricks and minor illusions."
	node_x = 0
	node_y = 0
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/prestidigitation

/datum/spell_node/light
	name = "Light"
	desc = "Create a magical source of illumination."
	node_x = 100
	node_y = 0
	spell_type = /obj/effect/proc_holder/spell/self/light5e

/datum/spell_node/message
	name = "Message"
	desc = "Send telepathic communications across distances."
	node_x = 200
	node_y = 0
	spell_type = /obj/effect/proc_holder/spell/self/message

/datum/spell_node/guidance
	name = "Guidance"
	desc = "Provide divine assistance to aid in tasks."
	node_x = 300
	node_y = 0
	spell_type = /obj/effect/proc_holder/spell/invoked/guidance

/datum/spell_node/acid_splash
	name = "Acid Splash"
	desc = "Hurl a bubble of acid at your enemies."
	node_x = -150
	node_y = 100
	prerequisites = list(/datum/spell_node/prestidigitation)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/acidsplash5e

/datum/spell_node/ray_of_frost
	name = "Ray of Frost"
	desc = "A frigid beam of blue-white light."
	node_x = -50
	node_y = 100
	prerequisites = list(/datum/spell_node/prestidigitation)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/rayoffrost5e

/datum/spell_node/eldritch_blast
	name = "Eldritch Blast"
	desc = "A crackling beam of otherworldly energy."
	node_x = 50
	node_y = 100
	prerequisites = list(/datum/spell_node/prestidigitation)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/eldritchblast5e

/datum/spell_node/poison_spray
	name = "Poison Spray"
	desc = "Extend your hand and release a puff of noxious gas."
	node_x = 150
	node_y = 100
	prerequisites = list(/datum/spell_node/prestidigitation)
	spell_type = /obj/effect/proc_holder/spell/invoked/poisonspray5e

// UTILITY CANTRIPS
/datum/spell_node/create_bonfire
	name = "Create Bonfire"
	desc = "Create a bonfire on the ground."
	node_x = 250
	node_y = 100
	prerequisites = list(/datum/spell_node/light)
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/createbonfire5e

/datum/spell_node/blade_ward
	name = "Blade Ward"
	desc = "Extend your hand and trace a sigil of warding."
	node_x = 350
	node_y = 100
	prerequisites = list(/datum/spell_node/guidance)
	spell_type = /obj/effect/proc_holder/spell/self/bladeward5e

// ENHANCED CANTRIPS
/datum/spell_node/chill_touch
	name = "Chill Touch"
	desc = "Create a ghostly, skeletal hand that weakens foes."
	node_x = -100
	node_y = 200
	prerequisites = list(/datum/spell_node/ray_of_frost, /datum/spell_node/eldritch_blast)
	spell_type = /obj/effect/proc_holder/spell/invoked/chilltouch5e

/datum/spell_node/frostbite
	name = "Frostbite"
	desc = "Cause numbing frost to form on a creature."
	node_x = 0
	node_y = 200
	prerequisites = list(/datum/spell_node/ray_of_frost)
	spell_type = /obj/effect/proc_holder/spell/invoked/frostbite5e

/datum/spell_node/infestation
	name = "Infestation"
	desc = "Cause a cloud of mites, fleas, and other parasites."
	node_x = 100
	node_y = 200
	prerequisites = list(/datum/spell_node/poison_spray)
	spell_type = /obj/effect/proc_holder/spell/invoked/infestation5e

/datum/spell_node/mind_sliver
	name = "Mind Sliver"
	desc = "Drive a disorienting spike of psychic energy."
	node_x = 200
	node_y = 200
	prerequisites = list(/datum/spell_node/message, /datum/spell_node/eldritch_blast)
	spell_type = /obj/effect/proc_holder/spell/invoked/mindsliver5e

/datum/spell_node/green_flame_blade
	name = "Green-Flame Blade"
	desc = "Evoke fiery green flames along your weapon."
	node_x = -50
	node_y = 300
	prerequisites = list(/datum/spell_node/create_bonfire)
	spell_type = /obj/effect/proc_holder/spell/invoked/greenflameblade5e

/datum/spell_node/booming_blade
	name = "Booming Blade"
	desc = "Evoke thunderous energy around your weapon."
	node_x = 50
	node_y = 300
	prerequisites = list(/datum/spell_node/blade_ward)
	spell_type = /obj/effect/proc_holder/spell/invoked/boomingblade5e

// UTILITY CANTRIPS - ADVANCED
/datum/spell_node/magic_stone
	name = "Magic Stone"
	desc = "Imbue up to three pebbles with magical force."
	node_x = 150
	node_y = 300
	prerequisites = list(/datum/spell_node/guidance)
	spell_type = /obj/effect/proc_holder/spell/invoked/magicstone5e

/datum/spell_node/decompose
	name = "Decompose"
	desc = "Accelerate the decay of organic matter."
	node_x = 250
	node_y = 300
	prerequisites = list(/datum/spell_node/infestation)
	spell_type = /obj/effect/proc_holder/spell/invoked/decompose5e

/datum/spell_node/encode_thoughts
	name = "Encode Thoughts"
	desc = "Extract a memory and crystallize it into a thought strand."
	node_x = 350
	node_y = 300
	prerequisites = list(/datum/spell_node/mind_sliver)
	spell_type = /obj/effect/proc_holder/spell/targeted/encodethoughts5e

/datum/spell_node/nondetection
	name = "Nondetection"
	desc = "Hide a target from divination magic."
	node_x = 0
	node_y = 400
	prerequisites = list(/datum/spell_node/prestidigitation, /datum/spell_node/message)
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/nondetection

/datum/spell_node/featherfall
	name = "Featherfall"
	desc = "Slow your descent when falling."
	node_x = 100
	node_y = 400
	prerequisites = list(/datum/spell_node/light)
	spell_type = /obj/effect/proc_holder/spell/invoked/featherfall

/datum/spell_node/longstrider
	name = "Longstrider"
	desc = "Increase your walking speed."
	node_x = 200
	node_y = 400
	prerequisites = list(/datum/spell_node/guidance)
	spell_type = /obj/effect/proc_holder/spell/invoked/longstrider

/datum/spell_node/fetch
	name = "Fetch"
	desc = "Magically retrieve distant objects."
	node_x = 300
	node_y = 400
	prerequisites = list(/datum/spell_node/magic_stone)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/fetch

/datum/spell_node/spitfire
	name = "Spitfire"
	desc = "Spit a small gout of flame at your enemy."
	node_x = -100
	node_y = 500
	prerequisites = list(/datum/spell_node/green_flame_blade)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/spitfire

/datum/spell_node/arcane_bolt
	name = "Arcane Bolt"
	desc = "Launch a bolt of pure magical energy."
	node_x = 0
	node_y = 500
	prerequisites = list(/datum/spell_node/eldritch_blast, /datum/spell_node/nondetection)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/arcanebolt

/datum/spell_node/snap_freeze
	name = "Snap Freeze"
	desc = "Instantly freeze the moisture around a target."
	node_x = 100
	node_y = 500
	prerequisites = list(/datum/spell_node/frostbite, /datum/spell_node/chill_touch)
	spell_type = /obj/effect/proc_holder/spell/invoked/snap_freeze

/datum/spell_node/blade_burst
	name = "Blade Burst"
	desc = "Create a burst of spectral blades around you."
	node_x = 200
	node_y = 500
	prerequisites = list(/datum/spell_node/booming_blade)
	spell_type = /obj/effect/proc_holder/spell/invoked/blade_burst

/datum/spell_node/primal_savagery
	name = "Primal Savagery"
	desc = "Channel primal magic to grow claws or fangs."
	node_x = 300
	node_y = 500
	prerequisites = list(/datum/spell_node/decompose)
	spell_type = /obj/effect/proc_holder/spell/self/primalsavagery5e

/datum/spell_node/forcewall_weak
	name = "Weak Force Wall"
	desc = "Create a weak barrier of magical force."
	node_x = 400
	node_y = 500
	prerequisites = list(/datum/spell_node/blade_ward, /datum/spell_node/fetch)
	spell_type = /obj/effect/proc_holder/spell/invoked/forcewall_weak

/datum/spell_node/haste
	name = "Haste"
	desc = "Make a creature move and act more quickly."
	node_x = 100
	node_y = 600
	prerequisites = list(/datum/spell_node/longstrider, /datum/spell_node/featherfall)
	spell_type = /obj/effect/proc_holder/spell/invoked/haste

/datum/spell_node/slowdown_aoe
	name = "Mass Slowdown"
	desc = "Slow multiple creatures in an area."
	node_x = 200
	node_y = 600
	prerequisites = list(/datum/spell_node/snap_freeze, /datum/spell_node/arcane_bolt)
	spell_type = /obj/effect/proc_holder/spell/invoked/slowdown_spell_aoe

/datum/spell_node/frostbolt
	name = "Frostbolt"
	desc = "Launch a shard of ice at your enemy."
	node_x = 300
	node_y = 600
	prerequisites = list(/datum/spell_node/snap_freeze)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/frostbolt

/datum/spell_node/repel
	name = "Repel"
	desc = "Push creatures away from you with force."
	node_x = 400
	node_y = 600
	prerequisites = list(/datum/spell_node/forcewall_weak, /datum/spell_node/blade_burst)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/repel

/datum/spell_node/find_familiar
	name = "Find Familiar"
	desc = "Summon an animal to serve as your familiar."
	node_x = 500
	node_y = 600
	prerequisites = list(/datum/spell_node/primal_savagery)
	spell_type = /obj/effect/proc_holder/spell/invoked/findfamiliar

/datum/spell_node/gravity
	name = "Gravity"
	desc = "Manipulate gravitational forces."
	node_x = 100
	node_y = 700
	prerequisites = list(/datum/spell_node/haste, /datum/spell_node/darkvision)
	spell_type = /obj/effect/proc_holder/spell/invoked/gravity

/datum/spell_node/darkvision
	name = "Darkvision"
	desc = "Grant the ability to see in darkness."
	node_x = 300
	node_y = 700
	prerequisites = list(/datum/spell_node/arcyne_eye, /datum/spell_node/slowdown_aoe)
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/darkvision

/datum/spell_node/arcyne_eye
	name = "Arcane Eye"
	desc = "Create an invisible, magical eye."
	node_x = 0
	node_y = 600
	prerequisites = list(/datum/spell_node/nondetection, /datum/spell_node/featherfall)
	spell_type = /obj/effect/proc_holder/spell/self/arcyne_eye

/datum/spell_node/lightning_bolt
	name = "Lightning Bolt"
	desc = "Strike your enemies with a bolt of lightning."
	node_x = 0
	node_y = 800
	prerequisites = list(/datum/spell_node/arcane_bolt, /datum/spell_node/haste)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/lightningbolt

/datum/spell_node/blood_lightning
	name = "Blood Lightning"
	desc = "Channel crimson lightning through blood."
	node_x = 100
	node_y = 800
	prerequisites = list(/datum/spell_node/lightning_bolt, /datum/spell_node/primal_savagery)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/bloodlightning

/datum/spell_node/sundering_lightning
	name = "Sundering Lightning"
	desc = "Lightning that tears through magical defenses."
	node_x = 200
	node_y = 800
	prerequisites = list(/datum/spell_node/blood_lightning, /datum/spell_node/arcyne_eye)
	spell_type = /obj/effect/proc_holder/spell/invoked/sundering_lightning

// TIER 4 SPELLS (4 cost)
/datum/spell_node/fireball
	name = "Fireball"
	desc = "Launch an explosive ball of fire."
	node_x = 0
	node_y = 900
	prerequisites = list(/datum/spell_node/spitfire, /datum/spell_node/lightning_bolt)
	spell_type = /obj/effect/proc_holder/spell/invoked/projectile/fireball

/datum/spell_node/arcyne_storm
	name = "Arcane Storm"
	desc = "Unleash a devastating storm of magical energy."
	node_x = 100
	node_y = 900
	prerequisites = list(/datum/spell_node/sundering_lightning, /datum/spell_node/arcyne_eye)
	spell_type = /obj/effect/proc_holder/spell/invoked/arcyne_storm

/datum/spell_node/meteor_storm
	name = "Meteor Storm"
	desc = "Call down meteors from the heavens."
	node_x = 200
	node_y = 900
	prerequisites = list(/datum/spell_node/fireball, /datum/spell_node/arcyne_storm, /datum/spell_node/gravity)
	spell_type = /obj/effect/proc_holder/spell/invoked/meteor_storm
