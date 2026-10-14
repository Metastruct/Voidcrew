// Per-limb body marking storage + rendering helpers, ported from Bubber.
//
// Markings are stored per bodypart as an assoc list of marking name -> list(colour,
// emissive), copied from `dna.body_markings` by update_limb(). Arms additionally carry
// the markings for their aux zone (the hand) so the arm's icon draw can render both.
//
// The actual draw happens in a PORT EDIT block in _bodyparts.dm's get_limb_icon().

/datum/dna
	/// Assoc list of body markings per body zone: zone -> (marking name -> list(colour, emissive)).
	var/list/body_markings = list()

/obj/item/bodypart
	/// Assoc list of marking name -> list(colour, emissive) for this limb.
	var/list/markings
	/// Marks for this limb's aux zone (hands), if it has one.
	var/list/aux_zone_markings
	/// Alpha the marking overlays are rendered at. Driven by the species' markings_alpha.
	var/markings_alpha = 255

/datum/species
	/// Alpha multiplier for this species' body markings (slimepeople render them faint).
	var/markings_alpha = 255

/// Copy `dna.body_markings` onto every bodypart of [human], and refresh the icon.
/// Called from on_species_gain() and apply_prefs_to(), mirroring meta_sync_mismatched_organs.
/proc/meta_sync_body_markings(mob/living/carbon/human/human, datum/species/species_override)
	if(!ishuman(human) || isnull(human.dna))
		return
	var/list/owner_markings = human.dna.body_markings
	var/datum/species/species = species_override || human.dna.species
	var/species_alpha = species?.markings_alpha || 255

	for(var/obj/item/bodypart/part as anything in human.bodyparts)
		part.markings = (islist(owner_markings) && islist(owner_markings[part.body_zone])) ? owner_markings[part.body_zone].Copy() : list()
		part.aux_zone_markings = (part.aux_zone && islist(owner_markings) && islist(owner_markings[part.aux_zone])) ? owner_markings[part.aux_zone].Copy() : list()
		part.markings_alpha = species_alpha

/// Read the markings this bodypart should draw from its owner's dna.
/obj/item/bodypart/proc/meta_set_markings_from_dna(mob/living/carbon/human/human_owner)
	if(isnull(human_owner) || isnull(human_owner.dna))
		return
	var/list/owner_markings = human_owner.dna.body_markings
	markings = (islist(owner_markings) && islist(owner_markings[body_zone])) ? owner_markings[body_zone].Copy() : list()
	aux_zone_markings = (aux_zone && islist(owner_markings) && islist(owner_markings[aux_zone])) ? owner_markings[aux_zone].Copy() : list()
	markings_alpha = human_owner.dna.species?.markings_alpha || 255
