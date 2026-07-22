/datum/action/cooldown/spell/conjure/bonfire
	name = "Create Bonfire"
	desc = "Creates a magical bonfire to cook on."
	button_icon_state = "create_campfire"
	self_cast_possible = FALSE

	sound = 'sound/magic/whiteflame.ogg'

	charge_required = FALSE
	cooldown_time = 30 SECONDS
	spell_cost = 30
	spell_flags = SPELL_RITUOS
	invocation = "Bonfire!"
	invocation_type = INVOCATION_SHOUT

	required_form = FORM_FIRE

	summon_type = list(/obj/machinery/light/fueled/firebowl/church/magic)
	summon_radius = 0
	summon_lifespan = 30 SECONDS
