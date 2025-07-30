/obj/structure/blueprint
	name = "construction blueprint"
	desc = "A holographic blueprint for construction."
	icon = 'icons/effects/alphacolors.dmi'
	icon_state = "white"
	alpha = 150
	anchored = TRUE
	density = FALSE
	var/datum/blueprint_recipe/recipe
	var/mob/creator
	var/construction_progress = 0
	var/max_construction_progress = 100
	var/list/viewing_clients = list() // Clients who can see this blueprint
	var/blueprint_dir = SOUTH // Direction this blueprint will be built in

/obj/structure/blueprint/Initialize(mapload)
	. = ..()
	GLOB.active_blueprints += src

/obj/structure/blueprint/Destroy()
	GLOB.active_blueprints -= src
	clear_all_viewers()
	return ..()

/obj/structure/blueprint/attackby(obj/item/I, mob/user, params)
	if(!istype(I, recipe.construct_tool))
		return
	try_construct(user, I)

/obj/structure/blueprint/proc/setup_blueprint()
	if(!recipe)
		return

	name = "[recipe.name] blueprint"
	desc = "A blueprint for constructing [recipe.name]. [recipe.desc]"

	var/atom/result = recipe.result_type
	icon = initial(result.icon)
	icon_state = initial(result.icon_state)
	smoothing_icon = initial(result.icon_state)
	smoothing_flags = initial(result.smoothing_flags)
	smoothing_groups = initial(result.smoothing_groups)
	smoothing_list = initial(result.smoothing_list)

	if(smoothing_flags & SMOOTH_EDGE)
		smoothing_flags &= ~SMOOTH_EDGE

	SETUP_SMOOTHING()
	QUEUE_SMOOTH(src)
	QUEUE_SMOOTH_NEIGHBORS(src)
	dir = recipe.supports_directions ? blueprint_dir : initial(result.dir)
	color = "#00FFFF"

/obj/structure/blueprint/proc/add_viewer(mob/living/viewer)
	if(!viewer.client || (viewer.client in viewing_clients))
		return

	viewing_clients += viewer.client
	var/image/blueprint_image = image(icon, src, icon_state, layer, dir)
	blueprint_image.color = color
	blueprint_image.alpha = alpha
	viewer.client.images += blueprint_image

/obj/structure/blueprint/proc/remove_viewer(mob/living/viewer)
	if(!viewer.client || !(viewer.client in viewing_clients))
		return

	viewing_clients -= viewer.client
	for(var/image/I in viewer.client.images)
		if(I.loc == src)
			viewer.client.images -= I

/obj/structure/blueprint/proc/clear_all_viewers()
	for(var/client/C in viewing_clients)
		for(var/image/I in C.images)
			if(I.loc == src)
				C.images -= I
	viewing_clients.Cut()

/obj/structure/blueprint/proc/try_construct(mob/user, obj/item/weapon/hammer/hammer)
	if(!recipe)
		return FALSE

	var/list/available_materials = get_materials_in_range()
	var/list/needed_materials = recipe.required_materials.Copy()

	for(var/mat_type in needed_materials)
		var/needed_amount = needed_materials[mat_type]
		var/available_amount = available_materials[mat_type] || 0
		if(available_amount < needed_amount)
			var/atom/temp = mat_type
			to_chat(user, "<span class='warning'>Need [needed_amount - available_amount] more [initial(temp.name)]!</span>")
			return FALSE

	to_chat(user, "<span class='notice'>You begin constructing [recipe.name]...</span>")

	for(var/i = 1 to 100)
		if(!do_after(user, recipe.build_time, target = src))
			return FALSE

		available_materials = get_materials_in_range()
		for(var/mat_type in needed_materials)
			var/needed_amount = needed_materials[mat_type]
			var/available_amount = available_materials[mat_type] || 0
			if(available_amount < needed_amount)
				var/atom/temp = mat_type
				to_chat(user, "<span class='warning'>Missing [needed_amount - available_amount] [initial(temp.name)]!</span>")
				return FALSE

		var/prob2craft = 25
		var/prob2fail = 1

		if(recipe.craftdiff)
			prob2craft -= (25 * recipe.craftdiff)

		if(recipe.skillcraft)
			if(user.mind)
				prob2craft += (user.get_skill_level(recipe.skillcraft) * 25)
		else
			prob2craft = 100

		if(isliving(user))
			var/mob/living/L = user
			if(L.STALUC > 10)
				prob2fail = 0
			if(L.STALUC < 10)
				prob2fail += (10 - L.STALUC)
			if(L.STAINT > 10)
				prob2craft += ((10 - L.STAINT) * -1) * 2

		if(prob2craft < 1)
			to_chat(user, "<span class='danger'>I lack the skills for this...</span>")
			return FALSE
		else
			prob2craft = CLAMP(prob2craft, 5, 99)

			if(prob(prob2fail)) // Critical fail
				to_chat(user, "<span class='danger'>MISTAKE! I've completely fumbled the construction of [recipe.name]!</span>")
				return FALSE

			if(!prob(prob2craft))
				if(user.client?.prefs.showrolls)
					to_chat(user, "<span class='danger'>I've failed to construct [recipe.name]. (Success chance: [prob2craft]%)</span>")
				else
					to_chat(user, "<span class='danger'>I've failed to construct [recipe.name].</span>")
				continue

		consume_materials(needed_materials)

		if(!ispath(recipe.result_type, /turf))
			var/atom/new_structure = new recipe.result_type(get_turf(src))
			if(recipe.supports_directions)
				new_structure.dir = blueprint_dir
			new_structure.pixel_x = pixel_x
			new_structure.pixel_y = pixel_y
			if(!initial(recipe.edge_density) && ((abs(pixel_x) >= 14) || (abs(pixel_y) >= 14)))
				new_structure.density = FALSE
			new_structure.OnCrafted(user.dir, user) //!TODO This is likely fucked with the new stuff
		else
			var/turf/turf = get_turf(src)
			var/turf/new_turf = turf.ChangeTurf(recipe.result_type)
			if(new_turf)
				new_turf.OnCrafted(user.dir, user)

		user.visible_message("<span class='notice'>[user] [recipe.verbage_tp] [recipe.name]!</span>", \
							"<span class='notice'>I [recipe.verbage] [recipe.name]!</span>")


		if(recipe.craftsound)
			playsound(get_turf(src), recipe.craftsound, 100, TRUE)

		if(user.mind && recipe.skillcraft)
			if(isliving(user))
				var/mob/living/L = user
				var/amt2raise = L.STAINT * 2
				if(recipe.craftdiff > 0) // Difficult recipe gives more XP
					amt2raise += (recipe.craftdiff * 10)
				if(amt2raise > 0)
					user.mind.add_sleep_experience(recipe.skillcraft, amt2raise, FALSE)

		qdel(src)
		return TRUE

	to_chat(user, "<span class='danger'>After many attempts, I cannot manage to construct [recipe.name].</span>")
	return FALSE

/obj/structure/blueprint/proc/get_materials_in_range(range = 3)
	var/list/materials = list()

	for(var/obj/item/I in range(range, src))
		if(!materials[I.type])
			materials[I.type] = 0

		if(istype(I, /obj/item/natural/bundle))
			var/obj/item/natural/bundle/S = I
			materials[I.type] += S.amount
		else
			materials[I.type] += 1

	for(var/obj/item/natural/bundle/B in range(range, src))
		var/bundle_type = B.stacktype || B.type
		if(!materials[bundle_type])
			materials[bundle_type] = 0
		materials[bundle_type] += B.amount

	return materials

/obj/structure/blueprint/proc/consume_materials(list/needed_materials)
	for(var/mat_type in needed_materials)
		var/needed_amount = needed_materials[mat_type]

		for(var/obj/item/natural/bundle/B in range(3, src))
			var/bundle_type = B.stacktype || B.type
			if(bundle_type == mat_type && needed_amount > 0)
				var/consumed = min(needed_amount, B.amount)
				B.amount -= consumed
				if(B.amount <= 0)
					qdel(B)
				needed_amount -= consumed

		if(needed_amount > 0)
			for(var/obj/item/I in range(3, src))
				if(I.type == mat_type && needed_amount > 0)
					if(istype(I, /obj/item/natural/bundle))
						var/obj/item/natural/bundle/S = I
						var/consumed = min(needed_amount, S.amount)
						S.amount -= consumed
						if(S.amount <= 0)
							qdel(S)
						needed_amount -= consumed
					else
						qdel(I)
						needed_amount -= 1
