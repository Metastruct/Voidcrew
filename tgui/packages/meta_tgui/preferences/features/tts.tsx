// Metastruct TTS preference UI entries, ported from Bubberstation's modular_zzmeta.
//
// The exported names MUST match the DM preferences' `savefile_key`.
// Imported by the core PreferencesMenu features index via './tts'.

import { useBackend } from 'tgui/backend';
import {
  type Feature,
  type FeatureChoiced,
  type FeatureChoicedServerData,
  FeatureShortTextInput,
  type FeatureValueProps,
} from 'tgui/interfaces/PreferencesMenu/preferences/features/base';
import { FeatureDropdownInput } from 'tgui/interfaces/PreferencesMenu/preferences/features/dropdowns';
import { Button, Stack } from 'tgui-core/components';

function FeatureWhisperVoiceInput(
  props: FeatureValueProps<string, string, FeatureChoicedServerData>,
) {
  const { act } = useBackend();

  return (
    <Stack>
      <Stack.Item grow>
        <FeatureDropdownInput {...props} />
      </Stack.Item>
      <Stack.Item>
        <Button
          onClick={() => {
            act('play_whisper_voice');
          }}
          icon="play"
          width="100%"
          height="100%"
        />
      </Stack.Item>
    </Stack>
  );
}

export const tts_whisper_voice: FeatureChoiced = {
  name: 'TTS Whisper Voice',
  description: `
    The TTS voice used only while whispering.
    Leave as "Same as normal voice" to whisper in your normal TTS voice.
  `,
  component: FeatureWhisperVoiceInput,
};

export const tts_custom_voice: Feature<string> = {
  name: 'TTS Voice Customization',
  description: `
    Used by eSpeak, DECtalk and SAPI4 voices.
    eSpeak: "<voice> [speed=<n>] [pitch=<n>] [amplitude=<n>]", e.g. "en+m3 speed=180"
    (or inline in chat as "[en+m3 speed=180]").
    Ranges: speed 80-4000 (Sonic kicks in at 450), pitch 0-99, amplitude 0-1000
    (100 default; above 200 clips).
    DECtalk: raw commands, e.g. "[:ra 220][:dv hs 100]" (also usable inline in chat).
    SAPI4: "pitch=<n> speed=<n>" (clamped to the voice's own range), or inline in
    chat as "[Pit=200]", "[Spd=300]", "[Pau=1000]", "[Vol=150]", "[Rst]".
    Leave blank to use the selected preset.
  `,
  component: FeatureShortTextInput,
};

export const tts_whisper_custom: Feature<string> = {
  name: 'TTS Whisper Voice Customization',
  description: `
    Used by eSpeak, DECtalk and SAPI4 whisper voices.
    eSpeak: "<voice> [speed=<n>] [pitch=<n>] [amplitude=<n>]".
    Ranges: speed 80-4000 (Sonic kicks in at 450), pitch 0-99, amplitude 0-1000
    (100 default; above 200 clips).
    DECtalk: raw commands, e.g. "[:ra 160]".
    SAPI4: "pitch=<n> speed=<n>", or inline as "[Pit=200]" / "[Spd=300]".
    Leave blank to use the selected preset.
  `,
  component: FeatureShortTextInput,
};
