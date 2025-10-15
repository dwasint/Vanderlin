/*
			< ATTENTION >
	If you need to add more map_adjustment, check 'map_adjustment_include.dm'
	These 'map_adjustment.dm' files shouldn't be included in 'dme'
*/

/datum/map_adjustment/voyager
	map_file_name = "voyager.dmm"
	blacklist = list(
		/datum/job/orphan,
		/datum/job/apothecary,
		/datum/job/artificer,
		/datum/job/armorsmith,
		/datum/job/carpenter,
		/datum/job/feldsher,
		/datum/job/gaffer,
		/datum/job/matron,
		/datum/job/tailor,
		/datum/job/butler,
		/datum/job/grabber,
		/datum/job/undertaker,
		/datum/job/captain,
		/datum/job/consort,
		/datum/job/courtphys,
		/datum/job/hand,
		/datum/job/magician,
		/datum/job/merchant,
		/datum/job/forestwarden,
		/datum/job/gatemaster,
		/datum/job/royalknight,
		/datum/job/town_elder,
		/datum/job/veteran,
		/datum/job/lieutenant,
		/datum/job/prince,
		/datum/job/servant,
		/datum/job/mageapprentice,
		/datum/job/bapprentice,
		/datum/job/bandit,
	)
	slot_adjust = list(
		/datum/job/farmer = 1000,
		/datum/job/miner = 1000,
	)
