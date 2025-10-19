/datum/quality_calculator/blacksmithing
	name = "Blacksmithing Quality"

/datum/quality_calculator/blacksmithing/calculate_final_quality()
	var/avg_material = floor(material_quality / num_components) - 2

	// Using skill per hit to normalize across recipe complexity
	var/skill_per_hit = (performance_quality > 0 && skill_quality > 0) ? (skill_quality / performance_quality) : 0

	// Scale the divisor based on expected performance
	// At max skill (6) with good minigame (~70%), skill_per_hit is ~700-1000
	// We want that to translate to ~2-3 quality, needing +3-4 from materials for masterwork
	var/normalized_skill = floor(skill_per_hit / 400) + avg_material

	// Efficiency penalty: more hits = worse quality
	// Each hit costs quality, rewarding skilled players who finish quickly
	var/hit_penalty = floor(performance_quality * 0.3)

	// Difficulty penalty: harder recipes cap quality lower
	// Each point of difficulty reduces max achievable quality
	var/difficulty_penalty = floor(difficulty_modifier * 0.4)

	// Breakthrough bonus restoration (already subtracted from performance_quality before this)
	// This was already handled in handle_creation() where breakthroughs reduce performance_quality

	var/final_performance = normalized_skill - hit_penalty - difficulty_penalty

	return final_performance
