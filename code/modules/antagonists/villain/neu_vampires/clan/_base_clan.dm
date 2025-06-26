GLOBAL_LIST_EMPTY_TYPED(vampire_clans, /datum/clan)	//>:3

/*
This datum stores a declarative description of clans, in order to make an instance of the clan component from this implementation in runtime
And it also helps for the character set panel
*/
/datum/clan
	var/name = "Caitiff"
	var/desc = "The clanless. The rabble. Of no importance."

	var/list/clane_covens = list() //coven datums
	var/list/restricted_covens = list()
	var/list/common_covens = list() //Covens that you don't start with but are easier to purchase like catiff instead of non clan discs

	/// List of traits that are applied to members of this Clan
	var/list/clane_traits = list(
		TRAIT_STRONGBITE,
		TRAIT_NOSTAMINA,
		TRAIT_NOHUNGER,
		TRAIT_NOBREATH,
		TRAIT_NOPAIN,
		TRAIT_TOXIMMUNE,
		TRAIT_STEELHEARTED,
		TRAIT_NOSLEEP,
		TRAIT_VAMPMANSION,
		TRAIT_VAMP_DREAMS,
		TRAIT_NOAMBUSH,
		TRAIT_DARKVISION,
		TRAIT_LIMBATTACHMENT,
	)

	var/list/disliked_clans = list()
	var/list/liked_clans = list()


	var/list/clan_members = list()
	var/datum/clan_hierarchy_node/hierarchy_root
	var/list/datum/clan_hierarchy_node/all_positions = list()

	var/curse = "None."

	var/clane_curse //There should be a reference here.
	///The Clan's unique body sprite
	var/alt_sprite
	///If the Clan's unique body sprites need to account for skintone
	var/alt_sprite_greyscale = FALSE

	var/humanitymod = 1
	var/frenzymod = 1
	var/start_humanity = 7
	var/is_enlightened = FALSE
	var/whitelisted = FALSE
	var/accessories = list()
	var/accessories_layers = list()
	var/current_accessory

	var/mob/living/clan_leader
	var/leader_title = "Vampire Lord"
	var/datum/clan_leader/leader = /datum/clan_leader/lord

/datum/clan/proc/on_gain(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)

	var/datum/action/clan_menu/menu_action = new /datum/action/clan_menu()
	menu_action.Grant(H)

	RegisterSignal(H, COMSIG_HUMAN_LIFE, PROC_REF(on_vampire_life))

	for (var/trait in clane_traits)
		ADD_TRAIT(H, trait, "clan")

	for(var/datum/coven/coven as anything in clane_covens)
		H.give_coven(coven)

	if(length(accessories))
		if(current_accessory)
			H.remove_overlay(accessories_layers[current_accessory])
			var/mutable_appearance/acc_overlay = mutable_appearance('icons/effects/clan.dmi', current_accessory, -accessories_layers[current_accessory])
			H.overlays_standing[accessories_layers[current_accessory]] = acc_overlay
			H.apply_overlay(accessories_layers[current_accessory])

	if(alt_sprite)
		if (!alt_sprite_greyscale)
			H.skin_tone = "#fff4e6"
		H.dna.species.limbs_id = alt_sprite
		H.update_body_parts()
		H.update_body()

	apply_clan_components(H)


	setup_vampire_abilities(H)
	apply_vampire_look(H)

	H.has_reflection = FALSE
	H.cut_overlay(H.reflective_icon)
	H.mob_biotypes = MOB_UNDEAD

	clan_members |= H


	H.playsound_local(get_turf(H), 'sound/music/vampintro.ogg', 80, FALSE, pressure_affected = FALSE)

/datum/clan/proc/initialize_hierarchy()
	if(hierarchy_root)
		return

	// Create the root leadership position
	hierarchy_root = new /datum/clan_hierarchy_node("Clan Leader", "The supreme leader of the clan", 0)
	hierarchy_root.position_color = "#gold"
	hierarchy_root.can_assign_positions = TRUE
	hierarchy_root.max_subordinates = 10
	all_positions += hierarchy_root

	// Assign current clan leader if exists
	if(clan_leader)
		hierarchy_root.assign_member(clan_leader)


/datum/clan/proc/create_position(position_name, position_desc, datum/clan_hierarchy_node/superior_position, rank_level)
	if(!superior_position || !superior_position.can_assign_positions)
		return null

	var/datum/clan_hierarchy_node/new_position = new /datum/clan_hierarchy_node(position_name, position_desc, rank_level)

	if(superior_position.add_subordinate(new_position))
		all_positions += new_position
		return new_position
	else
		qdel(new_position)
		return null

/datum/clan/proc/remove_position(datum/clan_hierarchy_node/position)
	if(!position || position == hierarchy_root)
		return FALSE // Can't remove root position

	// Reassign subordinates to this position's superior
	if(position.superior)
		for(var/datum/clan_hierarchy_node/subordinate in position.subordinates)
			position.superior.add_subordinate(subordinate)

	// Remove member assignment
	position.remove_member()

	// Remove from superior's subordinates
	if(position.superior)
		position.superior.remove_subordinate(position)

	all_positions -= position
	qdel(position)
	return TRUE

/datum/clan/proc/apply_clan_components(mob/living/carbon/human/H)
	H.AddComponent(/datum/component/sunlight_vulnerability)
	H.AddComponent(/datum/component/vampire_disguise)

/**
 * Undoes the effects of on_gain to more or less
 * remove the effects of gaining the Clan. By default,
 * this proc only removes unique traits and resets
 * the mob's alternative sprite.
 *
 * Arguments:
 * * vampire - Human losing the Clan.
 */
/datum/clan/proc/on_lose(mob/living/carbon/human/vampire)
	SHOULD_CALL_PARENT(TRUE)

	UnregisterSignal(vampire, COMSIG_HUMAN_LIFE)

	// Remove unique Clan feature traits
	for (var/trait in clane_traits)
		REMOVE_TRAIT(vampire, trait, "clan")


	vampire.update_body()

	var/datum/component/sunlight_vulnerability/sun_comp = vampire.GetComponent(/datum/component/sunlight_vulnerability)
	if(sun_comp)
		qdel(sun_comp)

	var/datum/component/vampire_disguise/disguise_comp = vampire.GetComponent(/datum/component/vampire_disguise)
	if(disguise_comp)
		qdel(disguise_comp)

	vampire.has_reflection = TRUE
	vampire.create_reflection()
	vampire.update_reflection()

	clan_members -= vampire

/datum/clan/proc/frenzy_message(mob/living/message)
	to_chat(message,"I'm full of <span class='danger'><b>ANGER</b></span>, and I'm about to flare up in <span class='danger'><b>RAGE</b></span>.")

/datum/clan/proc/adjust_bloodpool_size(adjust)
	for(var/mob/living/mob as anything in clan_members)
		mob.maxbloodpool += adjust

/datum/clan/proc/on_vampire_life(mob/living/carbon/human/H)
	H.process_vampire_life()

/datum/clan/proc/setup_vampire_abilities(mob/living/carbon/human/H)
	// Add vampire verbs
	H.verbs |= /mob/living/carbon/human/proc/vamp_regenerate
	H.verbs |= /mob/living/carbon/human/proc/disguise_button

	// Set combat music
	H.cmode_music = 'sound/music/cmode/antag/CombatThrall.ogg'

	// Add blood magic skill
	H.adjust_skillrank(/datum/skill/magic/blood, 2, TRUE)

	// Add basic spell
	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/transfix)


/datum/clan/proc/apply_vampire_look(mob/living/carbon/human/H)
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)

	// Apply vampire appearance
	H.skin_tone = "c9d3de"
	H.set_hair_color("#181a1d", FALSE)
	H.set_facial_hair_color("#181a1d", FALSE)

	if(eyes)
		eyes.heterochromia = FALSE
		eyes.eye_color = "#FF0000"

	H.update_body()
	H.update_body_parts(redraw = TRUE)

/datum/clan/proc/post_gain(mob/living/carbon/human/H)
	SHOULD_CALL_PARENT(TRUE)
	if(!clan_leader && ispath(leader))
		var/datum/clan_leader/new_leader = new leader()
		leader = new_leader
		leader.lord_title = leader_title
		leader.make_new_leader(H)
		clan_leader = H


/**
 * Gives the human a vampiric Clan, applying
 * on_gain effects and post_gain effects if the
 * parameter is true. Can also remove Clans
 * with or without a replacement, and apply
 * on_lose effects. Will have no effect the human
 * is being given the Clan it already has.
 *
 * Arguments:
 * * setting_clan - Typepath or Clan singleton to give to the human
 * * joining_round - If this Clan is being given at roundstart and should call on_join_round
 */
/mob/living/carbon/human/proc/set_clan(setting_clan, joining_round)
	if(!length(GLOB.vampire_clans))
		for(var/clan_type in subtypesof(/datum/clan))
			var/datum/clan/clan = new clan_type
			GLOB.vampire_clans[clan_type] = clan
		sortList(GLOB.vampire_clans)

	var/datum/clan/previous_clan = clan

	// Convert typepaths to Clan singletons, or just directly assign if already singleton
	var/datum/clan/new_clan = ispath(setting_clan) ? GLOB.vampire_clans[setting_clan] : setting_clan

	// Handle losing Clan
	previous_clan?.on_lose(src)

	clan = new_clan

	// Clan's been cleared, don't apply effects
	if (!new_clan)
		return

	// Gaining Clan effects
	clan.on_gain(src, joining_round)

// Add to clan datum for easy access
/datum/clan/proc/open_clan_menu(mob/living/carbon/human/user)
	if(!user.covens || !length(user.covens))
		to_chat(user, "<span class='warning'>You have no covens to manage!</span>")
		return

	user.open_clan_menu()

// Add action button for clan menu
/datum/action/clan_menu
	name = "Clan Menu"
	desc = "Open your clan's power management interface"
	background_icon_state = "spell" //And this is the state for the background icon
	button_icon_state = "coven" //And this is the state for the action icon

/datum/action/clan_menu/Trigger()
	if(!owner || !ishuman(owner))
		return

	var/mob/living/carbon/human/user = owner
	if(!user.clan)
		to_chat(user, "<span class='warning'>You have no clan!</span>")
		return

	user.open_clan_menu()

