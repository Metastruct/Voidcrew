// Per-limb body markings page for the Metastruct customization port.
//
// Data comes from the /datum/preference_middleware/body_markings middleware
// (`limbs_data` + `marking_presets`). Each limb lists the markings on it, with controls
// to change, recolour, toggle emissive, or remove them, plus a "+" to add one.
//
// PORTED FROM: Bubberstation's PreferencesMenu LimbsPage.tsx (markings half only; the
// limb/organ augmentation half belongs to an unported system.

import {
  Box,
  Button,
  ColorBox,
  Dropdown,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from 'tgui/backend';
import { CharacterPreview } from 'tgui/interfaces/common/CharacterPreview';

type Marking = {
  name: string;
  color: string;
  marking_id: string;
  emissive: number;
};

type LimbData = {
  slot: string;
  name: string;
  markings: {
    marking_choices: string[];
    markings_list: Marking[];
  };
};

type MarkingsPageData = {
  character_preview_view: string;
  limbs_data: LimbData[];
  marking_presets: string[];
};

const Markings = (props: { limb: LimbData }) => {
  const { act } = useBackend<MarkingsPageData>();
  const { limb } = props;
  return (
    <Stack fill vertical>
      {limb.markings.markings_list.map((marking) => (
        <Stack.Item key={marking.marking_id}>
          <Stack fill>
            <Stack.Item grow>
              <Dropdown
                width="100%"
                options={limb.markings.marking_choices}
                selected={marking.name}
                onSelected={(value) =>
                  act('change_marking', {
                    limb_slot: limb.slot,
                    marking_id: marking.marking_id,
                    marking_name: value,
                  })
                }
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                onClick={() =>
                  act('color_marking', {
                    limb_slot: limb.slot,
                    marking_id: marking.marking_id,
                  })
                }
              >
                <ColorBox color={marking.color} />
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color={marking.emissive ? 'good' : 'bad'}
                tooltip="The 'E' is for 'Emissive', meaning does it glow or not. Green for glow, red for no glow."
                onClick={() =>
                  act('change_emissive', {
                    limb_slot: limb.slot,
                    marking_id: marking.marking_id,
                    emissive: marking.emissive,
                  })
                }
              >
                E
              </Button>
            </Stack.Item>
            <Stack.Item>
              <Button
                color="bad"
                onClick={() =>
                  act('remove_marking', {
                    limb_slot: limb.slot,
                    marking_id: marking.marking_id,
                  })
                }
              >
                -
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ))}
      <Stack.Item>
        <Button
          color="good"
          onClick={() => act('add_marking', { limb_slot: limb.slot })}
        >
          +
        </Button>
      </Stack.Item>
    </Stack>
  );
};

export const MarkingsPage = (props) => {
  const { act, data } = useBackend<MarkingsPageData>();
  const presets = data.marking_presets || [];
  return (
    <Stack minHeight="100%">
      <Stack.Item minWidth="60%" minHeight="100%">
        <Section fill scrollable title="Body markings" height="100%">
          <Box mb={1}>
            <Dropdown
              width="100%"
              options={presets}
              selected={null}
              placeholder="Pick a preset:"
              onSelected={(value) => act('set_preset', { preset: value })}
            />
          </Box>
          {data.limbs_data.map((limb) => (
            <Section key={limb.slot} title={limb.name}>
              <Markings limb={limb} />
            </Section>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item minWidth="40%">
        <Section title="Character Preview" fill align="center" height="100%">
          <CharacterPreview id={data.character_preview_view} height="100%" />
        </Section>
      </Stack.Item>
    </Stack>
  );
};
