/obj/structure/water_vent
	name = "fluid vent"
	desc = "Shoots out liquids and fluids."
	icon = 'icons/obj/structures/rotation_devices/water_vent.dmi'
	icon_state = "pipevent"

	accepts_water_input = TRUE

	var/obj/particle_emitter/emitter

/obj/structure/water_vent/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/structure/water_vent/valid_water_connection(direction, obj/structure/water_pipe/pipe)
	if(direction == dir)
		input = pipe
		return TRUE

/obj/structure/water_vent/process()
	if(input)
		spew_water()

/obj/structure/water_vent/proc/spew_water()
	emitter = locate(/obj/particle_emitter) in particle_emitters
	if(!emitter)
		emitter = MakeParticleEmitter(/particles/smoke/steam/water_pipe)
	var/datum/reagent/reagent = input.carrying_reagent
	emitter.color = initial(reagent.color)

	var/matrix/matrix = matrix()
	switch(dir)
		if(SOUTH)
			matrix.Turn(180)
		if(EAST)
			matrix.Turn(90)
		if(WEST)
			matrix.Turn(270)
	emitter.transform = matrix

	var/range = max(1, FLOOR(input.water_pressure * 0.1, 1))
	range = min(3, range)

	var/list/emitter_velocity = list(0, 0.25 * range, 0)
	emitter.particles.velocity = emitter_velocity


	var/datum/reagents/splash_holder
	for(var/i = 1 to range)
		var/turf/pipe_turf
		if(!pipe_turf)
			pipe_turf = get_turf(src)
		else
			pipe_turf = get_step(src, dir)

		if(isclosedturf(pipe_turf))
			break
		if(isopenspace(pipe_turf))
			while(isopenspace(pipe_turf))
				for(var/mob/living/mob in pipe_turf.contents)
					if(!splash_holder)
						splash_holder = new/datum/reagents(FLOOR(input.water_pressure * 0.5, 1))
						splash_holder.my_atom = src
						splash_holder.add_reagent(reagent, FLOOR(input.water_pressure * 0.5, 1))
					splash_holder.reaction(mob, TOUCH, 1)
				pipe_turf = get_step_multiz(pipe_turf, DOWN)
		if(istype(pipe_turf, /turf/open/water))
			var/turf/open/water/water = pipe_turf
			if(water.mapped)
				return
			var/taking_pressure = input.water_pressure
			use_water_pressure(taking_pressure)
			water.water_volume = min(water.water_volume + taking_pressure, water.water_maximum)

		for(var/mob/living/mob in pipe_turf.contents)
			if(!splash_holder)
				splash_holder = new/datum/reagents(FLOOR(input.water_pressure * 0.5, 1))
				splash_holder.my_atom = src
				splash_holder.add_reagent(reagent, FLOOR(input.water_pressure * 0.5, 1))
			splash_holder.reaction(mob, TOUCH, 1)


/obj/structure/water_vent/return_rotation_chat(atom/movable/screen/movable/mouseover/mouseover)
	mouseover.maptext_height = 96
	var/datum/reagent/reagent = input.carrying_reagent
	return {"<span style='font-size:8pt;font-family:"Pterra";color:#808000;text-shadow:0 0 1px #fff, 0 0 2px #fff, 0 0 30px #e60073, 0 0 40px #e60073, 0 0 50px #e60073, 0 0 60px #e60073, 0 0 70px #e60073;' class='center maptext '>
			Input Pressure: [input ? input.water_pressure : "0"]
			Fluid: [reagent ? initial(reagent.name) : "Nothing"]</span>"}
