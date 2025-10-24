/datum/job/orthodoxist
	title = "Sacrestants"
	department_flag = INQUISITION
	faction = "Station"
	total_positions = 2 // TWO GOONS!!
	spawn_positions = 2
	allowed_races = RACES_PLAYER_ALL
	bypass_lastclass = TRUE

	allowed_patrons = list(
		/datum/patron/psydon
	)

	tutorial = "A student of the Oratorium in training to become a full Inquisitor. You’ve come here under the stern gaze of the Herr Präfekt to prove your wits and skill. This is your week. You’re going to take your place among the blades of Psydon."
	selection_color = JCOLOR_INQUISITION

	outfit = null
	outfit_female = null


	job_flags = (JOB_ANNOUNCE_ARRIVAL | JOB_SHOW_IN_CREDITS | JOB_EQUIP_RANK | JOB_NEW_PLAYER_JOINABLE)
	display_order = JDO_ORTHODOXIST
	min_pq = 0 // We need you to be atleast kinda competent to do this. This is a soft antaggy sorta role. Also needs to know wtf a PSYDON is

	advclass_cat_rolls = list(CTAG_INQUISITION = 20)
	same_job_respawn_delay = 30 MINUTES

/datum/job/orthodoxist/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		H.grant_language(/datum/language/oldpsydonic)
		if(!H.mind)
			return
		H.advsetup = 1
		H.invisibility = INVISIBILITY_MAXIMUM
		H.become_blind("advsetup")
