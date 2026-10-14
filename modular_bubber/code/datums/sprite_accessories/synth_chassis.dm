// Synthetic (IPC) chassis and head sprite accessories, ported from Bubber.
//
// Unlike mutant overlays these aren't drawn on top of a bodypart - the species swaps the
// bodypart's own icon/icon_state via `change_appearance()`. The accessory's `icon_state`
// is the prefix used for every piece (`bshipc_head`, `bshipc_chest`, ...), and `color_src`
// being set means the sheet is greyscale and gets tinted with the mutant colour.
// `dimorphic` marks chassis/heads with separate male/female art.
//
// PORTED FROM: Bubberstation modular_skyrat/.../sprite_accessories/ipc.dm
//              + modular_zubbers/.../sprite_accessories/ipc.dm

/datum/sprite_accessory/synth_chassis
	icon = 'modular_bubber/icons/skyrat/bodyparts/ipc_parts.dmi'
	icon_state = "ipc"
	color_src = null
	/// Does the body have separate male/female states?
	var/dimorphic = FALSE
	/// Can this chassis combine with digitigrade legs?
	var/is_digi_compatible = FALSE

/datum/sprite_accessory/synth_chassis/default
	name = "Default Chassis"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/synth_chassis/synth
	name = "Dark Chassis"
	icon_state = "synth"

/datum/sprite_accessory/synth_chassis/human
	name = "Human Chassis"
	icon = 'icons/mob/human/bodyparts_greyscale.dmi'
	icon_state = "human"
	color_src = MUTANT_COLOR
	dimorphic = TRUE

/datum/sprite_accessory/synth_chassis/android
	name = "Android Chassis"
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robotic"

/datum/sprite_accessory/synth_chassis/mammal
	name = "Mammal Chassis"
	icon = 'modular_bubber/icons/skyrat/bodyparts/synthmammal_parts_greyscale.dmi'
	icon_state = "synthmammal"
	color_src = MUTANT_COLOR
	dimorphic = TRUE
	is_digi_compatible = TRUE

/datum/sprite_accessory/synth_chassis/lizard
	name = "Lizard Chassis"
	icon = 'modular_bubber/icons/skyrat/bodyparts/synthliz_parts_greyscale.dmi'
	icon_state = "synthliz"
	color_src = MUTANT_COLOR
	dimorphic = TRUE
	is_digi_compatible = TRUE

/datum/sprite_accessory/synth_chassis/mcgreyscale
	name = "Morpheus Cyberkinetics"
	icon_state = "mcgipc"

/datum/sprite_accessory/synth_chassis/bishopcyberkinetics
	name = "Bishop Cyberkinetics"
	icon_state = "bshipc"

/datum/sprite_accessory/synth_chassis/bishopcyberkinetics2
	name = "Bishop Cyberkinetics 2.0"
	icon_state = "bs2ipc"

/datum/sprite_accessory/synth_chassis/hephaestussindustries
	name = "Hephaestus Industries"
	icon_state = "hsiipc"

/datum/sprite_accessory/synth_chassis/hephaestussindustries2
	name = "Hephaestus Industries 2.0"
	icon_state = "hi2ipc"

/datum/sprite_accessory/synth_chassis/shellguardmunitions
	name = "Shellguard Munitions Standard Series"
	icon_state = "sgmipc"

/datum/sprite_accessory/synth_chassis/wardtakahashimanufacturing
	name = "Ward-Takahashi Manufacturing"
	icon_state = "wtmipc"

/datum/sprite_accessory/synth_chassis/xionmanufacturinggroup
	name = "Xion Manufacturing Group"
	icon_state = "xmgipc"

/datum/sprite_accessory/synth_chassis/xionmanufacturinggroup2
	name = "Xion Manufacturing Group 2.0"
	icon_state = "xm2ipc"

/datum/sprite_accessory/synth_chassis/zenghupharmaceuticals
	name = "Zeng-Hu Pharmaceuticals"
	icon_state = "zhpipc"

/datum/sprite_accessory/synth_chassis/e3n
	name = "E3N AI"
	icon_state = "e3n"

/datum/sprite_accessory/synth_chassis/mariinsky
	name = "Mariinsky Ballet Company"
	icon_state = "mariinsky"

// --- Heads -------------------------------------------------------------------

/datum/sprite_accessory/synth_head
	icon = 'modular_bubber/icons/skyrat/bodyparts/ipc_parts.dmi'
	icon_state = "ipc"
	color_src = null
	/// Does the head have separate male/female states?
	var/dimorphic = FALSE

/datum/sprite_accessory/synth_head/default
	name = "Default Head"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/synth_head/synth
	name = "Dark Head"
	icon_state = "synth"

/datum/sprite_accessory/synth_head/human
	name = "Human Head"
	icon = 'icons/mob/human/bodyparts_greyscale.dmi'
	icon_state = "human"
	color_src = MUTANT_COLOR
	dimorphic = TRUE

/datum/sprite_accessory/synth_head/android
	name = "Android Head"
	icon = 'icons/mob/augmentation/augments.dmi'
	icon_state = "robotic"

/datum/sprite_accessory/synth_head/mammal
	name = "Mammal Head"
	icon = 'modular_bubber/icons/skyrat/bodyparts/synthmammal_parts_greyscale.dmi'
	icon_state = "synthmammal"
	color_src = MUTANT_COLOR
	dimorphic = TRUE

/datum/sprite_accessory/synth_head/lizard
	name = "Lizard Head"
	icon = 'modular_bubber/icons/skyrat/bodyparts/synthliz_parts_greyscale.dmi'
	icon_state = "synthliz"
	color_src = MUTANT_COLOR
	dimorphic = TRUE

/datum/sprite_accessory/synth_head/mcgreyscale
	name = "Morpheus Cyberkinetics (Greyscale)"
	icon_state = "mcgipc"
	color_src = MUTANT_COLOR

/datum/sprite_accessory/synth_head/bishopcyberkinetics
	name = "Bishop Cyberkinetics"
	icon_state = "bshipc"

/datum/sprite_accessory/synth_head/bishopcyberkinetics2
	name = "Bishop Cyberkinetics 2.0"
	icon_state = "bs2ipc"

/datum/sprite_accessory/synth_head/hephaestussindustries
	name = "Hephaestus Industries"
	icon_state = "hsiipc"

/datum/sprite_accessory/synth_head/hephaestussindustries2
	name = "Hephaestus Industries 2.0"
	icon_state = "hi2ipc"

/datum/sprite_accessory/synth_head/shellguardmunitions
	name = "Shellguard Munitions Standard Series"
	icon_state = "sgmipc"

/datum/sprite_accessory/synth_head/wardtakahashimanufacturing
	name = "Ward-Takahashi Manufacturing"
	icon_state = "wtmipc"

/datum/sprite_accessory/synth_head/xionmanufacturinggroup
	name = "Xion Manufacturing Group"
	icon_state = "xmgipc"

/datum/sprite_accessory/synth_head/xionmanufacturinggroup2
	name = "Xion Manufacturing Group 2.0"
	icon_state = "xm2ipc"

/datum/sprite_accessory/synth_head/zenghupharmaceuticals
	name = "Zeng-Hu Pharmaceuticals"
	icon_state = "zhpipc"

/datum/sprite_accessory/synth_head/e3n
	name = "E3N AI"
	icon_state = "e3n"

/datum/sprite_accessory/synth_head/mariinsky
	name = "Mariinsky Ballet Company"
	icon_state = "mariinsky"
	color_src = MUTANT_COLOR
