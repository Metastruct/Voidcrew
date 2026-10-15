// Per-character blood colour, ported from Bubber's "Blood Pigmentation" quirk.
//
// Voidcrew's blood colours live on singleton /datum/blood_type datums, so a per-character
// colour needs a dynamically-created recoloured type. We key those on (base type, colour)
// in a global cache, and point `type_key()` at the base so transfusions still work.
//
// The player-facing picker/quirk isn't ported yet - for now this is driven by the Bubber
// importer through the hidden `blood_color` preference.

GLOBAL_LIST_EMPTY(port_recolored_blood_types)

/// Bubber's "Blood Pigmentation" preset colours, keyed by their display name. Voidcrew
/// only defines a few of these, so the rest are inlined here.
GLOBAL_LIST_INIT(port_blood_color_presets, list(
	"Red/Human" = "#AA1010",
	"D.Green/Lizard" = "#035A00",
	"Green" = "#339933",
	"Lime/Xeno" = "#96BB00",
	"Violet/Avali" = "#9966FF",
	"Cyan/Vox" = "#33FFFF",
	"Teal/Skrell" = "#70B596",
	"White/Nanites" = "#CCCCCC",
	"Black" = "#1F1A00",
))

/// A blood type cloned from [base_type] with a different colour.
/datum/blood_type/recolored
	// Instantiated on demand by port_apply_blood_color(), not as a boot singleton.
	root_abstract_type = /datum/blood_type/recolored
	var/datum/blood_type/base_type
	var/recolor

/datum/blood_type/recolored/New(colour, datum/blood_type/orig)
	. = ..()
	base_type = orig
	recolor = colour
	name = "[orig.name] ([colour])"
	id = name
	color = colour
	desc = orig.desc
	dna_string = orig.dna_string
	reagent_type = orig.reagent_type
	restoration_chem = orig.restoration_chem
	blood_flags = orig.blood_flags
	is_species_universal = orig.is_species_universal
	// Transfusion compatibility must match the original type, so `type_key()` reports the
	// base type's key rather than ours.
	compatible_types = orig.compatible_types?.Copy()

/datum/blood_type/recolored/type_key()
	return base_type?.type_key()

/// Recolour [human]'s blood from the `blood_color` feature, if set. Recreates the type
/// when the base changes (e.g. species swap), so it can be called from on_species_gain.
/proc/port_apply_blood_color(mob/living/carbon/human/human)
	if(!ishuman(human))
		return
	var/colour = human.dna?.features?["blood_color"]
	if(!istext(colour) || !length(colour))
		return

	var/datum/blood_type/base = human.dna.blood_type
	if(!istype(base))
		return

	// Re-applying on top of one of our own recolours: unwrap to the real base first.
	var/datum/blood_type/recolored/current = base
	if(istype(current))
		if(current.recolor == colour)
			return
		base = current.base_type

	var/cache_key = "[base.id]__[colour]"
	var/datum/blood_type/recolored/stored = GLOB.port_recolored_blood_types[cache_key]
	if(isnull(stored))
		stored = new /datum/blood_type/recolored(colour, base)
		GLOB.port_recolored_blood_types[cache_key] = stored
		GLOB.blood_types[stored.id] = stored
	human.set_blood_type(stored)
