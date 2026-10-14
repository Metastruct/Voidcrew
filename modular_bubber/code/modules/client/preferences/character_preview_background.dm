// Character-preview background picker, ported from Bubber.
//
// The preview canvas is a template image (32x32, 64x64 or 96x96) chosen by body size;
// the dummy is composited on top so a scaled character is shown in relation to the
// frame instead of being cropped/scrunched. See the PORT EDIT on `char_preview` in
// code/modules/client/preferences.dm.
//
// PORTED FROM: Bubberstation modular_zubbers/code/modules/character_preview_background.

/datum/preference/choiced/background_state
	category = PREFERENCE_CATEGORY_SECONDARY_FEATURES
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "background_state"
	// The menu renders each background as an icon swatch, so the server has to ship one.
	should_generate_icons = TRUE

GLOBAL_LIST_INIT(background_state_options, list(
	"000",
	"midgrey",
	"FFF",
	"white",
	"plasteel",
	"dark",
	"plating",
	"reinforced",
))

/datum/preference/choiced/background_state/create_default_value()
	return GLOB.background_state_options[1]

/datum/preference/choiced/background_state/init_possible_values()
	return GLOB.background_state_options

/datum/preference/choiced/background_state/icon_for(value)
	return uni_icon('modular_bubber/icons/zubbers/customization/template.dmi', value)

/datum/preference/choiced/background_state/compile_constant_data()
	var/list/data = ..()
	data[CHOICED_PREFERENCE_DISPLAY_NAMES] = list(
		"000" = "Black",
		"midgrey" = "Mid Grey",
		"FFF" = "Light Grey",
		"white" = "White",
		"plasteel" = "Plasteel",
		"dark" = "Dark",
		"plating" = "Plating",
		"reinforced" = "Reinforced",
	)
	return data

/datum/preference/choiced/background_state/apply_to_human(mob/living/carbon/human/target, value)
	return
