

/proc/place_ore_deposit(turf/T, ore_type)
	var/turf_type
	switch(ore_type)
		if("iron")
			turf_type = /turf/closed/mineral/iron
		if("copper")
			turf_type = /turf/closed/mineral/copper
		if("silver")
			turf_type = /turf/closed/mineral/silver
		if("gold")
			turf_type = /turf/closed/mineral/gold
		if("mithril")
			// Using mana_crystal as closest equivalent to mithril
			turf_type = /turf/closed/mineral/mana_crystal
		if("adamantine")
			// Using cinnabar as closest equivalent to adamantine
			turf_type = /turf/closed/mineral/cinnabar
		if("coal")
			turf_type = /turf/closed/mineral/coal
		if("tin")
			turf_type = /turf/closed/mineral/tin
		if("lead")
			// Using salt as closest equivalent to lead
			turf_type = /turf/closed/mineral/salt
		if("sulfur")
			// Using salt as closest equivalent to sulfur
			turf_type = /turf/closed/mineral/salt
		if("crystal")
			turf_type = /turf/closed/mineral/mana_crystal
		else
			turf_type = /turf/closed/mineral/iron

	T.ChangeTurf(turf_type, flags = CHANGETURF_SKIP)
