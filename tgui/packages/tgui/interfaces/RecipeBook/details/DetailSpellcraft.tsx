import { Box } from 'tgui-core/components';
import { SectionHead } from '../Primitives';
import type { Recipe, FormTechniqueContribution } from '../types';

type Props = { r: Recipe };

const fmtMult = (v?: number) => (v !== undefined ? `×${Math.round(v * 100)}%` : '—');
const fmtMagnitude = (v?: number) => (v !== undefined ? `${v > 0 ? '+' : ''}${v}` : '—');
const fmtPoints = (v?: number) => (v !== undefined ? `+${v}` : '—');

const ContributionTable = ({ rows }: { rows: FormTechniqueContribution[] }) => (
  <table className="RecipeBook__table" style={{ width: '100%', borderCollapse: 'collapse', fontSize: '12px' }}>
    <thead>
      <tr>
        <th style={{ textAlign: 'left', padding: '4px 6px' }}>Name</th>
        <th style={{ textAlign: 'right', padding: '4px 6px' }}>Points</th>
        <th style={{ textAlign: 'right', padding: '4px 6px' }}>Cost</th>
        <th style={{ textAlign: 'right', padding: '4px 6px' }}>Cast Speed</th>
        <th style={{ textAlign: 'right', padding: '4px 6px' }}>Magnitude</th>
      </tr>
    </thead>
    <tbody>
      {rows.map((c, i) => (
        <tr key={i} style={{ borderTop: '1px solid rgba(0,0,0,0.15)' }}>
          <td style={{ padding: '4px 6px', fontWeight: 'bold', color: c.color || 'inherit' }}>{c.name}</td>
          <td style={{ padding: '4px 6px', textAlign: 'right' }}>{fmtPoints(c.points)}</td>
          <td style={{ padding: '4px 6px', textAlign: 'right' }}>{fmtMult(c.cost_mult)}</td>
          <td style={{ padding: '4px 6px', textAlign: 'right' }}>{fmtMult(c.speed_mult)}</td>
          <td style={{ padding: '4px 6px', textAlign: 'right' }}>{fmtMagnitude(c.magnitude_mod)}</td>
        </tr>
      ))}
    </tbody>
  </table>
);

export const DetailSpellcraft = ({ r }: Props) => (
  <>
    {!!r.forms?.length && (
      <>
        <SectionHead>Forms</SectionHead>
        <ContributionTable rows={r.forms!} />
      </>
    )}
    {!!r.techniques?.length && (
      <>
        <SectionHead>Techniques</SectionHead>
        <ContributionTable rows={r.techniques!} />
      </>
    )}
    {!r.forms?.length && !r.techniques?.length && (
      <Box className="RecipeBook__desc">No spellcraft contributions.</Box>
    )}
  </>
);
