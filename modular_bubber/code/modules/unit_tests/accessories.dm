// Regression tests for the ported customization content.
//
// Included from the upstream test harness (see the PORT EDIT in
// code/modules/unit_tests/_unit_tests.dm), so the TEST_* macros are available.

/// Does [accessory] have at least one icon state that Voidcrew's mutant renderer can
/// build for [feature_key]? Catches missing/renamed art and feature-key mismatches.
/proc/meta_accessory_has_art(datum/sprite_accessory/accessory, feature_key)
	if(isnull(accessory) || isnull(accessory.icon) || isnull(accessory.icon_state))
		return FALSE
	var/prefix = "m_[feature_key]_[accessory.icon_state]_"
	for(var/state in icon_states(accessory.icon))
		if(findtext(state, prefix) == 1)
			return TRUE
	return FALSE

/datum/unit_test/meta_accessory_art/Run()
	var/static/list/checked = list(
		"ears" = list(SSaccessories.ears_list, FEATURE_EARS),
		"tails" = list(SSaccessories.tails_list_bubber, "tail"), // FEATURE_TAIL_GENERIC
		"snouts" = list(SSaccessories.snouts_list, FEATURE_SNOUT),
		"horns" = list(SSaccessories.horns_list, FEATURE_HORNS),
		"frills" = list(SSaccessories.frills_list, FEATURE_FRILLS),
	)

	for(var/category in checked)
		var/list/entry = checked[category]
		var/list/accessories = entry[1]
		var/feature_key = entry[2]
		TEST_ASSERT(length(accessories), "[category] list is empty!")

		var/failures = 0
		for(var/name in accessories)
			var/datum/sprite_accessory/accessory = accessories[name]
			if(!istype(accessory))
				continue
			if(accessory.icon_state in list(SPRITE_ACCESSORY_NONE, "none"))
				continue
			if(!meta_accessory_has_art(accessory, feature_key))
				failures++
				if(failures <= 5)
					TEST_FAIL("[category] accessory '[name]' ([accessory.icon_state]) has no m_[feature_key]_[accessory.icon_state]_* art in [accessory.icon]")
		TEST_ASSERT_EQUAL(failures, 0, "[category] had [failures] accessories with missing art")

/datum/unit_test/meta_mammal_species/Run()
	// The ported lists must have been built during SSaccessories PreInit.
	TEST_ASSERT(length(SSaccessories.tails_list_bubber), "tails_list_bubber was not populated")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/human/mammal)

	TEST_ASSERT(istype(human.dna.species, /datum/species/human/mammal), "set_species did not apply the anthromorph species")
	TEST_ASSERT_EQUAL(human.dna.species.id, "mammal", "anthromorph has the wrong id") // SPECIES_MAMMAL

	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EARS), /obj/item/organ/ears/bubber), "anthromorph is missing ported ears")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/tail/bubber), "anthromorph is missing a ported tail")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT), /obj/item/organ/snout), "anthromorph is missing a snout")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_HORNS), /obj/item/organ/horns), "anthromorph is missing horns")

	// Rendering must not runtime on the ported overlays.
	human.update_body()

/datum/unit_test/meta_mammal_variants/Run()
	var/static/list/variants = list(
		/datum/species/human/mammal/vulpkanin,
		/datum/species/human/mammal/tajaran,
		/datum/species/human/mammal/humanoid,
	)

	for(var/datum/species/variant as anything in variants)
		var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
		human.set_species(variant)

		TEST_ASSERT(istype(human.dna.species, variant), "set_species did not apply [variant]")
		TEST_ASSERT_EQUAL(human.dna.species.id, initial(variant.id), "[variant] has the wrong id")
		TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EARS), /obj/item/organ/ears/bubber), "[variant] is missing ported ears")
		TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/tail/bubber), "[variant] is missing a ported tail")
		TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_SNOUT), /obj/item/organ/snout), "[variant] is missing a snout")

		human.update_body()

/datum/unit_test/meta_bubber_import_translate/Run()
	var/list/bubber = list(
		"real_name" = "Test",
		"age" = 30,
		"gender" = "female",
		"body_type" = "female",
		"species" = "mammal",
		"feature_ears" = "Husky",
		"feature_tail" = "Fox",
		"feature_snout" = "Mammal, Long",
		"digitigrade_legs" = "Digitigrade Legs",
		"allow_mismatched_parts_toggle" = 1,
		"mutant_colors_color" = list("#111111", "#222222", "#333333"),
		"ears_color" = list("#444444", "#555555", "#666666"),
	)

	var/list/out = translate_bubber_character(bubber)
	TEST_ASSERT_EQUAL(out["species"], "mammal", "species did not map")
	TEST_ASSERT_EQUAL(out["gender"], "female", "gender did not map")
	TEST_ASSERT_EQUAL(out["body_type"], "female", "body_type did not map")
	TEST_ASSERT_EQUAL(out["feature_bubber_ears"], "Husky", "ears did not map")
	TEST_ASSERT_EQUAL(out["feature_bubber_tail"], "Fox", "tail did not map")
	TEST_ASSERT_EQUAL(out["feature_lizard_snout"], "Mammal, Long", "snout did not map")
	TEST_ASSERT_EQUAL(out["feature_lizard_legs"], "Digitigrade Legs", "legs did not map")
	TEST_ASSERT_EQUAL(out["feature_mcolor"], "111111", "mcolor did not strip the hash")
	TEST_ASSERT(out["allow_mismatched_parts_toggle"], "mismatched toggle did not map")
	// Unknown species must fall back to human rather than break the character.
	var/list/unknown = translate_bubber_character(list("species" = "not_a_species"))
	TEST_ASSERT_EQUAL(unknown["species"], SPECIES_HUMAN, "unknown species did not fall back to human")

/datum/unit_test/meta_synth_species/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/android/synthetic)

	TEST_ASSERT(istype(human.dna.species, /datum/species/android/synthetic), "set_species did not apply the synthetic species")
	TEST_ASSERT_EQUAL(human.dna.species.id, "synth", "synthetic has the wrong id") // SPECIES_SYNTH
	// Slot literals: these defines live in modular_bubber, compiled after the tests.
	TEST_ASSERT(istype(human.get_organ_slot("synth_screen"), /obj/item/organ/synth_screen), "synthetic is missing a screen")
	TEST_ASSERT(istype(human.get_organ_slot("synth_antenna"), /obj/item/organ/synth_antenna), "synthetic is missing an antenna")

	human.update_body()

/datum/unit_test/meta_teshari_species/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/human/teshari)

	TEST_ASSERT(istype(human.dna.species, /datum/species/human/teshari), "set_species did not apply the teshari species")
	TEST_ASSERT_EQUAL(human.dna.species.id, "teshari", "teshari has the wrong id") // SPECIES_TESHARI
	TEST_ASSERT(istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/teshari), "teshari did not get its custom head")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EARS), /obj/item/organ/ears/bubber), "teshari is missing ported ears")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/tail/bubber), "teshari is missing a ported tail")

	human.update_body()

/datum/unit_test/meta_shadekin_species/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/human/shadekin)

	TEST_ASSERT(istype(human.dna.species, /datum/species/human/shadekin), "set_species did not apply the shadekin species")
	TEST_ASSERT_EQUAL(human.dna.species.id, "shadekin", "shadekin has the wrong id") // SPECIES_SHADEKIN
	TEST_ASSERT(istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/shadekin), "shadekin did not get its custom head")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_BRAIN), /obj/item/organ/brain/shadekin), "shadekin is missing its dark-regeneration brain")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EARS), /obj/item/organ/ears/bubber), "shadekin is missing ported ears")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_TAIL), /obj/item/organ/tail/bubber), "shadekin is missing a ported tail")

	human.update_body()

/datum/unit_test/meta_podweak_species/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.set_species(/datum/species/pod/podweak)

	TEST_ASSERT(istype(human.dna.species, /datum/species/pod/podweak), "set_species did not apply the podweak species")
	TEST_ASSERT_EQUAL(human.dna.species.id, "podweak", "podweak has the wrong id") // SPECIES_PODPERSON_WEAK
	TEST_ASSERT(istype(human.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/pod), "podweak did not get pod bodyparts")
	TEST_ASSERT(istype(human.get_organ_slot(ORGAN_SLOT_EXTERNAL_POD_HAIR), /obj/item/organ/pod_hair), "podweak is missing its pod hair slot")
	// Photosynthesis rides on the pod bodyparts in modern Voidcrew.
	TEST_ASSERT(human.has_status_effect(/datum/status_effect/grouped/bodypart_effect/photosynthesis), "podweak is missing the photosynthesis bodypart effect")

	human.update_body()

// Genital art sanity. The anus is deliberately omitted: it has no on-mob art in Bubber.
/datum/unit_test/meta_genital_art/Run()
	// Feature-key literals: the modular __DEFINES compile after this file.
	var/static/list/checked = list(
		"penis" = list(SSaccessories.genital_penis_list, "penis"),
		"testicles" = list(SSaccessories.genital_testicles_list, "testicles"),
		"vagina" = list(SSaccessories.genital_vagina_list, "vagina"),
		"breasts" = list(SSaccessories.genital_breasts_list, "breasts"),
		"butt" = list(SSaccessories.genital_butt_list, "butt"),
		"belly" = list(SSaccessories.genital_belly_list, "belly"),
	)

	for(var/category in checked)
		var/list/entry = checked[category]
		var/list/accessories = entry[1]
		var/feature_key = entry[2]
		TEST_ASSERT(length(accessories), "[category] genital list is empty!")

		for(var/name in accessories)
			var/datum/sprite_accessory/genital/accessory = accessories[name]
			if(!istype(accessory))
				continue
			if(isnull(accessory.icon) || accessory.icon_state in list(SPRITE_ACCESSORY_NONE, "none"))
				continue
			TEST_ASSERT(meta_accessory_has_art(accessory, feature_key), "[category] accessory '[name]' has no matching art for [feature_key]")

/datum/unit_test/meta_genital_organs/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	var/static/list/genital_names = list(
		"penis" = "Human",
		"testicles" = "Pair",
		"vagina" = "Human",
		"womb" = "Normal",
		"anus" = "Anus",
		"breasts" = "Pair",
		"butt" = "Pair",
		"belly" = "Belly",
	)
	var/static/list/genital_organs = list(
		"penis" = /obj/item/organ/genital/penis,
		"testicles" = /obj/item/organ/genital/testicles,
		"vagina" = /obj/item/organ/genital/vagina,
		"womb" = /obj/item/organ/genital/womb,
		"anus" = /obj/item/organ/genital/anus,
		"breasts" = /obj/item/organ/genital/breasts,
		"butt" = /obj/item/organ/genital/butt,
		"belly" = /obj/item/organ/genital/belly,
	)

	for(var/slot in genital_organs)
		human.dna.features[slot] = genital_names[slot]
		var/org_path = genital_organs[slot]
		var/obj/item/organ/genital/organ = new org_path
		organ.Insert(human, special = TRUE, movement_flags = DELETE_IF_REPLACED)
		TEST_ASSERT(organ in human.organs, "[slot] organ was not inserted")
		TEST_ASSERT(!isnull(organ.bodypart_overlay), "[slot] organ is missing its bodypart overlay")
		var/suffix = organ.bodypart_overlay.get_base_icon_state()
		TEST_ASSERT(!isnull(suffix) && length("[suffix]"), "[slot] organ produced no sprite suffix")

	// Everything visible, to exercise the render path (3 = GENITAL_ALWAYS_SHOW).
	human.dna.features["allow_genitals"] = TRUE
	for(var/obj/item/organ/genital/genital in human.organs)
		genital.visibility_preference = 3
	human.update_body()

// The TGUI dropdown crashes on a null choice (capitalizeFirst(null)), which happens when
// an abstract intermediate accessory type sneaks a null into the list.
/datum/unit_test/meta_accessory_list_no_nulls/Run()
	var/static/list/checked = list(
		"ears" = SSaccessories.ears_list,
		"bubber tails" = SSaccessories.tails_list_bubber,
		"penis" = SSaccessories.genital_penis_list,
		"testicles" = SSaccessories.genital_testicles_list,
		"vagina" = SSaccessories.genital_vagina_list,
		"breasts" = SSaccessories.genital_breasts_list,
		"butt" = SSaccessories.genital_butt_list,
		"belly" = SSaccessories.genital_belly_list,
	)
	for(var/list_name in checked)
		var/list/accessories = checked[list_name]
		TEST_ASSERT(islist(accessories), "[list_name] list is null")
		for(var/key in accessories)
			TEST_ASSERT(!isnull(key) && length("[key]"), "[list_name] list contains a null/empty choice")

// The character preview re-runs apply_prefs_to() on every change, so genital organs must
// add, remove and re-sync from DNA rather than only being granted once.
/datum/unit_test/meta_genital_sync/Run()
	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)

	human.dna.features["penis"] = SPRITE_ACCESSORY_NONE
	meta_sync_genital_organs(human)
	TEST_ASSERT(isnull(human.get_organ_by_type(/obj/item/organ/genital/penis)), "None must not grant a genital organ")

	human.dna.features["penis"] = "Human"
	meta_sync_genital_organs(human)
	var/obj/item/organ/genital/penis = human.get_organ_by_type(/obj/item/organ/genital/penis)
	TEST_ASSERT(!isnull(penis), "A chosen sprite must grant the genital organ")

	human.dna.features["penis_size"] = 20
	meta_sync_genital_organs(human)
	TEST_ASSERT_EQUAL(penis.genital_size, 20, "A size change must re-sync the existing organ")

	human.dna.features["penis"] = SPRITE_ACCESSORY_NONE
	meta_sync_genital_organs(human)
	TEST_ASSERT(isnull(human.get_organ_by_type(/obj/item/organ/genital/penis)), "None must remove the existing organ")

// Per-limb body markings: the globals must be populated, every offered marking must
// resolve to art (the DM side filters zones without art, so this catches a regression
// in that filtering), and the render path must run.
/datum/unit_test/meta_body_markings/Run()
	TEST_ASSERT(length(GLOB.body_markings), "GLOB.body_markings was not populated")
	TEST_ASSERT(length(GLOB.body_marking_sets), "GLOB.body_marking_sets was not populated")

	var/failures = 0
	for(var/zone in GLOB.marking_zones)
		var/list/choices = GLOB.body_markings_per_limb[zone]
		if(!islist(choices))
			continue
		for(var/name in choices)
			var/datum/body_marking/marking = GLOB.body_markings[name]
			if(!meta_body_marking_has_art(marking, zone))
				failures++
				if(failures <= 5)
					TEST_FAIL("body marking '[name]' is offered for [zone] but has no art")
	TEST_ASSERT_EQUAL(failures, 0, "[failures] markings were offered without art")

	var/mob/living/carbon/human/human = allocate(/mob/living/carbon/human/consistent)
	human.dna.meta_set_body_marking(BODY_ZONE_CHEST, "Plain", "#FF0000")
	human.dna.meta_set_body_marking(BODY_ZONE_HEAD, "Flushed Cheeks", "#00FF00", TRUE)
	TEST_ASSERT(length(human.dna.body_markings), "meta_set_body_marking stored nothing")

	meta_sync_body_markings(human)
	var/obj/item/bodypart/chest = human.get_bodypart(BODY_ZONE_CHEST)
	TEST_ASSERT(LAZYLEN(chest.markings), "the chest bodypart did not receive its marking")

	// Also exercise sanitization: unknown names/zones are dropped.
	var/list/clean = sanitize_body_markings(list("bogus" = list("nope" = list("#FFFFFF", 0)), BODY_ZONE_CHEST = human.dna.body_markings[BODY_ZONE_CHEST]))
	TEST_ASSERT(isnull(clean["bogus"]), "sanitize_body_markings kept an unknown zone")
	TEST_ASSERT(LAZYLEN(clean[BODY_ZONE_CHEST]), "sanitize_body_markings dropped a valid marking")

	human.update_body(is_creating = TRUE)
