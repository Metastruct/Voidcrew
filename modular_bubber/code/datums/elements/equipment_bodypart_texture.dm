/// Attached to clothing items to have them apply a texture to bodyparts when worn.
///
/// PORTED FROM: tgstation PR #97556 (MrMelbert). Upstream attaches/detaches against a
/// `bodypart_textures` list introduced by the bodypart-overlay refactor; Voidcrew still
/// uses `/datum/bodypart_overlay/texture` in `bodypart_overlays`, so we add/remove the
/// overlay instance instead of a typepath.
/datum/element/equipment_bodypart_texture
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2

	/// Bodypart we apply the texture to
	var/body_zone
	/// Texture we apply to the bodypart
	var/texture_type

/datum/element/equipment_bodypart_texture/Attach(datum/target, body_zone, texture_type)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.body_zone = body_zone
	src.texture_type = texture_type

	var/obj/item/target_item = target
	RegisterSignal(target_item, COMSIG_ITEM_EQUIPPED, PROC_REF(item_equipped))
	RegisterSignal(target_item, COMSIG_ITEM_DROPPED, PROC_REF(item_dropped))
	if(isliving(target_item.loc))
		var/mob/living/wearer = target_item.loc
		item_equipped(target_item, wearer, wearer.get_slot_by_item(target_item))

/datum/element/equipment_bodypart_texture/Detach(datum/source, ...)
	. = ..()
	var/obj/item/target_item = source
	UnregisterSignal(target_item, COMSIG_ITEM_EQUIPPED)
	UnregisterSignal(target_item, COMSIG_ITEM_DROPPED)
	if(isliving(target_item.loc))
		var/mob/living/wearer = target_item.loc
		item_dropped(target_item, wearer)

/datum/element/equipment_bodypart_texture/proc/item_equipped(obj/item/equipped_item, mob/living/carbon/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & equipped_item.slot_flags))
		return

	var/obj/item/bodypart/affected_bodypart = equipper.get_bodypart(body_zone)
	if(affected_bodypart)
		affected_bodypart.add_bodypart_overlay(new texture_type(), update = TRUE)
	RegisterSignal(equipper, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(limb_removed))
	RegisterSignal(equipper, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(limb_added))

/datum/element/equipment_bodypart_texture/proc/item_dropped(obj/item/dropped_item, mob/living/carbon/dropper)
	SIGNAL_HANDLER

	if(dropper.get_item_by_slot(dropped_item.slot_flags) != dropped_item)
		return

	var/obj/item/bodypart/affected_bodypart = dropper.get_bodypart(body_zone)
	remove_texture_from(affected_bodypart)
	UnregisterSignal(dropper, COMSIG_CARBON_POST_REMOVE_LIMB)
	UnregisterSignal(dropper, COMSIG_CARBON_POST_ATTACH_LIMB)

/datum/element/equipment_bodypart_texture/proc/limb_removed(mob/living/carbon/limb_owner, obj/item/bodypart/removed_limb)
	SIGNAL_HANDLER

	remove_texture_from(removed_limb, update = FALSE)

/datum/element/equipment_bodypart_texture/proc/limb_added(mob/living/carbon/limb_owner, obj/item/bodypart/added_limb)
	SIGNAL_HANDLER

	added_limb.add_bodypart_overlay(new texture_type(), update = FALSE)

/// Removes our texture overlay from the given bodypart, if present.
/datum/element/equipment_bodypart_texture/proc/remove_texture_from(obj/item/bodypart/bodypart, update = TRUE)
	if(!bodypart)
		return
	for(var/datum/bodypart_overlay/texture/texture as anything in bodypart.bodypart_overlays)
		if(texture.type != texture_type)
			continue
		bodypart.remove_bodypart_overlay(texture, update = update)
		break
