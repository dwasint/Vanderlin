import { useState } from 'react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  Box,
  Button,
  Chart,
  Input,
  Section,
  Stack,
  Table,
  ProgressBar,
  Tabs,
  NoticeBox,
} from 'tgui-core/components';

type SupplyPack = {
  name: string;
  desc: string;
  group: string;
  id: string;
  cost: number;
  in_stock: boolean;
  history: number[] | Record<string, number>;
};

type CartItem = {
  name: string;
  id: string;
  quantity: number;
  mammon_cost: number;
};

type BountyDiscount = {
  pack_name: string;
  modifier: number;
};

type FactionBounty = {
  id: string;
  name: string;
  desc: string;
  target_item: string;
  required_count: number;
  current_count: number;
  reward_reputation: number;
  reward_currency: number;
  discounts: BountyDiscount[];
};

type Data = {
  faction_name: string;
  categories: string[];
  supply_packs: SupplyPack[];
  active_bounties: FactionBounty[];
  cart: CartItem[];
  total_mammon_cost: number;
  bounty_reroll_ready: boolean;
  bounty_reroll_seconds_left: number;
  faction_reputation: number;
  faction_reputation_tier: number;
  faction_reputation_thresholds: number[];
  faction_color: string;
  rotation_seconds_left: number;
  manual_rotate_ready: boolean;
  manual_rotate_seconds_left: number;
  available_factions: FactionOption[];
};

type FactionOption = {
  name: string;
  ref: string;
  color: string;
  active: boolean;
};

const formatSeconds = (totalSeconds: number): string => {
  const mins = Math.floor(totalSeconds / 60);
  const secs = totalSeconds % 60;
  return `${mins}:${secs.toString().padStart(2, '0')}`;
};

const getValidChartData = (history: SupplyPack['history']): number[][] => {
  if (!history || typeof history !== 'object') return [];

  const rawValues = Array.isArray(history) ? history : Object.values(history);
  const cleanNumbers = rawValues
    .map(Number)
    .filter((val) => !isNaN(val) && isFinite(val));

  if (cleanNumbers.length < 2) return [];
  return cleanNumbers.map((val, index) => [index, val]);
};

export const CatatomaLedger = (props) => {
  const { data, act } = useBackend<Data>();

  if (!data || Object.keys(data).length === 0) {
    return (
      <Window title="Catatoma" width={860} height={620}>
        <Window.Content scrollable align="center">
          <NoticeBox danger>
            Synchronizing Manifest Ledger Data...
          </NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  const {
    faction_name,
    categories = [],
    supply_packs = [],
    active_bounties = [],
    cart = [],
    total_mammon_cost = 0,
    bounty_reroll_ready,
    bounty_reroll_seconds_left,
    faction_reputation = 0,
    faction_reputation_tier = 0,
    faction_reputation_thresholds = [],
    rotation_seconds_left = 0,
    manual_rotate_ready = false,
    manual_rotate_seconds_left = 0,
    available_factions = [],
  } = data;

  const [currentTab, setCurrentTab] = useState<'catalog' | 'bounties'>('catalog');
  const [currentCategory, setCurrentCategory] = useState('All');
  const [showInStock, setShowInStock] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const [expandedBountyId, setExpandedBountyId] = useState<string | null>(null);

  const [showFactionPicker, setShowFactionPicker] = useState(false);

  const nextThreshold = faction_reputation_thresholds[faction_reputation_tier + 1];
  const currThreshold = faction_reputation_thresholds[faction_reputation_tier] ?? 0;
  const tierProgress = nextThreshold
    ? Math.min(1, (faction_reputation - currThreshold) / (nextThreshold - currThreshold))
    : 1;

  const filteredPacks = supply_packs.filter((pack) => {
    if (currentCategory !== 'All' && pack.group !== currentCategory) return false;
    if (showInStock && !pack.in_stock) return false;
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      const nameMatch = pack.name?.toLowerCase().includes(query);
      const descMatch = pack.desc?.toLowerCase().includes(query);
      if (!nameMatch && !descMatch) return false;
    }
    return true;
  });

  return (
    <Window title="Catatoma" width={860} height={620}>
      <Window.Content scrollable>
        {/* FACTION OVERVIEW */}
        <Section title="Faction Clearance">
          <Table>
            <Table.Row>
              <Table.Cell bold width="150px">Active Trading Entity:</Table.Cell>
              <Table.Cell>{faction_name || "Unknown Entity"}</Table.Cell>
              <Table.Cell width="150px" align="right">
                <Button
                  icon="exchange-alt"
                  selected={showFactionPicker}
                  onClick={() => setShowFactionPicker(!showFactionPicker)}
                >
                  Redirect Trade Routes
                </Button>
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>Standing:</Table.Cell>
              <Table.Cell colSpan={2}>
                <Stack align="center">
                  <Stack.Item>Tier {faction_reputation_tier}</Stack.Item>
                  <Stack.Item grow>
                    <ProgressBar
                      value={tierProgress}
                      ranges={{ good: [0.66, 1], average: [0.33, 0.66], bad: [0, 0.33] }}
                    >
                      {faction_reputation}
                      {nextThreshold ? ` / ${nextThreshold}` : ' (Max)'}
                    </ProgressBar>
                  </Stack.Item>
                </Stack>
              </Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell bold>Rotates Out In:</Table.Cell>
              <Table.Cell colSpan={2}>
                {rotation_seconds_left > 0 ? formatSeconds(rotation_seconds_left) : "Pending rotation..."}
              </Table.Cell>
            </Table.Row>
          </Table>

          {showFactionPicker && (
            <Box mt={1}>
              <NoticeBox info={manual_rotate_ready}>
                {manual_rotate_ready
                  ? "Route redirection is ready. Choosing a faction will reset the automatic rotation clock."
                  : `Route redirection on cooldown: ${formatSeconds(manual_rotate_seconds_left)} remaining.`}
              </NoticeBox>
              <Stack wrap mt={0.5}>
                {available_factions.map((f) => (
                  <Stack.Item key={f.ref}>
                    <Button
                      disabled={f.active || !manual_rotate_ready}
                      selected={f.active}
                      color={f.active ? 'good' : undefined}
                      onClick={() => act('manual_rotate_faction', { ref: f.ref })}
                    >
                      {f.name}
                    </Button>
                  </Stack.Item>
                ))}
              </Stack>
            </Box>
          )}
        </Section>

        {/* TOP LEVEL MODULE WORKSPACE TABS */}
        <Tabs>
          <Tabs.Tab
            icon="store"
            selected={currentTab === 'catalog'}
            onClick={() => setCurrentTab('catalog')}
          >
            Provisions Catalog
          </Tabs.Tab>
          <Tabs.Tab
            icon="scroll"
            selected={currentTab === 'bounties'}
            onClick={() => setCurrentTab('bounties')}
          >
            Active Faction Bounties ({active_bounties.length})
          </Tabs.Tab>
        </Tabs>

        {/* WORKSPACE ELEMENT PANELS */}
        {currentTab === 'catalog' && (
          <>
            {/* CATEGORY SUB-BAR */}
            {categories.length > 0 && (
              <Tabs scrollable>
                {categories.map((cat) => (
                  <Tabs.Tab
                    key={cat}
                    selected={currentCategory === cat}
                    onClick={() => setCurrentCategory(cat)}
                  >
                    {cat}
                  </Tabs.Tab>
                ))}
              </Tabs>
            )}

            {/* CATALOG CONTROL BAR */}
            <Section>
              <Stack justify="space-between" align="center">
                <Stack.Item color="label">
                  Showing entries for: <b>{currentCategory}</b>
                </Stack.Item>
                <Stack.Item>
                  <Stack align="center">
                    <Stack.Item>
                      <Input
                        placeholder="Search provisions..."
                        value={searchQuery}
                        onChange={(e: string) => setSearchQuery(e)}
                        width="200px"
                      />
                    </Stack.Item>
                    {searchQuery && (
                      <Stack.Item>
                        <Button
                          icon="times"
                          color="transparent"
                          onClick={() => setSearchQuery('')}
                          tooltip="Clear Search"
                        />
                      </Stack.Item>
                    )}
                    <Stack.Item>
                      <Button
                        icon="boxes"
                        selected={showInStock}
                        onClick={() => setShowInStock(!showInStock)}
                      >
                        In Stock Only
                      </Button>
                    </Stack.Item>
                  </Stack>
                </Stack.Item>
              </Stack>
            </Section>

            {/* MARKET CATALOG DISPLAY */}
            <Section title="Provisions Listing">
              <Table>
                <Table.Row header>
                  <Table.Cell>Item</Table.Cell>
                  <Table.Cell>Market Trend</Table.Cell>
                  <Table.Cell>Purchase Options</Table.Cell>
                </Table.Row>
                {filteredPacks.length === 0 ? (
                  <Table.Row>
                    <Table.Cell colSpan={4}>No matching provisions found.</Table.Cell>
                  </Table.Row>
                ) : (
                  filteredPacks.map((pack) => {
                    const chartCoordinates = getValidChartData(pack.history);
                    const yValues = chartCoordinates.map(coord => coord[1]);
                    const minY = yValues.length > 0 ? Math.min(...yValues) : 0;
                    const maxY = yValues.length > 0 ? Math.max(...yValues) : 100;
                    const paddedRangeY: [number, number] = minY === maxY
                      ? [minY - 5, maxY + 5]
                      : [minY, maxY];

                    return (
                      <Table.Row key={pack.id} className="candystripe">
                        <Table.Cell verticalAlign="middle">
                          <Box bold>{pack.name}</Box>
                          <Box color="label" fontSize="0.9em">{pack.desc}</Box>
                        </Table.Cell>
                        <Table.Cell verticalAlign="middle" width="120px">
                          {chartCoordinates.length > 0 ? (
                            <Chart.Line
                              data={chartCoordinates}
                              height="25px"
                              strokeColor="amber"
                              fillColor="rgba(255, 193, 7, 0.1)"
                              rangeX={[0, chartCoordinates.length - 1]}
                              rangeY={paddedRangeY}
                            />
                          ) : (
                            <Box color="label" italic fontSize="0.9em">Stable</Box>
                          )}
                        </Table.Cell>
                        <Table.Cell>
                          <Button
                            icon="coins"
                            disabled={!pack.in_stock}
                            onClick={() => act('add_to_cart', { id: pack.id })}
                          >
                            Buy ({pack.cost} M)
                          </Button>
                        </Table.Cell>
                      </Table.Row>
                    );
                  })
                )}
              </Table>
            </Section>
          </>
        )}

        {currentTab === 'bounties' && (
          <Section title="Demanded Supply Inquisitions">
            <Table>
              <Table.Row header>
                <Table.Cell width="25px" />
                <Table.Cell>Contract Specifications</Table.Cell>
                <Table.Cell width="120px" align="center">Progress Status</Table.Cell>
                <Table.Cell width="180px">Compensation Rewards</Table.Cell>
              </Table.Row>
              {active_bounties.length === 0 ? (
                <Table.Row>
                  <Table.Cell colSpan={4} italic color="label">
                    No active contract allocations or bounties issued by this faction.
                  </Table.Cell>
                </Table.Row>
              ) : (
                active_bounties.map((bounty) => {
                  const isCompleted = bounty.current_count >= bounty.required_count;
                  const isExpanded = expandedBountyId === bounty.id;

                  return (
                    <>
                      {/* PRIMARY BOUNTY ROW */}
                      <Table.Row key={bounty.id} className="candystripe">
                        <Table.Cell verticalAlign="middle">
                          <Button
                            fluid
                            compact
                            color="transparent"
                            icon={isExpanded ? 'chevron-down' : 'chevron-right'}
                            onClick={() => setExpandedBountyId(isExpanded ? null : bounty.id)}
                          />
                        </Table.Cell>
                        <Table.Cell
                          verticalAlign="middle"
                          onClick={() => setExpandedBountyId(isExpanded ? null : bounty.id)}
                          style={{ cursor: 'pointer' }}
                        >
                          <Box bold color={isCompleted ? "success" : "default"}>
                            {bounty.name}
                          </Box>
                          <Box color="label" fontSize="0.9em">{bounty.desc}</Box>
                        </Table.Cell>
                        <Table.Cell verticalAlign="middle" align="center">
                          <Box bold color={isCompleted ? "success" : "amber"}>
                            {bounty.current_count} / {bounty.required_count}
                          </Box>
                          <Box fontSize="0.8em" color="label">
                            {isCompleted ? "RESOLVED" : "PENDING"}
                        </Box>
                        </Table.Cell>
                        <Table.Cell verticalAlign="middle">
                          <Box color="amber" bold>+{bounty.reward_currency} Mammons</Box>
                          <Box color="teal">+{bounty.reward_reputation} Faction Rep</Box>
                          <Button
                            fluid
                            mt={0.5}
                            icon="dice"
                            color="transparent"
                            disabled={!bounty_reroll_ready}
                            tooltip={
                              bounty_reroll_ready
                                ? 'Discard this bounty and generate a new one'
                                : `On cooldown (${bounty_reroll_seconds_left}s left)`
                            }
                            onClick={() => act('reroll_bounty', { id: bounty.id })}
                          >
                            {bounty_reroll_ready ? 'Reroll' : `${bounty_reroll_seconds_left}s`}
                          </Button>
                        </Table.Cell>
                      </Table.Row>

                      {/* DROPDOWN DETAILS SECTION */}
                      {isExpanded && (
                        <Table.Row key={`${bounty.id}-details`}>
                          <Table.Cell />
                          <Table.Cell colSpan={3}>
                            <Box p={1} style={{ backgroundColor: 'rgba(0, 0, 0, 0.2)', borderRadius: '4px' }}>
                              <Stack vertical >
                                <Stack.Item>
                                  <Box color="label" bold fontSize="0.9em">Material Demanded Specifically:</Box>
                                  <Box pl={1} color="default" italic>
                                    {bounty.target_item} ({bounty.required_count} needed)
                                  </Box>
                                </Stack.Item>

                                <Stack.Item>
                                  <Box color="label" bold fontSize="0.9em">Completion Manifest Incentives:</Box>
                                  {bounty.discounts && bounty.discounts.length > 0 ? (
                                    <Table mt={0.5}>
                                      <Table.Row header>
                                        <Table.Cell fontSize="0.85em">Target Supply Package</Table.Cell>
                                        <Table.Cell fontSize="0.85em" align="right">Wholesale Rebate</Table.Cell>
                                      </Table.Row>
                                      {bounty.discounts.map((discount, idx) => (
                                        <Table.Row key={idx}>
                                          <Table.Cell color="default">{discount.pack_name}</Table.Cell>
                                          <Table.Cell color="success" align="right" bold>{discount.modifier}% Discount</Table.Cell>
                                        </Table.Row>
                                      ))}
                                    </Table>
                                  ) : (
                                    <Box pl={1} color="label" italic fontSize="0.9em">
                                      No additional market provisions or package modifications associated with this contract.
                                    </Box>
                                  )}
                                </Stack.Item>
                              </Stack>
                            </Box>
                          </Table.Cell>
                        </Table.Row>
                      )}
                    </>
                  );
                })
              )}
            </Table>
          </Section>
        )}

        {/* SHOPPING CART OVERVIEW */}
        <Section title="Pending Manifest Invoice">
          {cart.length === 0 ? (
            <Box color="label">Invoice details empty.</Box>
          ) : (
            <Table>
              <Table.Row header>
                <Table.Cell>Item Manifest</Table.Cell>
                <Table.Cell>Qty</Table.Cell>
                <Table.Cell>Cost Value</Table.Cell>
                <Table.Cell />
              </Table.Row>
              {cart.map((item) => (
                <Table.Row key={item.id} className="candystripe">
                  <Table.Cell verticalAlign="middle">
                    <Box>{item.name}</Box>
                  </Table.Cell>
                  <Table.Cell verticalAlign="middle">{item.quantity}</Table.Cell>
                  <Table.Cell verticalAlign="middle">
                    <Box color="amber">{item.mammon_cost} M</Box>
                  </Table.Cell>
                  <Table.Cell verticalAlign="middle">
                    <Button
                      color="danger"
                      icon="minus"
                      compact
                      onClick={() => act('remove_from_cart', { id: item.id })}
                    />
                  </Table.Cell>
                </Table.Row>
              ))}
              <Table.Row>
                <Table.Cell colSpan={4}>
                  <Table>
                    <Table.Row>
                      <Table.Cell bold>Total Mammons:</Table.Cell>
                      <Table.Cell color="amber" bold>{total_mammon_cost} M</Table.Cell>
                    </Table.Row>
                  </Table>
                </Table.Cell>
              </Table.Row>
            </Table>
          )}

          {cart.length > 0 && (
            <Box mt={1}>
              <Stack>
                <Stack.Item grow>
                  <Button
                    fluid
                    color="danger"
                    icon="trash"
                    onClick={() => act('clear_cart')}
                  >
                    Void Invoice
                  </Button>
                </Stack.Item>
                <Stack.Item grow>
                  <Button
                    fluid
                    color="success"
                    icon="scroll"
                    onClick={() => act('submit_order')}
                  >
                    Write Order Scroll
                  </Button>
                </Stack.Item>
              </Stack>
            </Box>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
