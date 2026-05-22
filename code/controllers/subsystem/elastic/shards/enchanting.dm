/datum/elastic_shard/enchanting
	name = "Enchantments"
	upload_frequency = 60 SECONDS
	shard_category = ELASCAT_ENCHANTING

/datum/elastic_shard/enchanting/get_endpoint()
	return CONFIG_GET(string/enchanting_endpoint)
