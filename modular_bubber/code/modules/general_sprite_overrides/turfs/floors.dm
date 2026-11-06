/turf/open/floor
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/turf/open/floor/wood
	icon = 'icons/turf/floors.dmi'

/turf/open/floor/iron/freezer
	icon = 'icons/turf/floors.dmi'

/turf/open/floor/iron/kitchen_coldroom
	icon = 'icons/turf/floors.dmi'

/turf/open/floor/catwalk_floor
	icon = 'modular_bubber/icons/zubbers/turf/floors/catwalk_plating.dmi'

/turf/open/indestructible
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/turf/open/floor/plating/reinforced
	icon = 'icons/turf/floors.dmi'

/turf/open/floor/iron/white/textured_large/airless
	initial_gas_mix = AIRLESS_ATMOS

/turf/open/floor/circuit
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/turf/open/floor/light/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/engine/cult
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/obj/effect/cult_turf
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/turf/open/floor/cult/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/bamboo
	icon = 'modular_bubber/icons/zubbers/turf/floors/bamboo_mat.dmi'

/turf/open/floor/bamboo/tatami
	icon = 'modular_bubber/icons/zubbers/turf/floors/floor_variations.dmi'

/turf/open/floor/bamboo/tatami/purple
	icon = 'modular_bubber/icons/zubbers/turf/floors/floor_variations.dmi'

/turf/open/floor/bamboo/tatami/black
	icon = 'modular_bubber/icons/zubbers/turf/floors/floor_variations.dmi'

/turf/open/floor/tram/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/tram/tram_platform/burnt_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/tram/plate/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/tram/plate/burnt_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/tram/plate/energized/broken_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

/turf/open/floor/tram/plate/energized/burnt_states()
	return list("damaged1", "damaged2", "damaged3", "damaged4", "damaged5")

// LIVING FLOORS

/mob/living/basic/living_floor
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/*
// OBJECT BASED
// I know these are objects but it's more organized if we keep specific ones here.

/obj/item/stack/tile
	icon = 'modular_bubber/icons/zubbers/obj/tiles.dmi'

/obj/item/stack/light_w
	icon = 'modular_bubber/icons/zubbers/obj/tiles.dmi'

// This isn't under stack/tile..... Look at you, light_w, you get an entire two lines to yourself!
// Enjoy it, because people only craft you out of mistake.

/obj/item/stack/tile/mineral/titanium
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/titanium,
		/obj/item/stack/tile/mineral/titanium/yellow,
		/obj/item/stack/tile/mineral/titanium/blue,
		/obj/item/stack/tile/mineral/titanium/white,
		/obj/item/stack/tile/mineral/titanium/purple,
		/obj/item/stack/tile/mineral/titanium/tiled,
		/obj/item/stack/tile/mineral/titanium/tiled/yellow,
		/obj/item/stack/tile/mineral/titanium/tiled/blue,
		/obj/item/stack/tile/mineral/titanium/tiled/white,
		/obj/item/stack/tile/mineral/titanium/tiled/purple,
		/obj/item/stack/tile/mineral/titanium/cargo,
		/obj/item/stack/tile/mineral/titanium/cargo/mainta,
		/obj/item/stack/tile/mineral/titanium/cargo/maintb,
		/obj/item/stack/tile/mineral/titanium/cargo/maintc,
		/obj/item/stack/tile/mineral/titanium/exploration,
		/obj/item/stack/tile/mineral/titanium/exploration/flat,
		/obj/item/stack/tile/mineral/titanium/exploration/flat_textured,
		/obj/item/stack/tile/mineral/titanium/exploration/hazard,
		/obj/item/stack/tile/mineral/titanium/shuttle_arrivals,
		/obj/item/stack/tile/mineral/titanium/shuttle_evac,
		)

/obj/item/stack/tile/mineral/bananium/tiled
	tile_rotate_dirs = list(SOUTH, NORTH, EAST, WEST, SOUTHEAST, SOUTHWEST, NORTHEAST, NORTHWEST)

/obj/structure/broken_flooring
	icon = 'modular_bubber/icons/zubbers/obj/fluff/brokentiling.dmi'

/obj/structure/transport/linear/public
	icon = 'modular_bubber/icons/zubbers/turf/floors.dmi'

/obj/structure/thermoplastic
	icon = 'modular_bubber/icons/zubbers/turf/floors/tram.dmi'
*/
