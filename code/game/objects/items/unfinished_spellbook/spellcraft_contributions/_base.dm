
GLOBAL_LIST_INIT(spellcraft_contributions, build_spellcraft_contributions())

/proc/build_spellcraft_contributions()
	. = list()
	for(var/contribution_type in typesof(/datum/spellcraft_contribution))
		var/datum/spellcraft_contribution/contribution = new contribution_type()
		if(!contribution.atom_path)
			continue
		if(contribution.include_subtypes)
			for(var/sub_path in typesof(contribution.atom_path))
				.[sub_path] = contribution
		else
			.[contribution.atom_path] = contribution

/datum/spellcraft_contribution
	abstract_type = /datum/spellcraft_contribution
	/// The atom typepath this contribution is registered under.
	var/atom/atom_path
	/// If TRUE, all subtypes of atom_path get mapped to this same singleton too.
	var/include_subtypes = FALSE

	/// FORM_X = amount
	var/list/form_points = list()
	/// TECHNIQUE_X = amount
	var/list/technique_points = list()
	var/list/form_cost_multipliers = list()
	var/list/form_cast_speed_multipliers = list()
	var/list/form_magnitude_modifications = list()
	var/list/technique_cost_multipliers = list()
	var/list/technique_cast_speed_multipliers = list()
	var/list/technique_magnitude_modifications = list()

/datum/spellcraft_contribution/proc/is_empty()
	return !length(form_points) && !length(technique_points) \
		&& !length(form_cost_multipliers) && !length(form_cast_speed_multipliers) && !length(form_magnitude_modifications) \
		&& !length(technique_cost_multipliers) && !length(technique_cast_speed_multipliers) && !length(technique_magnitude_modifications)

/datum/spellcraft_contribution/return_recipe_data(atom/source_path)
	var/list/data = list()
	data["type"] = "spellcraft"
	data["name"] = initial(atom_path.name)
	data["category"] = "Spellcraft"
	data["output_icon"] = "[initial(atom_path.icon)]"
	data["output_state"] = "[initial(atom_path.icon_state)]"
	data["_output_path"] = "[source_path]"

	var/list/forms = list()
	for(var/form in GLOB.all_forms)
		var/list/entry = list("name" = form, "color" = GLOB.form_colors[form])
		if(form_points[form])
			entry["points"] = form_points[form]
		if(form_cost_multipliers[form])
			entry["cost_mult"] = form_cost_multipliers[form]
		if(form_cast_speed_multipliers[form])
			entry["speed_mult"] = form_cast_speed_multipliers[form]
		if(form_magnitude_modifications[form])
			entry["magnitude_mod"] = form_magnitude_modifications[form]
		if(length(entry) > 2) // more than just name+color means it actually has data
			forms += list(entry)
	data["forms"] = forms

	var/list/techniques = list()
	for(var/technique in GLOB.all_techniques)
		var/list/entry = list("name" = technique)
		if(technique_points[technique])
			entry["points"] = technique_points[technique]
		if(technique_cost_multipliers[technique])
			entry["cost_mult"] = technique_cost_multipliers[technique]
		if(technique_cast_speed_multipliers[technique])
			entry["speed_mult"] = technique_cast_speed_multipliers[technique]
		if(technique_magnitude_modifications[technique])
			entry["magnitude_mod"] = technique_magnitude_modifications[technique]
		if(length(entry) > 1)
			techniques += list(entry)
	data["techniques"] = techniques

	return data
