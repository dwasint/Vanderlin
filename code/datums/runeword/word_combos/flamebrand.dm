/datum/runeword/flamebrand
	name = "Flamebrand"
	runes = list("tir", "ral")
	sockets_required = 2
	allowed_items = list(/obj/item/weapon)
	stat_bonuses = list(
		"force_bonus" = 5,
		"throwforce_bonus" = 3
	)
	combat_effects = list(
		/datum/rune_effect/damage/fire = list(3, 8)
	)
	spell_actions = list(/datum/action/cooldown/spell/projectile/fireball)
