/obj/item/organ/lungs
	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery
	name = "lungs"
	icon_state = "lungs"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	organ_efficiency = list(ORGAN_SLOT_LUNGS = 100)
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.8
	high_threshold = STANDARD_ORGAN_THRESHOLD * 0.4
	low_threshold = STANDARD_ORGAN_THRESHOLD * 0.2

	organ_volume = 1
	max_blood_storage = 25
	current_blood = 25
	blood_req = 4
	oxygen_req = 4
	nutriment_req = 4
	hydration_req = 4

	high_threshold_passed = "<span class='warning'>I feel some sort of constriction around my chest as my breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>My lungs seem to once again be able to hold air.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around my chest loosens as my breathing calms down.</span>"

	food_type = /obj/item/reagent_containers/food/snacks/meat/organ/lungs

/obj/item/organ/lungs/on_life()
	..()
	if((!failed) && ((organ_flags & ORGAN_FAILING)))
		if(owner.stat == CONSCIOUS)
			owner.visible_message("<span class='danger'>[owner] grabs [owner.p_their()] throat, struggling for breath!</span>", \
								"<span class='danger'>I suddenly feel like you can't breathe!</span>")
		failed = TRUE
	else if(!(organ_flags & ORGAN_FAILING))
		failed = FALSE
	return

/obj/item/organ/lungs/prepare_eat()
	var/obj/S = ..()
	return S

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = ""
	icon_state = "lungs-plasma"


/obj/item/organ/lungs/slime
	name = "vacuole"
	desc = ""
