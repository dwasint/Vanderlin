
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
	/// The atom typepath this contribution is registered under.
	var/atom_path
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
