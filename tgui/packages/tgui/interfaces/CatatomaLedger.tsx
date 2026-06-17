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

type Data = {
  faction_name: string;
  categories: string[];
  supply_packs: SupplyPack[];
  cart: CartItem[];
  total_mammon_cost: number;
};

// Converts flat history into the required number[][] coordinate pairs [[x, y], [x, y]]
const getValidChartData = (history: SupplyPack['history']): number[][] => {
  if (!history || typeof history !== 'object') return [];

  const rawValues = Array.isArray(history)
    ? history
    : Object.values(history);

  const cleanNumbers = rawValues
    .map(Number)
    .filter((val) => !isNaN(val) && isFinite(val));

  // The component needs at least 2 coordinate points to map a line segment
  if (cleanNumbers.length < 2) return [];

  // Map flat values into [x, y] coordinates: [[0, val1], [1, val2], ...]
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
    cart = [],
    total_mammon_cost = 0,
  } = data;

  const [currentCategory, setCurrentCategory] = useState('All');
  const [showInStock, setShowInStock] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');

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
              <Table.Cell>Active Trading Entity:</Table.Cell>
              <Table.Cell>{faction_name || "Unknown Entity"}</Table.Cell>
            </Table.Row>
          </Table>
        </Section>

        {/* CATEGORY BAR */}
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
              <Table.Cell>Availability</Table.Cell>
              <Table.Cell>Purchase Options</Table.Cell>
            </Table.Row>
            {filteredPacks.length === 0 ? (
              <Table.Row>
                <Table.Cell colSpan={4}>No matching provisions found.</Table.Cell>
              </Table.Row>
            ) : (
              filteredPacks.map((pack) => {
                // Now returns valid number[][] matrix format
                const chartCoordinates = getValidChartData(pack.history);

                // Extract structural Y values to accurately map explicit range boundaries
                const yValues = chartCoordinates.map(coord => coord[1]);
                const minY = yValues.length > 0 ? Math.min(...yValues) : 0;
                const maxY = yValues.length > 0 ? Math.max(...yValues) : 100;

                // Prevent flatlines from triggering zero-span delta errors
                const paddedRangeY: [number, number] = minY === maxY
                  ? [minY - 5, maxY + 5]
                  : [minY, maxY];

                return (
                  <Table.Row key={pack.id} className="candystripe">
                    <Table.Cell verticalAlign="middle">
                      <Box bold>{pack.name}</Box>
                      <Box color="label" fontSize="0.9em">{pack.desc}</Box>
                    </Table.Cell>

                    {/* TRENDLINE CHART CELL */}
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

                    <Table.Cell verticalAlign="middle">
                      {pack.in_stock ? "AVAILABLE" : "BACKORDER ONLY"}
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

              {/* CART SUMMARY FOOTER */}
              <Table.Row>
                <Table.Cell colSpan={4}>
                  <Table>
                    <Table.Row>
                      <Table.Cell>Total Mammons:</Table.Cell>
                      <Table.Cell color="amber">{total_mammon_cost} M</Table.Cell>
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
