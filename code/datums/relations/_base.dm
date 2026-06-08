/datum/relation
	abstract_type = /datum/relation

	/// Display name shown in UI.
	var/name = "Relation"
	/// Flavour description shown to the holder.
	var/desc = ""
	/// List of /datum/grudge attached to this relation.
	var/list/grudges = null
	/// The mind that owns this relation entry.
	var/datum/mind/holder
	/// The mind on the other side.
	var/datum/mind/other
	/// For asymmetric relations, the counterpart datum on other's side.
	var/datum/relation/counterpart = null
	/// Whether this relation is symmetric (both sides share mutual awareness).
	var/symmetric = TRUE
	/// Relation types that cannot coexist with this one on the same pair.
	var/list/incompatible = null
	/// Snapshot of identity data at time of relation creation.
	/// Keys: "name", "vcolor", "job", "gender", "age"
	var/list/snapshot = null

/// Called when this relation is first established. Override to do setup.
/datum/relation/proc/on_created()
	return

/// Returns a sentence describing the relationship from an outside perspective.
/datum/relation/proc/get_desc_string()
	SHOULD_CALL_PARENT(FALSE)
	return "[holder?.name] and [other?.name] have a relationship."

/// Capture current identity state of the other mob into snapshot.
/datum/relation/proc/refresh_snapshot()
	if(!other?.current || !ishuman(other.current))
		return
	var/mob/living/carbon/human/H = other.current
	snapshot = list(
		"name"   = H.real_name,
		"vcolor" = H.voice_color,
		"job"    = _get_job_title(H),
		"gender" = H.gender,
		"age"    = H.age,
	)

/datum/relation/proc/_get_job_title(mob/living/carbon/human/H)
	if(H.job)
		var/datum/job/J = SSjob.GetJob(H.job)
		if(J)
			var/t = J.get_informed_title(H)
			if(t)
				return t
	return "Unknown"

/// Returns TRUE if this relation conflicts with an existing relation type.
/datum/relation/proc/conflicts_with(datum/relation/other_rel)
	if(!incompatible || !other_rel)
		return FALSE
	return (other_rel.name in incompatible)

/// Dissolve this relation from both minds and nullify counterpart links.
/datum/relation/proc/dissolve()
	if(holder)
		holder.relations -= src
	if(symmetric && other)
		// find and remove the mirrored datum on other's side
		for(var/datum/relation/R in other.relations)
			if(R.other == holder && R.type == type)
				other.relations -= R
				break
	if(counterpart)
		counterpart.counterpart = null
		counterpart.dissolve()
		counterpart = null

///this adds a grudge to a users grudge list and returns it
/datum/relation/proc/add_grudge(datum/grudge/grudge)
	LAZYADD(grudges, grudge)
	return grudge
