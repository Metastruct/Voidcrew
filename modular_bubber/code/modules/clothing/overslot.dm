// Form-fitting clothing that MODsuits can deploy (overslot) over.
//
// PORTED FROM: Bubberstation / upstream /tg/ #97872 ("Expands MODsuit overslotting to
// most form-fitting equipment..."). Upstream flagged each item inline with
// `item_flags = CAN_BE_OVERSLOT`; we instead re-declare the base types here (loaded
// last by `modular_bubber.dme`) so the core files stay untouched apart from the one
// `CAN_BE_OVERSLOT` define and the two `deploy()` checks it feeds.
//
// The flag is read in `code/modules/mod/mod_activation.dm` (deploy) and
// `code/modules/mod/mod_theme.dm` (rebuild), both tagged `MODSUIT_OVERSLOT`.

/obj/item/clothing/gloves
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/shoes
	item_flags = CAN_BE_OVERSLOT

// --- Suits / coats -----------------------------------------------------------------

/obj/item/clothing/suit/armor/vest
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/armor/laserproof
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/toggle/labcoat
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/jacket
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/toggle/jacket
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/apron
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/hazardvest
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/toggle/lawyer
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/mothcoat
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/suit/hooded/ethereal_raincoat
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/neck/cloak
	item_flags = CAN_BE_OVERSLOT

// --- Headwear / head accessories ---------------------------------------------------

/obj/item/clothing/head/wig
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/head/beanie
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/head/costume/kitty
	item_flags = CAN_BE_OVERSLOT

/obj/item/clothing/head/costume/rabbitears
	item_flags = CAN_BE_OVERSLOT
