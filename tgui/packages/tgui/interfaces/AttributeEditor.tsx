import { useBackend } from '../backend';
import {
  Box,
  Button,
  Divider,
  Flex,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { Window } from '../layouts';

type Attribute = {
  name: string;
  type: string;
  value: number;
  raw_value: number;
};

type Skill = {
  name: string;
  type: string;
  value: number;
  raw_value: number;
};

type AttributeEditorData = {
  parent: string;
  attribute_min: number;
  attribute_max: number;
  attribute_default: number;
  skill_min: number;
  skill_max: number;
  skill_default: number;
  cached_diceroll_modifier: number;
  attributes: Attribute[];
  skills: Skill[];
};

export const AttributeEditor = (props: object, context: object) => {
  const { act, data } = useBackend<AttributeEditorData>(context);
  const {
    parent,
    attribute_min = 0,
    attribute_max = 0,
    attribute_default = 0,
    skill_min = 0,
    skill_max = 0,
    skill_default = 0,
    cached_diceroll_modifier = 0,
    attributes = [],
    skills = [],
  } = data;

  return (
    <Window
      title={parent ? `${parent} Attributes Editor` : 'Attributes Editor'}
      width={600}
      height={700}
    >
      <Window.Content>
        <Flex
          height="100%"
          overflowX="hidden"
          overflowY="scroll"
          direction="column"
        >
          <Flex.Item grow>
            <Section title="Misc Variables">
              <LabeledList>
                {(
                  [
                    ['Attribute Max', 'attribute_max', attribute_max],
                    ['Attribute Min', 'attribute_min', attribute_min],
                    ['Attribute Default', 'attribute_default', attribute_default],
                    ['Skill Max', 'skill_max', skill_max],
                    ['Skill Min', 'skill_min', skill_min],
                    ['Skill Default', 'skill_default', skill_default],
                  ] as [string, string, number][]
                ).map(([label, var_name, value]) => (
                  <LabeledList.Item label={label} key={var_name}>
                    <NumberInput
                      value={value ?? 0}
                      step={1}
                      onChange={(val: number) =>
                        act('change_var', { var_name, var_value: val })
                      }
                    />
                    <Button
                      ml={1}
                      onClick={() => act('null_var', { var_name })}
                    >
                      NULL
                    </Button>
                  </LabeledList.Item>
                ))}
                <LabeledList.Item label="Diceroll Modifier">
                  <NumberInput
                    value={cached_diceroll_modifier ?? 0}
                    step={1}
                    onChange={(value: number) =>
                      act('change_diceroll_modifier', { new_value: value })
                    }
                  />
                </LabeledList.Item>
              </LabeledList>
            </Section>

            <Section title="Attributes">
              <LabeledList>
                {attributes.map((attribute) => (
                  <LabeledList.Item
                    label={attribute.name}
                    key={attribute.name}
                  >
                    <NumberInput
                      value={attribute.value ?? 0}
                      step={1}
                      onChange={(value: number) =>
                        act('change_attribute', {
                          attribute_type: attribute.type,
                          new_value: value,
                        })
                      }
                    />
                    <Button
                      ml={1}
                      onClick={() =>
                        act('null_attribute', {
                          attribute_type: attribute.type,
                        })
                      }
                    >
                      NULL
                    </Button>
                    <Box ml={1} mr={1} inline>
                      Raw:
                    </Box>
                    <NumberInput
                      value={attribute.raw_value ?? 0}
                      maxValue={attribute_max ?? 0}
                      minValue={attribute_min ?? 0}
                      step={1}
                      onChange={(value: number) =>
                        act('change_raw_attribute', {
                          attribute_type: attribute.type,
                          new_value: value,
                        })
                      }
                    />
                    <Button
                      ml={1}
                      onClick={() =>
                        act('null_raw_attribute', {
                          attribute_type: attribute.type,
                        })
                      }
                    >
                      NULL
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>

            <Section title="Skills">
              <LabeledList>
                {skills.map((skill) => (
                  <LabeledList.Item label={skill.name} key={skill.name}>
                    <NumberInput
                      value={skill.value ?? 0}
                      step={1}
                      onChange={(value: number) =>
                        act('change_attribute', {
                          attribute_type: skill.type,
                          new_value: value,
                        })
                      }
                    />
                    <Button
                      ml={1}
                      onClick={() =>
                        act('null_attribute', {
                          attribute_type: skill.type,
                        })
                      }
                    >
                      NULL
                    </Button>
                    <Box ml={1} mr={1} inline>
                      Raw:
                    </Box>
                    <NumberInput
                      value={skill.raw_value ?? 0}
                      maxValue={skill_max ?? 0}
                      minValue={skill_min ?? 0}
                      step={1}
                      onChange={(value: number) =>
                        act('change_raw_attribute', {
                          attribute_type: skill.type,
                          new_value: value,
                        })
                      }
                    />
                    <Button
                      ml={1}
                      onClick={() =>
                        act('null_raw_attribute', {
                          attribute_type: skill.type,
                        })
                      }
                    >
                      NULL
                    </Button>
                  </LabeledList.Item>
                ))}
              </LabeledList>
            </Section>
          </Flex.Item>
        </Flex>
      </Window.Content>
    </Window>
  );
};
