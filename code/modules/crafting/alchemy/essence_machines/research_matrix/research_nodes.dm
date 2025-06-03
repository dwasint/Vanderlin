/datum/thaumic_research_node
	var/name = "Unknown Research"
	var/desc = "A mysterious field of study."
	var/icon = 'icons/roguetown/misc/alchemy.dmi'
	var/icon_state = "essence"
	var/list/required_essences = list()
	var/list/prerequisites = list()
	var/list/unlocks = list()
	var/experience_reward = 100
	var/node_x = 0
	var/node_y = 0
	var/list/connected_nodes = list()


/datum/thaumic_research_node/basic_understanding
	name = "Essence Knowledge"
	desc = "The understanding of essences."
	icon_state = "node"
	required_essences = list()
	node_x = 0
	node_y = 0

/datum/thaumic_research_node/transmutation
	name = "Basic Transmutation"
	desc = "The fundamental principles of transforming matter through thaumaturgical means."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/basic_understanding)
	required_essences = list(/datum/thaumaturgical_essence/fire = 10, /datum/thaumaturgical_essence/earth = 10)
	node_x = 100
	node_y = 40

/datum/thaumic_research_node/basic_splitter
	name = "Basic Splitter Efficency"
	desc = "Increase the effectiveness of splitting essences."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/basic_understanding)
	required_essences = list(
		/datum/thaumaturgical_essence/fire = 5,
		/datum/thaumaturgical_essence/earth = 5,
		/datum/thaumaturgical_essence/water = 5,
		/datum/thaumaturgical_essence/life = 5,
		/datum/thaumaturgical_essence/air = 5,
		/datum/thaumaturgical_essence/order = 5,
		/datum/thaumaturgical_essence/chaos = 5,
	)
	node_x = -50
	node_y = 50

/datum/thaumic_research_node/advanced_splitter
	name = "Advanced Splitter Efficency"
	desc = "Increase the effectiveness of splitting essences."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/basic_splitter)
	required_essences = list(
		/datum/thaumaturgical_essence/fire = 15,
		/datum/thaumaturgical_essence/earth = 15,
		/datum/thaumaturgical_essence/water = 15,
		/datum/thaumaturgical_essence/life = 15,
		/datum/thaumaturgical_essence/air = 15,
		/datum/thaumaturgical_essence/order = 15,
		/datum/thaumaturgical_essence/chaos = 15,
	)
	node_x = 20
	node_y = 70

/datum/thaumic_research_node/expert_splitter
	name = "Expert Splitter Efficency"
	desc = "Increase the effectiveness of splitting essences."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/advanced_splitter)
	required_essences = list(
		/datum/thaumaturgical_essence/fire = 45,
		/datum/thaumaturgical_essence/earth = 45,
		/datum/thaumaturgical_essence/water = 45,
		/datum/thaumaturgical_essence/life = 45,
		/datum/thaumaturgical_essence/air = 45,
		/datum/thaumaturgical_essence/order = 45,
		/datum/thaumaturgical_essence/chaos = 45,
	)
	node_x = -50
	node_y = 90

/datum/thaumic_research_node/master_splitter
	name = "Master Splitter Efficency"
	desc = "Increase the effectiveness of splitting essences."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/expert_splitter)
	required_essences = list(
		/datum/thaumaturgical_essence/fire = 100,
		/datum/thaumaturgical_essence/earth = 100,
		/datum/thaumaturgical_essence/water = 100,
		/datum/thaumaturgical_essence/life = 100,
		/datum/thaumaturgical_essence/air = 100,
		/datum/thaumaturgical_essence/order = 100,
		/datum/thaumaturgical_essence/chaos = 100,
	)
	node_x = -50
	node_y = 90

/datum/thaumic_research_node/gnomes
	name = "Life Synthesis"
	desc = "Understand the principals behind life."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/transmutation)
	required_essences = list(/datum/thaumaturgical_essence/life = 200)
	node_x = 100
	node_y = -100

/datum/thaumic_research_node/gnome_efficency
	name = "Improved Essence Handling"
	desc = "Reduces the essence needed to form form life."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/gnomes)
	required_essences = list(/datum/thaumaturgical_essence/life = 150, /datum/thaumaturgical_essence/energia = 50)
	node_x = 150
	node_y = -70

/datum/thaumic_research_node/gnome_speed
	name = "Improved Essence Incorperation"
	desc = "Improves the speed at which essences form life."
	icon_state = "node"
	prerequisites = list(/datum/thaumic_research_node/gnomes)
	required_essences = list(/datum/thaumaturgical_essence/life = 150, /datum/thaumaturgical_essence/cycle = 50)
	node_x = 150
	node_y = -130
