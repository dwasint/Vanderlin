/datum/enchantment/on_hit
	abstract_type = /datum/enchantment/on_hit
	var/cooldown_time = 20 SECONDS
	COOLDOWN_DECLARE(hit_cooldown)

/datum/enchantment/on_hit/register_triggers(atom/item)
	. = ..()
	registered_signals += COMSIG_ITEM_SPEC_ATTACKEDBY
	RegisterSignal(item, COMSIG_ITEM_SPEC_ATTACKEDBY, PROC_REF(on_human_attack))

	registered_signals += COMSIG_ITEM_POST_ATTACK_SIMPLE
	RegisterSignal(item, COMSIG_ITEM_POST_ATTACK_SIMPLE, PROC_REF(on_simple_attack))

/datum/enchantment/on_hit/proc/on_human_attack(obj/item/source, mob/living/carbon/human/attacked, mob/attacker, obj/item/bodypart/attacked_part, actual_damage)
	if(!COOLDOWN_FINISHED(src, hit_cooldown))
		return
	if(!actual_damage)
		return
	apply_human_attack_effects(source, attacked, attacker, attacked_part, actual_damage)
	COOLDOWN_START(src, hit_cooldown, cooldown_time)

/datum/enchantment/on_hit/proc/apply_human_attack_effects(obj/item/source, mob/living/carbon/human/attacked, mob/attacker, obj/item/bodypart/attacked_part, actual_damage)
	SHOULD_CALL_PARENT(FALSE)
	if(!actual_damage)
		return
	apply_attack_effects(source, attacked, attacker, actual_damage)

/datum/enchantment/on_hit/proc/on_simple_attack(obj/item/source, mob/living/carbon/human/attacked, mob/attacker, actual_damage)
	if(!COOLDOWN_FINISHED(src, hit_cooldown))
		return
	apply_attack_effects(source, attacked, attacker, actual_damage)
	COOLDOWN_START(src, hit_cooldown, cooldown_time)

/datum/enchantment/on_hit/proc/apply_attack_effects(obj/item/source, mob/living/carbon/human/attacked, mob/living/carbon/attacker, actual_damage)
	return
