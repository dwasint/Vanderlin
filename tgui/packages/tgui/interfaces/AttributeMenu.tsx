import { useBackend, useLocalState } from '../backend';
import { Box, Button, Input, Stack, Tooltip } from 'tgui-core/components';
import { Window } from '../layouts';

// --- Interfaces ---

interface AttributeModifier {
  id: string;
  value: number;
}

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
  modifiers?: AttributeModifier[];
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
  const hasModifiers = !!attribute.modifiers?.length;

  let mainHeight = '85%';
  if (hasDefaults && hasModifiers) mainHeight = '42%';
  else if (hasDefaults || hasModifiers) mainHeight = '52.5%';

  const secondaryHeight = hasDefaults && hasModifiers ? '24%' : '32.5%';

  return (
    <Stack width="100%" height="100%" vertical>
      <Stack.Item mb={0} height={mainHeight}>
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
            hasDefaults || hasModifiers
              ? 'PreferencesMenu__papersplease__leftbottomless'
              : 'PreferencesMenu__papersplease__left'
          }
          style={{ paddingTop: '8px', paddingBottom: '8px' }}>
          <Stack>
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
          <Stack.Item mt={0} height={secondaryHeight}>
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
              className={hasModifiers ? 'PreferencesMenu__papersplease__leftbottomless' : 'PreferencesMenu__papersplease__left'}
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
                      <Stack.Item>
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

      {hasModifiers && (
        <>
          <Stack.Item mt={0} mb={0}>
            <Box height={1} className="PreferencesMenu__papersplease__gutterhorizontal" />
          </Stack.Item>
          <Stack.Item mt={0} height={secondaryHeight}>
            <Box
              width="100%"
              className="PreferencesMenu__papersplease__header__leftnoradius">
              <Box
                textAlign="center"
                className="PreferencesMenu__papersplease__header__title"
                style={{ fontSize: '175%' }}>
                Active Modifiers
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
              {attribute.modifiers?.map((mod) => (
                <Stack.Item ml={1} mb={2} key={mod.id} style={{ fontSize: '165%' }}>
                  <Stack>
                    <Stack.Item grow>{mod.id}</Stack.Item>
                    <Stack.Item mr={2}>
                      <Box
                        textAlign="right"
                        style={{ color: mod.value >= 0 ? '#008000' : '#800000' }}>
                        {mod.value >= 0 ? `+${mod.value}` : mod.value}
                      </Box>
                    </Stack.Item>
                  </Stack>
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
  const [search, setSearch] = useLocalState('skill_search', '');

  const isSearching = search.trim().length > 0;

  const handleSearch = (val: string) => {
    const wasSearching = search.trim().length > 0;
    const nowSearching = val.trim().length > 0;
    setSearch(val);
    if (nowSearching && !wasSearching && !show_bad_skills) {
      act('enable_bad_skills');
    } else if (!nowSearching && wasSearching && !show_bad_skills) {
      act('disable_bad_skills');
    }
  };

  const visibleCategories = skills_by_category
    .map((category) => ({
      ...category,
      skills: category.skills.filter((skill) =>
        !isSearching || skill.name.toLowerCase().includes(search.toLowerCase())
      ),
    }))
    .filter((category) => category.skills.length > 0);

  return (
    <Stack width="100%" height="100%">
      <Stack.Item width="40%" height="100%">
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
          overflowY="scroll"
          className="PreferencesMenu__papersplease__left"
          style={{
            paddingLeft: '4px',
            paddingRight: '4px',
            paddingTop: '8px',
            paddingBottom: '8px',
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
                    <Stack.Item width="85%">
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
                        (<span
                          style={{
                            color:
                              (stat.value ?? 0) < (stat.raw_value ?? 0)
                                ? '#800000'
                                : (stat.value ?? 0) > (stat.raw_value ?? 0)
                                ? '#008000'
                                : '',
                          }}>
                          {stat.value}
                        </span>/{stat.raw_value})
                      </Box>
                    </Stack.Item>
                  </Stack>
                </Tooltip>
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      </Stack.Item>

      {/* Skills Column */}
      <Stack.Item width="60%" height="100%">
        <Box width="100%" className="PreferencesMenu__papersplease__header__left">
          <Stack align="center" width="100%" className="PreferencesMenu__papersplease__header__title">
            <Stack.Item grow textAlign="center" style={{ fontSize: '275%' }}>
              Skills
            </Stack.Item>
            <Stack.Item mr={1}>
              <Tooltip
                content={show_bad_skills ? 'Hide untrained skills' : 'Show untrained skills'}
                position="bottom">
                <Button.Checkbox
                  checked={show_bad_skills || isSearching}
                  onClick={() => act(show_bad_skills ? 'disable_bad_skills' : 'enable_bad_skills')}
                  style={{ fontSize: '120%' }}>
                  All skills
                </Button.Checkbox>
              </Tooltip>
            </Stack.Item>
          </Stack>
          <Box px={1} pb={1}>
            <Input
              fluid
              placeholder="Search skills..."
              value={search}
              onInput={(e) => handleSearch(e.target.value)}
            />
          </Box>
        </Box>
        <Box
          width="100%"
          height="85.5%"
          className="PreferencesMenu__papersplease__left"
          style={{ paddingLeft: '4px', paddingRight: '4px', paddingBottom: '4px', fontSize: '150%' }}>
          <Stack width="100%" height="100%" overflowX="hidden" overflowY="scroll" vertical>
            {!visibleCategories.length && <Box>No skills!</Box>}
            {visibleCategories.map((category) => (
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
                        <Stack.Item width="85%">
                          <Box width="100%">
                            <Box mr={1} className={`attributes_small16x16 ${skill.icon}`} />
                            {skill.name}
                          </Box>
                        </Stack.Item>
                        <Stack.Item>
                          <Box textAlign="right" mr={2}>
                            {skill.value !== null && skill.raw_value !== null ? (
                              <>(<span
                                style={{
                                  color:
                                    skill.value < skill.raw_value
                                      ? '#800000'
                                      : skill.value > skill.raw_value
                                      ? '#008000'
                                      : '',
                                }}>
                                {skill.value}
                              </span>/{skill.raw_value})</>
                            ) : (
                              <>
                                {typeof skill.value === 'number' && (
                                  <>(<span style={{ color: '#008000' }}>{skill.value}</span>/{skill.raw_value})</>
                                )}
                                {typeof skill.raw_value === 'number' && !skill.value && (
                                  <>(<span style={{ color: '#800000' }}>{skill.value}</span>/{skill.raw_value})</>
                                )}
                              </>
                            )}
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
      height={450}>
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
