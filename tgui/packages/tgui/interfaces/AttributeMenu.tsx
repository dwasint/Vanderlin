import { useBackend } from '../backend';
import { Box, Button, Stack, Tooltip } from 'tgui-core/components';
import { Window } from '../layouts';

// --- Interfaces ---

interface Attribute {
  name: string;
  shorthand?: string;
  desc?: string;
  icon?: string;
  value: number | null;
  raw_value: number | null;
  difficulty?: string;
  governing_attribute?: string;
  default_value?: number;
  defaults?: Attribute[];
}

interface SkillCategory {
  name: string;
  skills: Attribute[];
}

interface AttributeData {
  show_bad_skills: boolean;
  parent?: string;
  skills_by_category: SkillCategory[];
  stats: Attribute[];
  closely_inspected_attribute: Attribute | null;
}

const CloserInspection = (props: { data: AttributeData; act: any }) => {
  const { data, act } = props;
  const attribute = data.closely_inspected_attribute;

  if (!attribute) return null;

  const hasDefaults = !!attribute.defaults?.length;

  return (
    <Stack width="100%" height="100%" vertical>
      <Stack.Item mb={0} height={hasDefaults ? '52.5%' : '85%'}>
        <Box width="100%" className="PreferencesMenu__papersplease__header__left">
          <Box
            textAlign="center"
            className="PreferencesMenu__papersplease__header__title"
            style={{ fontSize: '200%' }}>
            <Box>
              {attribute.name}
              {attribute.shorthand && (
                <span style={{ fontSize: '70%' }}> ({attribute.shorthand})</span>
              )}
            </Box>
            <Tooltip content="Stop inspecting" position="top">
              <Box
                className="PreferencesMenu__ribbon"
                onClick={() => act('inspect_closely')}
              />
            </Tooltip>
          </Box>
        </Box>
        <Box
          overflowY="hidden"
          width="100%"
          height="100%"
          className={
            hasDefaults
              ? 'PreferencesMenu__papersplease__leftbottomless'
              : 'PreferencesMenu__papersplease__left'
          }
          style={{ paddingTop: '8px', paddingBottom: '8px' }}>
          <Stack vertical={false}>
            <Stack.Item>
              <Box
                height="128px"
                width="128px"
                className={`attributes_big128x128 ${attribute.icon}`}
              />
            </Stack.Item>
            <Stack.Item overflowX="hidden" overflowY="hidden" width="85%" height="128px">
              <Box
                overflowX="hidden"
                overflowY="hidden"
                height="100%"
                width="100%"
                className="PreferencesMenu__papersplease__dotted">
                {attribute.desc}
                <Box mt={1.5} style={{ fontSize: '120%' }}>
                  {attribute.difficulty && (
                    <Box>
                      <b>Difficulty: </b> {attribute.difficulty}
                    </Box>
                  )}
                  {attribute.governing_attribute && (
                    <Box>
                      <b>Governing attribute: </b> {attribute.governing_attribute}
                    </Box>
                  )}
                </Box>
              </Box>
            </Stack.Item>
          </Stack>
        </Box>
      </Stack.Item>

      {hasDefaults && (
        <>
          <Stack.Item mt={0} mb={0}>
            <Box height={1} className="PreferencesMenu__papersplease__gutterhorizontal" />
          </Stack.Item>
          <Stack.Item mt={0} height="32.5%">
            <Box
              width="100%"
              className="PreferencesMenu__papersplease__header__leftnoradius">
              <Box
                textAlign="center"
                className="PreferencesMenu__papersplease__header__title"
                style={{ fontSize: '175%' }}>
                Defaults to:
              </Box>
            </Box>
            <Box
              overflowX="hidden"
              overflowY="scroll"
              height="100%"
              className="PreferencesMenu__papersplease__left"
              style={{
                paddingLeft: '4px',
                paddingRight: '4px',
                paddingTop: '10px',
                paddingBottom: '8px',
              }}>
              {attribute.defaults?.map((def) => (
                <Stack.Item
                  ml={1}
                  mb={2}
                  key={def.name}
                  style={{ fontSize: '165%' }}
                  onClick={() => act('inspect_closely', { attribute_name: def.name })}>
                  <Tooltip
                    position="bottom"
                    content={
                      <Box>
                        {def.desc}
                        {def.difficulty && <Box mt={0.5}>[{def.difficulty}]</Box>}
                      </Box>
                    }>
                    <Stack>
                      <Stack.Item vertical={false}>
                        <Box>
                          <Box
                            mr={1}
                            className={`attributes_small16x16 ${def.icon}`}
                          />
                          {def.name}
                          {def.shorthand && (
                            <span style={{ fontSize: '65%' }}> ({def.shorthand})</span>
                          )}
                        </Box>
                      </Stack.Item>
                      <Stack.Item ml={1}>
                        <Box textAlign="right">{def.default_value}</Box>
                      </Stack.Item>
                    </Stack>
                  </Tooltip>
                </Stack.Item>
              ))}
            </Box>
          </Stack.Item>
        </>
      )}
    </Stack>
  );
};

const AttributeStack = (props: { data: AttributeData; act: any }) => {
  const { data, act } = props;
  const { show_bad_skills, skills_by_category = [], stats = [] } = data;

  return (
    <Stack width="100%" height="100%" vertical={false}>
      {/* Stats Column */}
      <Stack.Item width="40%" height="90%">
        <Box width="100%" className="PreferencesMenu__papersplease__header__left">
          <Box
            textAlign="center"
            className="PreferencesMenu__papersplease__header__title"
            style={{ fontSize: '275%' }}>
            Stats
          </Box>
        </Box>
        <Box
          width="100%"
          height="52.5%"
          className="PreferencesMenu__papersplease__left"
          style={{
            paddingLeft: '4px',
            paddingRight: '4px',
            paddingTop: '8px',
            fontSize: '150%',
          }}>
          <Stack vertical>
            {!stats.length && <Box>No stats!</Box>}
            {stats.map((stat) => (
              <Stack.Item
                mb={2}
                width="100%"
                key={stat.name}
                onClick={() => act('inspect_closely', { attribute_name: stat.name })}>
                <Tooltip position="bottom" content={<Box>{stat.desc}</Box>}>
                  <Stack>
                    <Stack.Item width="85%" vertical={false}>
                      <Box width="100%">
                        <Box mr={1} className={`attributes_small16x16 ${stat.icon}`} />
                        {stat.name}
                        {stat.shorthand && (
                          <span style={{ fontSize: '65%' }}> ({stat.shorthand})</span>
                        )}
                      </Box>
                    </Stack.Item>
                    <Stack.Item>
                      <Box textAlign="right">
                        ({' '}
                        <span
                          style={{
                            color:
                              (stat.value ?? 0) < (stat.raw_value ?? 0)
                                ? '#800000'
                                : (stat.value ?? 0) > (stat.raw_value ?? 0)
                                ? '#008000'
                                : '',
                          }}>
                          {stat.value}
                        </span>
                        /{stat.raw_value})
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Tooltip>
              </Stack.Item>
            ))}
          </Stack>
        </Box>

        {/* Worthless Skills Toggle */}
        <Box
          mt={1}
          width="100%"
          className="PreferencesMenu__papersplease__header__left">
          <Box
            width="100%"
            textAlign="center"
            className="PreferencesMenu__papersplease__header__title"
            style={{ fontSize: '200%' }}>
            Show worthless skills?
          </Box>
        </Box>
        <Box
          height="20%"
          width="100%"
          className="PreferencesMenu__papersplease__left"
          style={{
            paddingLeft: '25%',
            paddingRight: '4px',
            paddingTop: '8px',
            fontSize: '175%',
          }}>
          <Stack mt={1} width="100%" vertical={false}>
            <Stack.Item>
              <Stack>
                <Stack.Item mr={0.5} ml={0}>
                  <Box mt={0.75} style={{ fontWeight: 'bold' }}>
                    No
                  </Box>
                </Stack.Item>
                <Stack.Item ml={0}>
                  <Tooltip
                    content="Skills you have absolutely no training on will not be shown."
                    position="right">
                    <Button
                      className="PreferencesMenu__Jobs__departments__attributebutton"
                      icon="times"
                      width="32px"
                      height="32px"
                      color={!show_bad_skills ? 'paperplease' : 'null'}
                      onClick={() => act('disable_bad_skills')}
                      circular
                    />
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Stack.Item>
            <Stack.Item>
              <Stack>
                <Stack.Item mr={0.5}>
                  <Box mt={0.75} style={{ fontWeight: 'bold' }}>
                    Yes
                  </Box>
                </Stack.Item>
                <Stack.Item ml={0}>
                  <Tooltip
                    content="Skills you have absolutely no training on will be shown."
                    position="right">
                    <Button
                      className="PreferencesMenu__Jobs__departments__attributebutton"
                      icon="check"
                      width="32px"
                      height="32px"
                      color={show_bad_skills ? 'paperplease' : 'null'}
                      onClick={() => act('enable_bad_skills')}
                      circular
                    />
                  </Tooltip>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Box>
      </Stack.Item>

      {/* Skills Column */}
      <Stack.Item width="60%" height="85.5%">
        <Box width="100%" className="PreferencesMenu__papersplease__header__left">
          <Box
            textAlign="center"
            className="PreferencesMenu__papersplease__header__title"
            style={{ fontSize: '275%' }}>
            Skills
          </Box>
        </Box>
        <Box
          width="100%"
          height="100%"
          className="PreferencesMenu__papersplease__left"
          style={{ paddingLeft: '4px', paddingRight: '0px', fontSize: '150%' }}>
          <Stack width="100%" height="100%" overflowX="hidden" overflowY="scroll" vertical>
            {!skills_by_category.length && <Box>No skills!</Box>}
            {skills_by_category.map((category) => (
              <Stack vertical key={category.name}>
                <Stack.Item>
                  <Box
                    mt={2}
                    style={{
                      fontSize: '140%',
                      fontWeight: 'bold',
                      borderTop: '4px dotted rgba(90, 76, 76, 0.7)',
                      borderBottom: '4px dotted rgba(90, 76, 76, 0.7)',
                    }}>
                    {category.name}
                  </Box>
                </Stack.Item>
                {category.skills.map((skill) => (
                  <Stack.Item
                    ml={1}
                    mb={2}
                    width="100%"
                    key={skill.name}
                    onClick={() => act('inspect_closely', { attribute_name: skill.name })}>
                    <Tooltip
                      position="bottom"
                      content={
                        <Box>
                          {skill.desc}
                          {skill.difficulty && <Box mt={0.5}>[{skill.difficulty}]</Box>}
                        </Box>
                      }>
                      <Stack>
                        <Stack.Item width="85%" vertical={false}>
                          <Box width="100%">
                            <Box mr={1} className={`attributes_small16x16 ${skill.icon}`} />
                            {skill.name}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box textAlign="right" mr={2}>
                            ({' '}
                            {skill.value !== null && skill.raw_value !== null ? (
                              <span
                                style={{
                                  color:
                                    skill.value < skill.raw_value
                                      ? '#800000'
                                      : skill.value > skill.raw_value
                                      ? '#008000'
                                      : '',
                                }}>
                                {skill.value}
                              </span>
                            ) : (
                              <span>
                                {typeof skill.value === 'number' && (
                                  <span style={{ color: '#008000' }}>{skill.value}</span>
                                )}
                                {typeof skill.raw_value === 'number' && (
                                  <span style={{ color: '#800000' }}>{skill.value}</span>
                                )}
                              </span>
                            )}
                            /{skill.raw_value})
                          </Box>
                        </Stack.Item>
                      </Stack>
                    </Tooltip>
                  </Stack.Item>
                ))}
              </Stack>
            ))}
          </Stack>
        </Box>
      </Stack.Item>
    </Stack>
  );
};

export const AttributeMenu = (props, context) => {
  const { act, data } = useBackend<AttributeData>(context);
  const { parent, closely_inspected_attribute } = data;

  return (
    <Window
      title={parent ? `${parent} Attributes` : 'Attributes'}
      width={800}
      height={400}>
      <Window.Content>
        {closely_inspected_attribute?.name ? (
          <CloserInspection data={data} act={act} />
        ) : (
          <AttributeStack data={data} act={act} />
        )}
      </Window.Content>
    </Window>
  );
};
