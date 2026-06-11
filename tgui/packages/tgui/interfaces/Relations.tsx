import { Box, Button, Section, Stack, Tabs } from 'tgui-core/components';
import { useBackend, useLocalState } from '../backend';
import { Window } from '../layouts';

type RelationEntry = {
  name: string;
  rel_type: string;
  snapshot: SnapshotData | null;
  desc: string;
  grudges: GrudgeEntry[];
  is_asymmetric: boolean;
};

type SnapshotData = {
  name: string;
  vcolor: string | null;
  job: string;
  gender: string;
  age: number | string;
};

type GrudgeEntry = {
  label: string;
  text: string; // already resolved to our side by the backend
};

type Data = {
  relations: RelationEntry[];
  rival_count: number;    // current number of rival relations
  rival_pref: number;     // player's preferred max rivals (0–3)
};

export const Relations = () => {
  const { data } = useBackend<Data>();
  const { relations = [], rival_count, rival_pref } = data;

  const [tab, setTab] = useLocalState<string>('rel_tab', 'All');

  const tabs = ['All', 'Rivals', 'Other'];
  const visible = relations.filter((r) => {
    if (tab === 'Rivals') return r.rel_type === 'Rival'; //shitcode but like idk man maybe a category var?
    if (tab === 'Other') return r.rel_type !== 'Rival';
    return true;
  });

  return (
    <Window width={360} height={520} title="Relations">
      <Window.Content scrollable>
        <Tabs>
          {tabs.map((t) => (
            <Tabs.Tab
              key={t}
              selected={tab === t}
              onClick={() => setTab(t)}
            >
              {t}
            </Tabs.Tab>
          ))}
        </Tabs>
        <Box mb={1} color="label">
          Rivals: {rival_count} / {rival_pref} preferred
        </Box>
        <Stack vertical>
          {visible.length === 0 && (
            <Stack.Item>
              <Box color="gray" italic>
                No relations in this category.
              </Box>
            </Stack.Item>
          )}
          {visible.map((rel, i) => (
            <Stack.Item key={i}>
              <RelationCard rel={rel} />
            </Stack.Item>
          ))}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const RelationCard = ({ rel }: { rel: RelationEntry }) => {
  const { name, snapshot, desc, grudges, rel_type } = rel;
  const [open, setOpen] = useLocalState<boolean>(`grudge_open_${name}`, false);

  const displayName = snapshot?.name ?? name;
  const vcolor = snapshot?.vcolor;
  const job = snapshot?.job ?? 'Unknown';
  const gender = snapshot?.gender
    ? snapshot.gender.charAt(0).toUpperCase() + snapshot.gender.slice(1)
    : 'Unknown';
  const age = snapshot?.age ?? '?';

  return (
    <Section
      title={
        <Box inline>
          {displayName}
        </Box>
      }
      buttons={
        grudges.length > 0 && (
          <Button
            icon={open ? 'chevron-up' : 'chevron-down'}
            tooltip={open ? 'Hide history' : 'Show history'}
            onClick={() => setOpen(!open)}
          />
        )
      }
    >
      <Stack vertical>
        <Stack.Item>
          <Box color="gray" italic>
            {desc}
          </Box>
        </Stack.Item>
        <Stack.Item>
          <Box>
            {job} &mdash; {gender}, {age}
          </Box>
        </Stack.Item>
        {open && grudges.length > 0 && (
          <Stack.Item>
            <Section title="History">
              <Stack vertical>
                {grudges.map((g, i) => (
                  <Stack.Item key={i}>
                    <Box color="average">
                      <b>{g.label}:</b> {g.text}
                    </Box>
                  </Stack.Item>
                ))}
              </Stack>
            </Section>
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
