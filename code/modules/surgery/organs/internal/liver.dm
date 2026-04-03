#define LIVER_DEFAULT_TOX_TOLERANCE 3 //amount of toxins the liver can filter out
#define LIVER_DEFAULT_TOX_LETHALITY 0.01 //lower values lower how harmful toxins are to the liver

/obj/item/organ/liver
	name = "liver"
	icon_state = "liver"
	w_class = WEIGHT_CLASS_SMALL
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LIVER
	desc = ""
	organ_efficiency = list(ORGAN_SLOT_LIVER = 100)
	maxHealth = STANDARD_ORGAN_THRESHOLD
	healing_factor = STANDARD_ORGAN_HEALING

	organ_volume = 2
	max_blood_storage = 25
	current_blood = 25
	blood_req = 4
	oxygen_req = 4
	nutriment_req = 4
	hydration_req = 4

	var/alcohol_tolerance = ALCOHOL_RATE        //affects how much damage the liver takes from alcohol
	var/toxTolerance = LIVER_DEFAULT_TOX_TOLERANCE  //maximum amount of toxins the liver can just shrug off
	var/toxLethality = LIVER_DEFAULT_TOX_LETHALITY  //affects how much damage toxins do to the liver
	var/filterToxins = FALSE                    //whether to filter toxins
	food_type = /obj/item/reagent_containers/food/snacks/meat/organ/liver

#undef LIVER_DEFAULT_TOX_TOLERANCE
#undef LIVER_DEFAULT_TOX_LETHALITY
