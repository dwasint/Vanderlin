/datum/job/orthodoxist
	title = "Orthodoxist"
	department_flag = INQUISITION
	faction = "Station"
	total_positions = 2 // TWO GOONS!!
	spawn_positions = 2
	allowed_races = RACES_PLAYER_ALL

	allowed_patrons = list(
		/datum/patron/psydon
	)

	tutorial = "A fervent believer in the cause of the Inquisition. Recruited by the Otavan Inquisitor to further the Psydonian goal in the locale."
	selection_color = JCOLOR_INQUISITION

	outfit = null
	outfit_female = null



	display_order = JDO_ORTHODOXIST
	min_pq = 0 // We need you to be atleast kinda competent to do this. This is a soft antaggy sorta role. Also needs to know wtf a PSYDON is

	advclass_cat_rolls = list(CTAG_INQUISITION = 20)
	same_job_respawn_delay = 30 MINUTES

/datum/job/orthodoxist/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(!H.mind)
			return
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
