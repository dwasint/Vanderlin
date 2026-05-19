import { useEffect, useMemo, useRef, useState } from 'react';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  DmIcon,
  Icon,
  Input,
  NoticeBox,
  Section,
  Stack,
  Tabs,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { Window } from '../layouts';

type LoadoutEntry = {
  path: string;
  name: string;
  description: string | null;
  cost_single: number;
  cost_permanent: number;
  free: BooleanLike;
  owned: BooleanLike;
  equipped: BooleanLike;
  rented: BooleanLike;
  can_afford_single: BooleanLike;
  can_afford_perm: BooleanLike;
  award_locked: BooleanLike;
  ui_icon: string | null;
  ui_icon_state: string | null;
  category: string;
  no_rent: BooleanLike;
  no_equip: BooleanLike;
  patreon_locked: BooleanLike;
};

type EquippedSlot = {
  path: string | null;
  name: string;
  permanent: BooleanLike;
};

type SpecialEntry = {
  path: string;
  name: string;
  greet_text: string;
  req_text: string | null;
  weight: number;
  total_weight: number;
  eligible: BooleanLike;
  cost_random: number;
  cost_specific: number;
  is_pending: BooleanLike;
};

type Data = {
  triumph_balance: number;
  cost_random_special: number;
  pending_special: string | null;
  categories: Record<string, LoadoutEntry[]>;
  equipped_slots: [EquippedSlot, EquippedSlot, EquippedSlot];
  specials: SpecialEntry[];
};

function flattenCategories(categories: Record<string, LoadoutEntry[]>): LoadoutEntry[] {
  return Object.values(categories).flatMap((v) =>
    Array.isArray(v) ? v : [v as unknown as LoadoutEntry],
  );
}

type RarityTier = 'common' | 'uncommon' | 'rare' | 'epic';

function getRarity(weight: number, allWeights: number[]): RarityTier {
  if (!allWeights.length || weight <= 0) return 'epic';
  const sorted = [...allWeights].sort((a, b) => b - a);
  const q1 = sorted[Math.floor(sorted.length * 0.25)];
  const q2 = sorted[Math.floor(sorted.length * 0.50)];
  const q3 = sorted[Math.floor(sorted.length * 0.75)];
  if (weight >= q1) return 'common';
  if (weight >= q2) return 'uncommon';
  if (weight >= q3) return 'rare';
  return 'epic';
}

const RARITY_COLOR: Record<RarityTier, string> = {
  common:   '#9e9e9e',
  uncommon: '#4caf50',
  rare:     '#2196f3',
  epic:     '#9c27b0',
};

const RARITY_LABEL: Record<RarityTier, string> = {
  common:   'Common',
  uncommon: 'Uncommon',
  rare:     'Rare',
  epic:     'Epic',
};

const ItemSprite = ({
  icon,
  icon_state,
  size = 2,
}: {
  icon: string | null;
  icon_state: string | null;
  size?: number;
}) => {
  if (!icon || !icon_state) {
    return <Icon name="question" size={1} color="gray" />;
  }
  return (
    <DmIcon
      icon={icon}
      icon_state={icon_state}
      height={size}
      width={size}
      fallback={<Icon name="spinner" size={1} spin color="gray" />}
    />
  );
};

const EquippedPanel = ({
  slots,
  onUnequip,
}: {
  slots: EquippedSlot[];
  onUnequip: (path: string) => void;
}) => (
  <Section title="Loadout Slots" fill>
    <Stack vertical>
      {slots.map((slot, i) => (
        <Stack.Item key={i}>
          <Stack align="center">
            <Stack.Item>
              <Icon
                name={slot.path ? 'check-circle' : 'circle'}
                color={slot.path ? 'good' : 'average'}
              />
            </Stack.Item>
            <Stack.Item grow>
              {slot.path ? slot.name : `Slot ${i + 1} — Empty`}
            </Stack.Item>
            {!!slot.path && (
              <Stack.Item>
                <Button
                  icon="times"
                  color="transparent"
                  tooltip={
                    !!slot.permanent
                      ? 'Unequip (item stays owned)'
                      : 'Cancel rental (refunded)'
                  }
                  onClick={() => onUnequip(slot.path!)}
                />
              </Stack.Item>
            )}
          </Stack>
        </Stack.Item>
      ))}
      <Stack.Item>
        <Box mt={1} color="label" fontSize="0.8em">
          Items spawn with you next round.
        </Box>
      </Stack.Item>
    </Stack>
  </Section>
);

const LoadoutItemRow = ({
  item,
  onBuySingle,
  onBuyPermanent,
  onEquip,
  onUnequip,
  slotsUsed,
}: {
  item: LoadoutEntry;
  onBuySingle: (path: string) => void;
  onBuyPermanent: (path: string) => void;
  onEquip: (path: string) => void;
  onUnequip: (path: string) => void;
  slotsUsed: number;
}) => {
  const slotsFull   = slotsUsed >= 3;
  const owned       = !!item.owned;
  const equipped    = !!item.equipped;
  const rented      = !!item.rented;
  const free        = !!item.free;
  const awardLocked = !!item.award_locked;
  const canSingle   = !!item.can_afford_single;
  const canPerm     = !!item.can_afford_perm;
  const noRent      = !!item.no_rent;
  const noEquip     = !!item.no_equip;
  const patreonLock = !!item.patreon_locked;

  return (
    <Stack align="center" mb={1}>
      <Stack.Item>
        <ItemSprite icon={item.ui_icon} icon_state={item.ui_icon_state} />
      </Stack.Item>
      <Stack.Item grow>
        <Box bold>{item.name}</Box>
        {!!item.description && (
          <Box color="label" fontSize="0.8em">{item.description}</Box>
        )}
      </Stack.Item>
      <Stack.Item>
        {patreonLock && !owned && (
          <Box color="purple" fontSize="0.8em">Patreon exclusive</Box>
        )}
        {awardLocked && (
          <Box color="bad" fontSize="0.8em">Achievement locked</Box>
        )}
        {!awardLocked && !patreonLock && owned && (
          <Box color="good" fontSize="0.8em">{noEquip ? 'Claimed' : 'Owned'}</Box>
        )}
        {!awardLocked && !patreonLock && !owned && rented && (
          <Box color="average" fontSize="0.8em">Rented this round</Box>
        )}
      </Stack.Item>
      <Stack.Item>
        <Stack>
          {owned && !equipped && !noEquip && (
            <Button
              icon="plus"
              disabled={slotsFull}
              tooltip={slotsFull ? 'All slots full' : 'Equip'}
              onClick={() => onEquip(item.path)}
            >
              Equip
            </Button>
          )}
          {equipped && !noEquip && (
            <Button icon="minus" color="bad" tooltip="Unequip" onClick={() => onUnequip(item.path)}>
              Unequip
            </Button>
          )}
          {!owned && !rented && !awardLocked && !patreonLock && !noRent && !noEquip && (
            <Button
              icon="clock"
              disabled={slotsFull || (!free && !canSingle)}
              tooltip={
                slotsFull ? 'All slots full'
                  : free ? 'Free — use for one round'
                    : canSingle ? `Rent for ${item.cost_single} triumphs (one round)`
                      : `Need ${item.cost_single} triumphs`
              }
              onClick={() => onBuySingle(item.path)}
            >
              {free ? 'Use' : `Rent (${item.cost_single})`}
            </Button>
          )}
          {rented && !noEquip && (
            <Button icon="undo" color="average" tooltip="Cancel rental and get a refund" onClick={() => onUnequip(item.path)}>
              Cancel
            </Button>
          )}
          {!owned && !awardLocked && !patreonLock && item.cost_permanent > 0 && (
            <Button
              icon="lock-open"
              color={canPerm ? 'good' : 'bad'}
              disabled={!canPerm}
              tooltip={
                canPerm
                  ? `Permanently unlock for ${item.cost_permanent} triumphs`
                  : `Need ${item.cost_permanent} triumphs to permanently unlock`
              }
              onClick={() => onBuyPermanent(item.path)}
            >
              Unlock ({item.cost_permanent})
            </Button>
          )}
          {!owned && !awardLocked && !patreonLock && item.cost_permanent === 0 && !rented && free && (
            <Button icon="gift" color="good" tooltip="Claim permanently for free" onClick={() => onBuyPermanent(item.path)}>
              Claim
            </Button>
          )}
        </Stack>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutCategoryView = ({
  items,
  onBuySingle,
  onBuyPermanent,
  onEquip,
  onUnequip,
  slotsUsed,
  search,
}: {
  items: LoadoutEntry[];
  onBuySingle: (path: string) => void;
  onBuyPermanent: (path: string) => void;
  onEquip: (path: string) => void;
  onUnequip: (path: string) => void;
  slotsUsed: number;
  search: string;
}) => {
  const filtered = useMemo(() => {
    if (!search) return items;
    const q = search.toLowerCase();
    return items.filter(
      (i) => i.name.toLowerCase().includes(q) || (i.description ?? '').toLowerCase().includes(q),
    );
  }, [items, search]);

  if (!filtered.length) {
    return <NoticeBox>No items found{search ? ` for "${search}"` : ''}.</NoticeBox>;
  }

  return (
    <Box>
      {filtered.map((item) => (
        <LoadoutItemRow
          key={item.path}
          item={item}
          onBuySingle={onBuySingle}
          onBuyPermanent={onBuyPermanent}
          onEquip={onEquip}
          onUnequip={onUnequip}
          slotsUsed={slotsUsed}
        />
      ))}
    </Box>
  );
};

const CollectionView = ({
  categories,
  onEquip,
  onUnequip,
  slotsUsed,
}: {
  categories: Record<string, LoadoutEntry[]>;
  onEquip: (path: string) => void;
  onUnequip: (path: string) => void;
  slotsUsed: number;
}) => {
  const items = useMemo(
    () => flattenCategories(categories).filter((i) => i.owned || i.equipped || i.rented),
    [categories],
  );

  if (!items.length) {
    return <NoticeBox>You have not unlocked any items yet. Browse the shop tabs to spend triumphs!</NoticeBox>;
  }

  return (
    <Box>
      {items.map((item) => (
        <LoadoutItemRow
          key={item.path}
          item={item}
          onBuySingle={() => {}}
          onBuyPermanent={() => {}}
          onEquip={onEquip}
          onUnequip={onUnequip}
          slotsUsed={slotsUsed}
        />
      ))}
    </Box>
  );
};

const REEL_VISIBLE   = 5;
const REEL_CARD_H    = 52;
const REEL_LAND_MS   = 2000;
const REEL_LINGER_MS = 2500;

function buildPool(specials: SpecialEntry[]): string[] {
  if (!specials.length) return [];
  const totalWeight = specials.reduce((s, x) => s + x.weight, 0);
  const divisor = totalWeight / 20;
  const pool: string[] = [];
  for (const s of specials) {
    const reps = Math.max(1, Math.round(s.weight / divisor));
    for (let i = 0; i < reps; i++) pool.push(s.path);
  }
  for (let i = pool.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [pool[i], pool[j]] = [pool[j], pool[i]];
  }
  while (pool.length < 50) {
    pool.push(...pool.slice(0, Math.min(pool.length, 50 - pool.length)));
  }
  return pool;
}

function safeMod(n: number, m: number): number {
  if (m <= 0) return 0;
  return ((n % m) + m) % m;
}

const TraitReel = ({
  specials,
  landOnPath,
  onDone,
}: {
  specials: SpecialEntry[];
  landOnPath: string | null;
  onDone: () => void;
}) => {
  const allWeights = useMemo(() => specials.map((s) => s.weight), [specials]);
  const nameMap    = useMemo(() => Object.fromEntries(specials.map((s) => [s.path, s.name])), [specials]);
  const weightMap  = useMemo(() => Object.fromEntries(specials.map((s) => [s.path, s.weight])), [specials]);

  const [strip, setStrip]     = useState<string[]>(() => buildPool(specials));
  const [offsetY, setOffsetY] = useState(0);

  const rafRef         = useRef<number | null>(null);
  const phaseRef       = useRef<'spin' | 'land' | 'linger'>('spin');
  const spinOffsetRef  = useRef(0);
  const landStartRef   = useRef<number | null>(null);
  const landFromRef    = useRef(0);
  const landTargetRef  = useRef(0);
  const lingerStartRef = useRef<number | null>(null);
  const doneRef        = useRef(false);
  const centreIndex    = Math.floor(REEL_VISIBLE / 2);

  const spinLoopRef = useRef<(ts: number) => void>(() => {});
  spinLoopRef.current = (_ts: number) => {
    if (phaseRef.current !== 'spin') return;
    spinOffsetRef.current += REEL_CARD_H * 0.35;
    const maxOffset = strip.length * REEL_CARD_H;
    if (maxOffset > 0 && spinOffsetRef.current >= maxOffset) spinOffsetRef.current -= maxOffset;
    setOffsetY(Math.round(spinOffsetRef.current));
    rafRef.current = requestAnimationFrame(spinLoopRef.current);
  };

  useEffect(() => {
    phaseRef.current = 'spin';
    rafRef.current = requestAnimationFrame(spinLoopRef.current);
    return () => { if (rafRef.current !== null) cancelAnimationFrame(rafRef.current); };
  }, []);

  useEffect(() => {
    if (!landOnPath || phaseRef.current !== 'spin') return;
    const newStrip = buildPool(specials);
    newStrip.push(landOnPath);
    setStrip(newStrip);

    const targetIndex  = newStrip.length - 1 - centreIndex;
    const targetOffset = targetIndex * REEL_CARD_H;
    landFromRef.current   = spinOffsetRef.current;
    landTargetRef.current = targetOffset;
    landStartRef.current  = null;
    phaseRef.current      = 'land';
    if (rafRef.current !== null) cancelAnimationFrame(rafRef.current);

    const lingerLoop = (ts: number) => {
      if (!lingerStartRef.current) lingerStartRef.current = ts;
      if (ts - lingerStartRef.current < REEL_LINGER_MS) {
        rafRef.current = requestAnimationFrame(lingerLoop);
      } else if (!doneRef.current) {
        doneRef.current = true;
        onDone();
      }
    };

    const landAnimate = (ts: number) => {
      if (!landStartRef.current) landStartRef.current = ts;
      const elapsed = ts - landStartRef.current;
      const t       = Math.min(elapsed / REEL_LAND_MS, 1);
      const eased   = 1 - Math.pow(1 - t, 3);
      const current = landFromRef.current + (landTargetRef.current - landFromRef.current) * eased;
      setOffsetY(Math.round(current));
      if (t < 1) {
        rafRef.current = requestAnimationFrame(landAnimate);
      } else {
        setOffsetY(landTargetRef.current);
        phaseRef.current       = 'linger';
        lingerStartRef.current = null;
        rafRef.current = requestAnimationFrame(lingerLoop);
      }
    };
    rafRef.current = requestAnimationFrame(landAnimate);
  }, [landOnPath]);

  const startIndex    = strip.length > 0 ? Math.floor(offsetY / REEL_CARD_H) : 0;
  const pixelOffset   = strip.length > 0 ? offsetY % REEL_CARD_H : 0;
  const visibleIndices: number[] = [];
  for (let i = 0; i < REEL_VISIBLE + 1; i++) visibleIndices.push(startIndex + i);

  const centredPath   = strip.length > 0 ? (strip[safeMod(startIndex + centreIndex, strip.length)] ?? '') : '';
  const centredRarity = getRarity(weightMap[centredPath] ?? 0, allWeights);
  const centreColor   = RARITY_COLOR[centredRarity];

  return (
    <Section title={phaseRef.current === 'linger' ? `You got: ${nameMap[centredPath] ?? '???'}` : landOnPath ? 'Landing...' : 'Rolling...'}>
      <Box style={{ height: `${REEL_VISIBLE * REEL_CARD_H}px`, overflow: 'hidden', position: 'relative' }}>
        <Box
          style={{
            position: 'absolute',
            top: `${centreIndex * REEL_CARD_H}px`,
            left: 0, right: 0,
            height: `${REEL_CARD_H}px`,
            background: `${centreColor}18`,
            borderTop: `1px solid ${centreColor}88`,
            borderBottom: `1px solid ${centreColor}88`,
            pointerEvents: 'none',
            zIndex: 1,
          }}
        />
        <Box style={{ position: 'absolute', top: `-${pixelOffset}px`, left: 0, right: 0 }}>
          {visibleIndices.map((idx, i) => {
            const path     = strip.length > 0 ? (strip[safeMod(idx, strip.length)] ?? '') : '';
            const isCentre = i === centreIndex;
            const rarity   = getRarity(weightMap[path] ?? 0, allWeights);
            const color    = RARITY_COLOR[rarity];
            return (
              <Box
                key={i}
                style={{
                  height: `${REEL_CARD_H}px`,
                  display: 'flex',
                  alignItems: 'center',
                  paddingLeft: '12px',
                  fontWeight: isCentre ? 'bold' : 'normal',
                  opacity: isCentre ? 1 : 0.4,
                  fontSize: isCentre ? '1.05em' : '0.9em',
                  color: isCentre ? color : 'inherit',
                  borderLeft: `3px solid ${color}`,
                }}
              >
                <Icon name="dice" mr={1} />
                {nameMap[path] ?? '???'}
              </Box>
            );
          })}
        </Box>
      </Box>
    </Section>
  );
};

const SpecialsTab = ({
  specials,
  pendingSpecial,
  balance,
  costRandom,
  onRollRandom,
  onBuySpecific,
  onClearPending,
}: {
  specials: SpecialEntry[];
  pendingSpecial: string | null;
  balance: number;
  costRandom: number;
  onRollRandom: () => void;
  onBuySpecific: (path: string) => void;
  onClearPending: () => void;
}) => {
  const [showReel, setShowReel]     = useState(false);
  const [landOnPath, setLandOnPath] = useState<string | null>(null);
  const prevPendingRef              = useRef<string | null>(pendingSpecial);

  const allWeights  = useMemo(() => specials.map((s) => s.weight), [specials]);
  const totalWeight = specials[0]?.total_weight ?? 1;

  useEffect(() => {
    if (showReel && pendingSpecial && pendingSpecial !== prevPendingRef.current) {
      setLandOnPath(pendingSpecial);
    }
  }, [pendingSpecial, showReel]);

  const handleRollClick = () => {
    prevPendingRef.current = pendingSpecial;
    setLandOnPath(null);
    setShowReel(true);
    onRollRandom();
  };

  const handleReelDone = () => setShowReel(false);

  const hasPending      = !!pendingSpecial;
  const canAffordRandom = balance >= costRandom;
  const pendingTrait    = pendingSpecial ? specials.find((s) => s.path === pendingSpecial) : null;

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Next Round Special">
          {showReel ? (
            <TraitReel specials={specials} landOnPath={landOnPath} onDone={handleReelDone} />
          ) : hasPending ? (
            <NoticeBox>
              <Stack align="center">
                <Stack.Item grow>
                  <Box bold>
                    <Icon name="dice" mr={1} />
                    {pendingTrait?.name ?? pendingSpecial}
                  </Box>
                  {pendingTrait && (
                    <Box fontSize="0.8em" style={{ color: RARITY_COLOR[getRarity(pendingTrait.weight, allWeights)] }}>
                      {RARITY_LABEL[getRarity(pendingTrait.weight, allWeights)]}
                    </Box>
                  )}
                  {pendingTrait?.req_text && (
                    <Box color="label" fontSize="0.85em" mt={0.5}>Requirements: {pendingTrait.req_text}</Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button icon="times" color="bad" tooltip="Clear pending special (no refund)" onClick={onClearPending}>
                    Clear
                  </Button>
                </Stack.Item>
              </Stack>
            </NoticeBox>
          ) : (
            <Stack align="center">
              <Stack.Item>
                <Button
                  icon="dice"
                  color={canAffordRandom ? 'caution' : 'bad'}
                  disabled={!canAffordRandom || hasPending || showReel}
                  tooltip={!canAffordRandom ? `Need ${costRandom} triumphs` : `Roll a random special for ${costRandom} triumphs`}
                  onClick={handleRollClick}
                >
                  Roll Random ({costRandom})
                </Button>
              </Stack.Item>
              <Stack.Item color="label" fontSize="0.85em">
                or pick a specific trait below, cost varies by rarity
              </Stack.Item>
            </Stack>
          )}
        </Section>
      </Stack.Item>

      <Stack.Item grow>
        <Section title="Available Specials" fill scrollable>
          {specials.map((trait) => {
            const eligible      = !!trait.eligible;
            const rarity        = getRarity(trait.weight, allWeights);
            const color         = RARITY_COLOR[rarity];
            const canAfford     = balance >= trait.cost_specific;
            const expectedRolls = totalWeight > 0
              ? Math.round(totalWeight / Math.max(trait.weight, 1))
              : 999;

            return (
              <Stack key={trait.path} align="center" mb={1}>
                <Stack.Item
                  width="4px"
                  style={{ alignSelf: 'stretch', background: color, borderRadius: '2px', marginRight: '8px' }}
                />
                <Stack.Item grow>
                  <Box bold color={eligible ? 'default' : 'label'}>
                    {trait.name}
                    {!eligible && <Box as="span" color="average" fontSize="0.8em" ml={1}>(ineligible)</Box>}
                  </Box>
                  <Box fontSize="0.75em" style={{ color }}>
                    {RARITY_LABEL[rarity]}  ~1 in {expectedRolls} rolls
                  </Box>
                  {!!trait.req_text && (
                    <Box color="label" fontSize="0.8em">Requires: {trait.req_text}</Box>
                  )}
                </Stack.Item>
                <Stack.Item>
                  <Button
                    icon="hand-pointer"
                    color={canAfford && eligible ? 'default' : 'bad'}
                    disabled={!eligible || !canAfford || hasPending || showReel}
                    tooltip={
                      !eligible ? 'Your character does not meet the requirements'
                        : hasPending ? 'You already have a special queued — clear it first'
                          : !canAfford ? `Need ${trait.cost_specific} triumphs`
                            : `Pick this trait for ${trait.cost_specific} triumphs`
                    }
                    onClick={() => onBuySpecific(trait.path)}
                  >
                    Pick ({trait.cost_specific})
                  </Button>
                </Stack.Item>
              </Stack>
            );
          })}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const TriumphShop = () => {
  const { act, data } = useBackend<Data>();
  const {
    triumph_balance,
    categories,
    equipped_slots,
    specials,
    pending_special,
    cost_random_special,
  } = data;

  const categoryNames = Object.keys(categories);
  const allTabs       = ['Collection', 'Specials', ...categoryNames];

  const [activeTab, setActiveTab] = useLocalState('ts_tab', 'Specials');
  const [search, setSearch]       = useLocalState('ts_search', '');

  const slotsUsed = equipped_slots.filter((s) => s.path !== null).length;

  const handleBuySingle    = (path: string) => act('buy_single', { path });
  const handleBuyPermanent = (path: string) => act('buy_permanent', { path });
  const handleEquip        = (path: string) => act('equip_item', { path });
  const handleUnequip      = (path: string) => act('unequip_item', { path });
  const handleRollRandom   = () => act('buy_random_special');
  const handleBuySpecific  = (path: string) => act('buy_specific_special', { path });
  const handleClearPending = () => act('clear_pending_special');

  const effectiveTab = search.length > 1 ? '__search__' : activeTab;
  const allItems     = useMemo(() => flattenCategories(categories), [categories]);

  return (
    <Window title="Triumph Shop" width={820} height={600}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Box bold>
                    <Icon name="trophy" mr={1} color="average" />
                    Triumph Shop
                  </Box>
                  <Box color="label" fontSize="0.85em">
                    Spend triumphs on loadout items and special traits.
                  </Box>
                </Stack.Item>
                <Stack.Item>
                  <Box bold color="average">
                    <Icon name="trophy" mr={1} />
                    {triumph_balance.toLocaleString()} triumphs
                  </Box>
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item>
            <Section>
              <Stack align="center">
                <Stack.Item grow>
                  <Tabs>
                    {allTabs.map((tab) => (
                      <Tabs.Tab
                        key={tab}
                        selected={effectiveTab === tab}
                        onClick={() => { setActiveTab(tab); setSearch(''); }}
                      >
                        <Icon name={tab === 'Specials' ? 'dice' : tab === 'Collection' ? 'archive' : 'tag'} mr={1} />
                        {tab}
                        {tab === 'Specials' && !!pending_special && (
                          <Icon name="circle" color="good" ml={1} fontSize="0.6em" />
                        )}
                      </Tabs.Tab>
                    ))}
                  </Tabs>
                </Stack.Item>
                {activeTab !== 'Specials' && (
                  <Stack.Item>
                    <Input
                      placeholder="Search..."
                      value={search}
                      onChange={(value: string) => setSearch(value)}
                      width="150px"
                    />
                  </Stack.Item>
                )}
              </Stack>
            </Section>
          </Stack.Item>

          <Stack.Item grow>
            <Stack fill>
              {activeTab !== 'Specials' && (
                <Stack.Item width="210px">
                  <EquippedPanel slots={equipped_slots} onUnequip={handleUnequip} />
                </Stack.Item>
              )}
              <Stack.Item grow>
                {activeTab === 'Specials' && effectiveTab !== '__search__' ? (
                  <SpecialsTab
                    specials={specials}
                    pendingSpecial={pending_special}
                    balance={triumph_balance}
                    costRandom={cost_random_special}
                    onRollRandom={handleRollRandom}
                    onBuySpecific={handleBuySpecific}
                    onClearPending={handleClearPending}
                  />
                ) : (
                  <Section
                    fill
                    scrollable
                    title={effectiveTab === '__search__' ? `Search: "${search}"` : activeTab}
                  >
                    {effectiveTab === '__search__' ? (
                      <LoadoutCategoryView
                        items={allItems}
                        onBuySingle={handleBuySingle}
                        onBuyPermanent={handleBuyPermanent}
                        onEquip={handleEquip}
                        onUnequip={handleUnequip}
                        slotsUsed={slotsUsed}
                        search={search}
                      />
                    ) : activeTab === 'Collection' ? (
                      <CollectionView
                        categories={categories}
                        onEquip={handleEquip}
                        onUnequip={handleUnequip}
                        slotsUsed={slotsUsed}
                      />
                    ) : (
                      <LoadoutCategoryView
                        items={categories[activeTab] ?? []}
                        onBuySingle={handleBuySingle}
                        onBuyPermanent={handleBuyPermanent}
                        onEquip={handleEquip}
                        onUnequip={handleUnequip}
                        slotsUsed={slotsUsed}
                        search=""
                      />
                    )}
                  </Section>
                )}
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
