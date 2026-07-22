/obj/item/book/granter/spellbook
	icon = 'icons/roguetown/items/books.dmi'
	icon_state = "spellbookbrown_0"
	slot_flags = ITEM_SLOT_HIP
	unique = TRUE
	firefuel = 2 MINUTES
	dropshrink = 0.6
	drop_sound = 'sound/foley/dropsound/book_drop.ogg'
	force = 5
	associated_skill = /datum/attribute/skill/misc/reading
	name = "tome of the arcyne"
	desc = "A crackling, glowing book, filled with runes and symbols that hurt the mind to stare at."
	pages_to_mastery = 7
	remarks = list(
		"Recall that place of white and black, so cold after its season of heat...",
		"Time slips away as I devour each pictograph and sigil...",
		"Noc is a shrewd God, and his followers' writings are no different...",
		"The smell of wet rain fills the room with every turned page...",
		"Helical text spans the page like a winding puzzle...",
		"Tracing a finger over one rune renders my hand paralyzed, if only for a moment...",
		"This page clearly details the benefits of swampweed on one's capacity to conceptualize the arcyne...",
		"Conceptualize. Theorize. Feel. Flow. Manifest...",
		"Passion. Strength. Power. Victory. The tenets through which we break the chains of reality...",
		"Magick is to be kept close, a guarded secret. Noc changed the rules again. I need to catch up...",
		"Didn't I just read this page...?",
		"A lone illustration of Noc's visage fills this page, his stony gaze boring into my soul...",
		"My eyes begin to lid as I finish this chapter. These symbols cast a heavy fog over my mind...",
		"Silver. Blade. Mana. Blood. These are the ingredients I'll need to imbibe the very ground with arcyne abilities...",
		"Elysium incants speak to me in an extinct tongue immortalized on parchment...",
		"My mind wanders and waves. Z's temptations draw close, but I weather through as I finally finish this chapter...",
		"I close my eyes for but a moment, and the competing visages of Noc and Z stare into my very soul. I see them blink, and my eyelids open...",
		"I am the Root. The Root is me. I must reach it, and the Tree...",
		"I feel the arcyne circuits running through my body, empowered with each word I read...",
		"Am I reading? Are these words, symbols or inane scribbles? I cannot be sure, yet with each one my eyes glaze over, I can feel the arcyne pulse within me...",
		"A mystery is revealed before my very eyes. I do not read it, yet I am aware. Gems are the Root's natural arcyne energy, manifest. Perhaps I can use them to better my conceptualization..."
	)
	oneuse = FALSE
	item_weight = 547 GRAMS
	/// The mob who owns and originally bound this tome
	var/owner = null
	/// Up to two additional mobs allowed to read this tome
	var/list/allowed_readers = list()
	/// Flat quality bonus stored from a crushed gem, consumed on next read
	var/stored_gem = FALSE
	/// Attunement datum stored from the gem used, applied on next read
	var/datum/attunement/stored_attunement
	/// Whether the player has chosen a visual style for this book yet
	var/picked = FALSE
	/// If TRUE, this tome was made from a magic stone rather than a gem and has a reading penalty
	var/born_of_rock = FALSE
	/// Multiplier for spell points gained per read. Higher = better book.
	var/bookquality = 3
	var/datum/spell_mastery/mastery
	/// If set, this book is specialized in one form and gets bonus points + spell buffs for it
	var/themed_form = null
	/// Total innate points this book grants toward its form track on creation
	var/base_form_points = 0
	/// Total innate points this book grants toward the (generic) technique pool on creation
	var/base_technique_points = 0
	/// Cost multiplier for spells of themed_form (below 1 = cheaper)
	var/themed_cost_multiplier = 1
	var/themed_cast_speed_multiplier = 1
	/// Flat magnitude addition for spells of themed_form
	var/themed_magnitude_bonus = 0

	var/list/designlist = list("green", "yellow", "brown")

/obj/item/book/granter/spellbook/Initialize()
	. = ..()
	mastery = new /datum/spell_mastery(null, src)
	apply_themed_bonuses()
	if(length(designlist) == 1)
		base_icon_state = "spellbook[designlist[1]]"
		update_appearance(UPDATE_ICON_STATE)
		picked = TRUE

/obj/item/book/granter/spellbook/proc/get_or_make_mastery()
	if(!mastery)
		mastery = new /datum/spell_mastery(null, src)
	return mastery


/obj/item/book/granter/spellbook/proc/apply_themed_bonuses()
	if(base_form_points > 0)
		if(themed_form)
			var/themed_amount = CEILING(base_form_points * 0.5, 1)
			var/generic_amount = base_form_points - themed_amount
			mastery.adjust_form_mastery_points(themed_amount, FALSE, themed_form)
			if(generic_amount)
				mastery.adjust_form_points(generic_amount)
		else
			mastery.adjust_form_points(base_form_points)

	if(base_technique_points > 0)
		mastery.adjust_technique_points(base_technique_points)

	if(themed_form && (themed_cost_multiplier != 1 || themed_cast_speed_multiplier != 1 || themed_magnitude_bonus != 0))
		AddComponent(/datum/component/spell_modifier, \
			list("[themed_form]" = themed_cost_multiplier), \
			list("[themed_form]" = themed_cast_speed_multiplier), \
			list("[themed_form]" = themed_magnitude_bonus))

// ============================================================
// VISUAL / OPEN STATE
// ============================================================

/// The open and closed states share identical mob prop data, so we return
/// one table regardless of open state.
/obj/item/book/granter/spellbook/getonmobprop(tag)
	. = ..()
	if(!tag)
		return
	switch(tag)
		if("gen")
			return list(
				"shrink" = 0.4,
				"sx" = -2, "sy" = -3,
				"nx" = 10, "ny" = -2,
				"wx" = 1,  "wy" = -3,
				"ex" = 5,  "ey" = -3,
				"northabove" = 0, "southabove" = 1,
				"eastabove" = 1,  "westabove" = 0,
				"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
				"nflip" = 0, "sflip" = 0, "wflip" = 0, "eflip" = 0
			)
		if("onbelt")
			return list(
				"shrink" = 0.3,
				"sx" = -2, "sy" = -5,
				"nx" = 4,  "ny" = -5,
				"wx" = 0,  "wy" = -5,
				"ex" = 2,  "ey" = -5,
				"nturn" = 0, "sturn" = 0, "wturn" = 0, "eturn" = 0,
				"nflip" = 0, "sflip" = 0, "wflip" = 0, "eflip" = 0,
				"northabove" = 0, "southabove" = 1,
				"eastabove" = 1,  "westabove" = 0
			)

/obj/item/book/granter/spellbook/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state]_[open]"

/obj/item/book/granter/spellbook/attack_self(mob/user, list/modifiers)
	if(!open)
		attack_hand_secondary(user, modifiers)
		return
	if(SEND_SIGNAL(src, COMSIG_ITEM_ATTACK_SELF, user, modifiers) & COMPONENT_CANCEL_ATTACK_CHAIN)
		return TRUE
	..()
	user.update_inv_hands()

/obj/item/book/granter/spellbook/attack_self_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	attack_hand_secondary(user, modifiers)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/book/granter/spellbook/read(mob/user)
	return FALSE

/obj/item/book/granter/spellbook/attack_hand_secondary(mob/user, list/modifiers)
	//first pick styles
	if(!picked)
		var/the_time = world.time
		var/design = input(user, "Select a design.", "Spellbook Design") as null|anything in designlist
		if(!design || world.time > (the_time + 30 SECONDS))
			return
		base_icon_state = "spellbook[design]"
		update_appearance(UPDATE_ICON_STATE)
		picked = TRUE
		return

	//now we togge state
	if(owner == null)
		owner = user
	if(!open)
		slot_flags &= ~ITEM_SLOT_HIP
		open = TRUE
		playsound(src, 'sound/items/book_open.ogg', 100, FALSE, -1)
	else
		slot_flags |= ITEM_SLOT_HIP
		open = FALSE
		playsound(src, 'sound/items/book_close.ogg', 100, FALSE, -1)
	curpage = 1
	update_appearance(UPDATE_ICON_STATE)
	user.update_inv_hands()

/obj/item/book/granter/spellbook/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with))
		return NONE

	var/mob/living/target = interacting_with
	if(target.stat == DEAD)
		target.visible_message(span_danger("[user] smacks [target]'s lifeless corpse with [src]."))
		playsound(src, "punch", 25, TRUE, -1)
		return

	if(user == target)
		to_chat(user, span_warning("I'm already chained to this tome!"))
		return

	target.visible_message(
		span_danger("[user] beats [target] over the head with [src]!"),
		span_danger("[user] beats [target] over the head with [src]!")
	)

	if(length(allowed_readers) > 2 || (target in allowed_readers))
		to_chat(user, span_smallnotice("I can't chain [target.p_them()] to my tome..."))
		return

	allowed_readers += target

	playsound(src, "punch", 25, TRUE, -1)

/obj/item/book/granter/spellbook/on_reading_start(mob/user)
	to_chat(user, span_notice("Arcyne mysteries abound in this enigmatic tome, gift of Noc..."))

/obj/item/book/granter/spellbook/on_reading_finished(mob/user)
	var/mob/living/carbon/human/gamer = user
	if(gamer != owner && !allowed_readers.Find(gamer))
		to_chat(user, span_notice("What was that gibberish? Even for the arcyne it was completely illegible!"))
		recoil(user)
		return

	user.mind?.has_studied = TRUE
	var/mob/living/reader = user

	// Base quality is a blend of INT, reading skill, and arcane skill.
	var/qualityoflearn = (GET_MOB_ATTRIBUTE_VALUE(reader, STAT_INTELLIGENCE) * 2 + GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/misc/reading) * 5 + GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/magic/arcane) * 5)

	// Bonuses from external factors.
	if(reader.has_status_effect(/datum/status_effect/buff/weed))
		to_chat(user, span_smallgreen("Swampweed truly does open one's third eye to the secrets of the arcyne..."))
		qualityoflearn += 10

	var/obj/effect/decal/cleanable/ritual_rune/rune = locate(/obj/effect/decal/cleanable/ritual_rune) in range(1, user)
	if(rune)
		to_chat(user, span_cultsmall("The rune beneath my feet glows..."))
		qualityoflearn += rune.spellbonus
		rune.do_invoke_glow()

	if(stored_gem)
		to_chat(user, span_smallnotice("I can feel the magical energies imbued within the crystalline dust scattered upon my tome resonate with the arcyne..."))
		qualityoflearn += stored_gem
		stored_gem = FALSE

	// Penalties for untrained readers.
	if(GET_MOB_SKILL_VALUE(user, /datum/attribute/skill/magic/arcane) <= SKILL_LEVEL_NONE)
		if(gamer != owner)
			qualityoflearn = 1
		else
			qualityoflearn = min(qualityoflearn * 0.5, 15)

	// Born-of-rock tomes are easier to craft, so they're harder to read.
	if(born_of_rock)
		qualityoflearn *= 0.8

	user.visible_message(
		span_warning("[user] is filled with arcyne energy! You witness [user.p_their()] body convulse and spark brightly."),
		span_notice("Noc blesses me. I have been granted knowledge and wisdom beyond my years, this tome's mysteries unveiled one at a time.")
	)

	var/spellpoints = CEILING(bookquality * (qualityoflearn / 100), 1)
	reader.adjust_spell_points(spellpoints)

	if(stored_attunement)
		user.mana_pool?.adjust_attunement(stored_attunement, 0.1 * (spellpoints / 0.2))

	user.log_message("successfully studied their spellbook and gained spellpoints", LOG_ATTACK, color = "orange")
	onlearned(user)

	if(prob(55))
		to_chat(user, span_notice("Confounded arcyne mysteries, my notes have gone in circles. I must sleep before I can bring myself to open this damned thing again..."))
		user.mind?.add_sleep_experience(/datum/attribute/skill/misc/reading, GET_MOB_ATTRIBUTE_VALUE(reader, STAT_INTELLIGENCE) * 10)

	to_chat(user, span_small("My notes include passages I've read before, but don't understand. I must sleep on their meaning..."))

/obj/item/book/granter/spellbook/onlearned(mob/user)
	used = FALSE

/obj/item/book/granter/spellbook/recoil(mob/user)
	user.visible_message(span_warning("[src] shoots out a spark of angry, arcyne energy at [user]!"))
	var/mob/living/gamer = user
	gamer.electrocute_act(5, src)

/obj/item/book/granter/spellbook/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/gem))
		return NONE

	if(stored_gem)
		to_chat(user, span_notice("This tome is already coursing with arcyne energies..."))
		return ITEM_INTERACT_BLOCKING

	if(GET_MOB_SKILL_VALUE(user, /datum/attribute/skill/magic/arcane) <= SKILL_LEVEL_NONE)
		to_chat(user, span_notice("Why am I jamming a gem into a book? I must look like a fool!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/gem/gem = tool
	var/crafttime = max(0, 60 - GET_MOB_SKILL_VALUE_OLD(user, /datum/attribute/skill/magic/arcane) * 5)
	if(!do_after(user, crafttime, target = src))
		return ITEM_INTERACT_BLOCKING

	playsound(src, 'sound/magic/glass.ogg', 100, TRUE)
	to_chat(user, span_notice("Running my arcyne energy through this crystal, I imbue the tome with my natural essence, attuning it to my state of mind..."))
	stored_gem = gem.arcyne_potency
	stored_attunement = gem.attuned
	qdel(tool)
	return ITEM_INTERACT_SUCCESS

/obj/item/book/granter/spellbook/horrible
	name = "poorly made tome of the arcyne"
	desc = "A poorly made book, it barely glows with arcyne and has only small notes on arcyne symbols."
	bookquality = 1
	sellprice = 15

/obj/item/book/granter/spellbook/mid
	name = "beginners tome of the arcyne"
	desc = "An obviously handcrafted book, it glows occasionally with arcyne and has a meager amount of notes on arcyne symbols."
	bookquality = 2
	sellprice = 30

/obj/item/book/granter/spellbook/apprentice
	name = "apprentice tome of the arcyne"
	desc = "A carefully made book, faintly glowing with arcyne and half filled with notes and theory on arcyne symbols."
	bookquality = 3
	sellprice = 75

/obj/item/book/granter/spellbook/adept
	name = "adept tome of the arcyne"
	desc = "A well-made book, it shines moderately with arcyne light. It has been filled with notes of varying degrees on the arcyne."
	bookquality = 4
	sellprice = 150

/obj/item/book/granter/spellbook/expert
	name = "expert tome of the arcyne"
	desc = "A well cared for book, shining brightly with arcyne. It has many runes and arcyne symbols scribed within, with detailed notes."
	bookquality = 6
	sellprice = 200

/obj/item/book/granter/spellbook/master
	name = "masterful tome of the arcyne"
	desc = "A crackling, glowing book, filled with advanced arcyne runes and symbols that hurt the mind to stare at. A true master of the arcyne has left their mark behind."
	bookquality = 8
	sellprice = 250

/obj/item/book/granter/spellbook/legendary
	name = "legendary tome of the arcyne"
	desc = "An incredible book that gives off glowing arcyne motes, it is filled with runes and arcyne theories that is hard for even masters of arcyne to understand. The arcyne script glows and practically whispers from the page..."
	bookquality = 12
	sellprice = 400

/obj/item/book/granter/spellbook/expert/fire
	name = "expert tome of the arcyne, aflame"
	desc = "A well cared for book, shining brightly with arcyne. Faint heat radiates from its pages, and its runes are all subtly singed."
	themed_form = FORM_FIRE
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("steel")

/obj/item/book/granter/spellbook/expert/ice
	name = "expert tome of the arcyne, frostbound"
	desc = "A well cared for book, shining brightly with arcyne. Its pages are cool to the touch, rimed with a frost that never quite melts."
	themed_form = FORM_ICE
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1

/obj/item/book/granter/spellbook/expert/lightning
	name = "expert tome of the arcyne, storm-charged"
	desc = "A well cared for book, shining brightly with arcyne. Tiny sparks crawl between its runes whenever the cover is opened."
	themed_form = FORM_LIGHTNING
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("steel")

/obj/item/book/granter/spellbook/expert/earth
	name = "expert tome of the arcyne, stoneveined"
	desc = "A well cared for book, shining brightly with arcyne. Its binding is threaded with fine mineral veins, heavy as river stone."
	themed_form = FORM_EARTH
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("steel")

/obj/item/book/granter/spellbook/expert/arcane
	name = "expert tome of the arcyne, thrice-warded"
	desc = "A well cared for book, shining brightly with arcyne. Its script folds in on itself in ways the eye struggles to follow."
	themed_form = FORM_ARCANE
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("gem")

/obj/item/book/granter/spellbook/expert/death
	name = "expert tome of the arcyne, grave-touched"
	desc = "A well cared for book, shining brightly with arcyne. A faint chill of the grave lingers about its pages."
	themed_form = FORM_DEATH
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("skin")

/obj/item/book/granter/spellbook/expert/life
	name = "expert tome of the arcyne, verdant"
	desc = "A well cared for book, shining brightly with arcyne. Its margins are traced with fine, living green filigree."
	themed_form = FORM_LIFE
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("mimic")

/obj/item/book/granter/spellbook/expert/air
	name = "expert tome of the arcyne, windswept"
	desc = "A well cared for book, shining brightly with arcyne. Its pages riffle gently even in still air."
	themed_form = FORM_AIR
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("steel")

/obj/item/book/granter/spellbook/expert/water
	name = "expert tome of the arcyne, tidebound"
	desc = "A well cared for book, shining brightly with arcyne. Condensation beads along its cover no matter how dry the room."
	themed_form = FORM_WATER
	base_form_points = 7
	base_technique_points = 3
	themed_cost_multiplier = 0.85
	themed_cast_speed_multiplier = 1.3
	themed_magnitude_bonus = 0.1
	designlist = list("steel")
