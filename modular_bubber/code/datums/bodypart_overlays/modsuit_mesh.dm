// "Mesh" bodypart texture: stamps a suit's mesh pattern over external organ overlays
// (tails, wings, ears, ...) so they appear to be under the suit.
//
// PORTED FROM: tgstation PR #97556 "Some species features now appear meshed over when
// wearing certain equipment" (MrMelbert).
//
// The upstream version lives on /datum/bodypart_texture (introduced by the big
// /datum/bodypart_overlay refactor). Voidcrew still has the earlier
// /datum/bodypart_overlay/texture subtype, so this is adapted to that: it is a texture
// overlay, not a standalone texture datum. The art (mesh_mask_space and friends) is
// copied from tg's icons/mob/clothing/tail_suit_mask.dmi.

/// Priority used by the mesh textures. Higher than every other bodypart texture so the
/// mesh wins when several would overlap.
#define BODYPART_OVERLAY_MESH 5

/datum/bodypart_overlay/texture/mesh
	texture_icon_state = "mesh_mask"
	texture_icon = 'modular_bubber/icons/tg/mob/clothing/tail_suit_mask.dmi'
	overlay_priority = BODYPART_OVERLAY_MESH
	/// Displacement map the mesh uses so its outline lines up with the bottom of the sprite
	var/displacement_icon_state = "mesh_mask_displacement"
	/// Icon file for the displacement map
	var/displacement_icon = 'modular_bubber/icons/tg/mob/clothing/tail_suit_mask.dmi'
	var/cached_displacement_icon
	/// Lighting map that gives the mesh a bit of depth
	var/lighting_icon_state = "mesh_mask_lighting"
	/// Icon file for the lighting map
	var/lighting_icon = 'modular_bubber/icons/tg/mob/clothing/tail_suit_mask.dmi'
	var/cached_lighting_icon
	/// Color of the outline filter, tweaked per suit
	var/outline_color = "#080808"

/datum/bodypart_overlay/texture/mesh/New()
	. = ..()
	cached_displacement_icon = icon(displacement_icon, displacement_icon_state)
	cached_lighting_icon = icon(lighting_icon, lighting_icon_state)

/datum/bodypart_overlay/texture/mesh/modify_bodypart_appearance(image/appearance)
	if(!should_modify(appearance))
		return
	. = ..()
	// adds a displacement map so the outline lines up with the bottom of the sprite
	appearance.add_filter("displacement", 2, displacement_map_filter(cached_displacement_icon, size = 1))
	// adds an outline so the texture doesn't end abruptly
	appearance.add_filter("outline", 3, outline_filter(1, outline_color, OUTLINE_SHARP))
	// adds a bit of lighting to make the texture look less flat
	appearance.add_filter("lighting", 4, layering_filter(cached_lighting_icon, blend_mode = BLEND_MULTIPLY))
	// forces white (blends better with the texture)
	appearance.color = COLOR_WHITE

/datum/bodypart_overlay/texture/mesh/proc/should_modify(image/appearance)
	// only apply to external organ overlays; filter by layer (not ideal, but the
	// alternative is a per-overlay flag we don't have in this older system)
	var/appearance_layer = abs(appearance.layer)
	return appearance_layer == BODY_ADJ_LAYER || appearance_layer == BODY_FRONT_LAYER || appearance_layer == BODY_BEHIND_LAYER

/datum/bodypart_overlay/texture/mesh/space
	texture_icon_state = "mesh_mask_space"
	outline_color = "#1F1F1F"
