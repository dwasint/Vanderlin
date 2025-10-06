/datum/chimeric_table/animal
	compatible_blood_types = list(
		/datum/blood_type/animal,
	)
	preferred_blood_types = list(
		/datum/blood_type/animal,
	)
	incompatible_blood_types = list()
	base_blood_cost = 0.4
	node_tier = 1
	node_purity_min = 30
	node_purity_max = 60

/datum/chimeric_table/troll
	compatible_blood_types = list(
		/datum/blood_type/troll,
	)
	preferred_blood_types = list(
		/datum/blood_type/troll,
	)
	incompatible_blood_types = list()

	input_nodes = list(
		/datum/chimeric_node/input/heartbeat = 5,
		/datum/chimeric_node/input/death = -5,
	)
	output_nodes = list(
		/datum/chimeric_node/output/healing = 10,
	)

	base_blood_cost = 0.6
	node_tier = 2
	node_purity_min = 55
	node_purity_max = 80
