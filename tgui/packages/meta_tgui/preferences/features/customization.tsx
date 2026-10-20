// Preference UI entries for the Metastruct (modular_bubber) customization port.
//
// The PreferencesMenu builds its `features` registry from the exported names of
// feature files, keyed by savefile_key. A preference with no entry here renders
// "Feature <key> is not recognized." (character) or "...is not filled out
// properly!!!" (game preferences). The exported names MUST match the DM
// preferences' `savefile_key`.
//
// PORTED FROM: Bubberstation's preference menu features.

import type {
  Feature,
  FeatureChoiced,
  FeatureChoicedServerData,
  FeatureNumeric,
  FeatureToggle,
} from 'tgui/interfaces/PreferencesMenu/preferences/features/base';
import {
  CheckboxInput,
  FeatureColorInput,
  FeatureSliderInput,
  type FeatureValueProps,
} from 'tgui/interfaces/PreferencesMenu/preferences/features/base';
import { FeatureDropdownInput } from 'tgui/interfaces/PreferencesMenu/preferences/features/dropdowns';
import { useBackend } from 'tgui/backend';
import { Button, ColorBox, Stack } from 'tgui-core/components';
import type { PreferencesMenuData } from 'tgui/interfaces/PreferencesMenu/types';

function toggle(name: string, category?: string): FeatureToggle {
  return { name, component: CheckboxInput, category };
}

function dropdown(name: string, category?: string): FeatureChoiced {
  return { name, component: FeatureDropdownInput, category };
}

function slider(name: string, category?: string): FeatureNumeric {
  return { name, component: FeatureSliderInput, category };
}

function color(name: string, category?: string): Feature<string> {
  return { name, component: FeatureColorInput, category };
}

// Three-tone colour control: one swatch per matrixed layer, on a single row. Clicking a
// swatch asks the server to open the picker for that layer (`set_tri_color_layer`).
// Not exported, so it doesn't register as a feature of its own.
function FeatureTriColorInput(props: FeatureValueProps<string[]>) {
  const { act } = useBackend<PreferencesMenuData>();
  const { featureId, value } = props;
  const colors =
    Array.isArray(value) && value.length >= 3
      ? value
      : ['#ffffff', '#ffffff', '#ffffff'];
  return (
    <Stack>
      {[0, 1, 2].map((index) => (
        <Stack.Item key={index}>
          <Button
            onClick={() =>
              act('set_tri_color_layer', {
                preference: featureId,
                index: index + 1,
              })
            }
          >
            <ColorBox color={colors[index]} />
          </Button>
        </Stack.Item>
      ))}
    </Stack>
  );
}

function triColor(name: string, category?: string): Feature<string[]> {
  return { name, component: FeatureTriColorInput, category };
}

// Tri-state control: one checkbox per matrixed colour layer (primary/secondary/
// tertiary). Used by the per-part emissive preferences. Not exported, so it doesn't
// register as a feature of its own.
function FeatureTriBoolInput(props: FeatureValueProps<number[]>) {
  const { handleSetValue, value } = props;
  const flags = Array.isArray(value) ? value : [0, 0, 0];
  return (
    <Stack>
      {[0, 1, 2].map((index) => (
        <Stack.Item key={index}>
          <Button.Checkbox
            checked={!!flags[index]}
            onClick={() => {
              const next = [...flags];
              next[index] = next[index] ? 0 : 1;
              handleSetValue(next);
            }}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
}

function triBool(name: string): Feature<number[]> {
  return { name, component: FeatureTriBoolInput };
}

// --- Anthro framework (ears / tail / mismatched parts) -----------------------

export const allow_mismatched_parts_toggle = toggle(
  'Allow mismatched parts',
  'CHARACTER',
);

// Bubber exposes a three-tone "body colour" pair alongside the core primary mutant
// colour (`feature_mcolor`). Without these exports the second and third tones were
// applied on import but not visible/editable.
export const feature_mcolor_two = color('Body colour (secondary)');
export const feature_mcolor_three = color('Body colour (tertiary)');

// Bubber's body scale + discrete height.
export const body_size = slider('Body size');
export const height_scaling = dropdown('Height');
// Bubber's character-preview background picker (canvas backing image).
export const background_state = dropdown('Preview background');

// --- Emissives (glow) --------------------------------------------------------
// `allow_emissives_toggle` gates everything; each per-part control is three checkboxes
// (primary/secondary/tertiary glow).
export const allow_emissives_toggle = toggle('Allow emissions', 'CHARACTER');
export const eye_emissives = toggle('Eyes emit emissives');
export const feature_ears_emissive = triBool('Ears glow');
export const feature_tail_emissive = triBool('Tail glow');
export const feature_snout_emissive = triBool('Snout glow');
export const feature_horns_emissive = triBool('Horns glow');
export const feature_frills_emissive = triBool('Frills glow');
export const feature_spines_emissive = triBool('Spines glow');
export const feature_moth_antennae_emissive = triBool('Antennae glow');
export const feature_moth_wings_emissive = triBool('Moth wings glow');
export const feature_synth_antenna_emissive = triBool('Synth antenna glow');
export const feature_penis_emissive = triBool('Penis glow');
export const feature_testicles_emissive = triBool('Testicles glow');
export const feature_vagina_emissive = triBool('Vagina glow');
export const feature_breasts_emissive = triBool('Breasts glow');
export const feature_butt_emissive = triBool('Butt glow');
export const feature_belly_emissive = triBool('Belly glow');
// Named with an "(Anthro)" suffix so they don't collide with the core felinid/monkey/
// lizard "Ears"/"Tail" features when "allow mismatched parts" shows them all at once.
export const feature_bubber_ears = dropdown('Ears (Anthro)');
export const feature_bubber_tail = dropdown('Tail (Anthro)');
export const feature_fluff = dropdown('Fluff');

// Give the core species-specific dropdowns the same treatment, so the four tail/ear
// features are distinguishable when mismatched parts shows them side by side.
export const feature_human_ears = dropdown('Ears (Feline)');
export const feature_human_tail = dropdown('Tail (Feline)');
export const feature_lizard_tail = dropdown('Tail (Lizard)');
export const feature_monkey_tail = dropdown('Tail (Monkey)');

// --- Synth (IPC) screen / antenna --------------------------------------------

export const feature_synth_screen = dropdown('Screen');
export const feature_synth_antenna = dropdown('Antenna');
export const feature_synth_chassis = dropdown('Chassis');
export const feature_synth_head = dropdown('Head');

// "Legs Style" (Metastruct): the server sends the picker's value together with the choices
// this character may actually use (native styles, plus everything with "Allow Mismatched
// Parts" on), so foreign styles are never shown.
type LegStyleData = {
  value?: string;
  choices?: string[];
};

export const leg_style: FeatureChoiced = {
  name: 'Legs Style',
  component: (
    props: FeatureValueProps<string, string, FeatureChoicedServerData>,
  ) => {
    const raw = props.value as unknown;
    const packed =
      typeof raw === 'object' && raw !== null
        ? (raw as LegStyleData)
        : undefined;
    const value = packed?.value ?? (raw as string);
    const serverData =
      packed?.choices && props.serverData
        ? { ...props.serverData, choices: packed.choices }
        : props.serverData;
    return (
      <FeatureDropdownInput
        buttons
        {...props}
        value={value}
        serverData={serverData}
      />
    );
  },
};

// Chassis/head are single-tone (Bubber's ipc_chassis_color/ipc_head_color); the antenna
// is three-tone (ipc_antenna_color). Screens are pre-coloured and not tintable in Bubber
// either, so there is deliberately no screen colour picker.
export const synth_chassis_color = color('Chassis colour');
export const synth_head_color = color('Head colour');
export const ipc_antenna_color = triColor('Antenna colour');

// --- Mushroom cap (core pref that ships without a UI entry) -------------------

export const feature_mushperson_cap = dropdown('Mushroom cap');

// --- ERP gate ----------------------------------------------------------------

export const master_erp_pref = toggle('Adult content (ERP)', 'ERP');
export const allow_genitals_toggle = toggle('Allow genitals', 'CHARACTER');

// --- Genital shapes ----------------------------------------------------------

export const feature_penis = dropdown('Penis');
export const feature_testicles = dropdown('Testicles');
export const feature_vagina = dropdown('Vagina');
export const feature_breasts = dropdown('Breasts');
// Single-shape parts: a presence toggle rather than a one-option dropdown.
export const feature_womb = toggle('Womb');
export const feature_anus = toggle('Anus');
export const feature_butt = toggle('Butt');
export const feature_belly = toggle('Belly');

// --- Genital colours (three-tone) --------------------------------------------

export const penis_color = triColor('Penis colour');
export const testicles_color = triColor('Testicles colour');
export const vagina_color = triColor('Vagina colour');
export const breasts_color = triColor('Breasts colour');
export const butt_color = triColor('Butt colour');
export const belly_color = triColor('Belly colour');

// --- External organ colours (three-tone) -------------------------------------

export const ears_color = triColor('Ears colour');
export const tail_color = triColor('Tail colour');
export const snout_color = triColor('Snout colour');
export const horns_color = triColor('Horns colour');
export const frills_color = triColor('Frills colour');
export const spines_color = triColor('Spines colour');
export const wings_color = triColor('Wings colour');

// --- Genital sizes -----------------------------------------------------------

export const penis_length = slider('Penis length');
export const penis_girth = slider('Penis girth');
export const balls_size = slider('Testicle size');
export const breasts_size = slider('Breast size');
export const butt_size = slider('Butt size');
export const belly_size = slider('Belly size');

// --- Genital skin shading / colour ------------------------------------------
// "skin-tone shading" switches to the pre-shaded art variant; "match skin colour" tints
// with the owner's skin. The colour picker above only applies when the latter is off.

export const penis_skin_tone = toggle('Penis skin-tone shading');
export const penis_skin_color = toggle('Penis match skin colour');
export const testicles_skin_tone = toggle('Testicles skin-tone shading');
export const testicles_skin_color = toggle('Testicles match skin colour');
export const vagina_skin_tone = toggle('Vagina skin-tone shading');
export const vagina_skin_color = toggle('Vagina match skin colour');
export const breasts_skin_tone = toggle('Breasts skin-tone shading');
export const breasts_skin_color = toggle('Breasts match skin colour');
export const butt_skin_tone = toggle('Butt skin-tone shading');
export const butt_skin_color = toggle('Butt match skin colour');
export const belly_skin_tone = toggle('Belly skin-tone shading');
export const belly_skin_color = toggle('Belly match skin colour');

// --- Extra genital shape toggles --------------------------------------------

export const penis_sheath = dropdown('Penis sheath');
export const breasts_lactation_toggle = toggle('Breasts lactation');
export const penis_taur_mode_toggle = toggle('Taur penis sprites');

// --- Chat colours (modular_meta/modules/chat_colors) ------------------------

/// Player-picked IC chat colour; used for say/radio/LOOC names and overhead chat.
export const ic_chat_color: Feature<string> = {
  name: 'Chat color',
  description:
    'The color your name is shown in for say, radio, LOOC and overhead chat.',
  component: FeatureColorInput,
};

// --- LOOC (modular_bubber/modules/looc) -------------------------------------

export const enable_looc_runechat: FeatureToggle = {
  name: 'Enable LOOC runechat',
  category: 'RUNECHAT',
  description:
    "If TRUE, LOOC will appear above the speaker's head as well as in the chat.",
  component: CheckboxInput,
};

export const looc_admin_pref: FeatureToggle = {
  name: 'See remote LOOC',
  category: 'ADMIN',
  description:
    'Toggles whether you want to see LOOC anywhere as an admin or not.',
  component: CheckboxInput,
};
