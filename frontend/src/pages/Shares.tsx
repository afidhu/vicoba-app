import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { membersApi } from '../api/endpoints';
import { GroupMember } from '../types';
import { formatCurrency } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

interface ShareSummary {
  sharePrice: number;
  totalShares: number;
  totalShareCapital: number;
  breakdown: { memberId: string; name: string; shareHoldings: number; shareValue: number }[];
}

export default function Shares() {
  const { activeGroup } = useGroup();
  const [summary, setSummary] = useState<ShareSummary | null>(null);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [purchase, setPurchase] = useState({ memberId: '', quantity: '1' });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    Promise.all([
      membersApi.sharesSummary(activeGroup.id),
      membersApi.list(activeGroup.id),
    ])
      .then(([s, m]) => {
        setSummary(s.data as ShareSummary);
        setMembers(m.data.filter((mm) => mm.isActive));
      })
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  async function handlePurchase(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await membersApi.purchaseShares(
        activeGroup.id,
        purchase.memberId,
        Number(purchase.quantity),
      );
      setPurchase({ memberId: '', quantity: '1' });
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  if (loading || !summary) {
    return <div className="spinner-border text-success" role="status" />;
  }

  return (
    <div>
      <h4 className="fw-bold mb-3">Shares</h4>

      <div className="row g-3 mb-4">
        <div className="col-md-4">
          <div className="card border-0 shadow-sm">
            <div className="card-body">
              <div className="text-muted small">Share price</div>
              <div className="fs-5 fw-bold">{formatCurrency(summary.sharePrice)}</div>
            </div>
          </div>
        </div>
        <div className="col-md-4">
          <div className="card border-0 shadow-sm">
            <div className="card-body">
              <div className="text-muted small">Total shares</div>
              <div className="fs-5 fw-bold">{summary.totalShares}</div>
            </div>
          </div>
        </div>
        <div className="col-md-4">
          <div className="card border-0 shadow-sm">
            <div className="card-body">
              <div className="text-muted small">Total share capital</div>
              <div className="fs-5 fw-bold">{formatCurrency(summary.totalShareCapital)}</div>
            </div>
          </div>
        </div>
      </div>

      <RoleGuard roles={['ADMIN', 'TREASURER']}>
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            <h6 className="fw-semibold mb-3">Record a share purchase</h6>
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handlePurchase}>
              <div className="col-md-5">
                <select
                  className="form-select"
                  required
                  value={purchase.memberId}
                  onChange={(e) => setPurchase({ ...purchase, memberId: e.target.value })}
                >
                  <option value="">Select member</option>
                  {members.map((m) => (
                    <option key={m.id} value={m.id}>
                      {m.name}
                    </option>
                  ))}
                </select>
              </div>
              <div className="col-md-3">
                <input
                  type="number"
                  min={1}
                  className="form-control"
                  value={purchase.quantity}
                  onChange={(e) => setPurchase({ ...purchase, quantity: e.target.value })}
                />
              </div>
              <div className="col-md-2">
                <button type="submit" className="btn btn-success w-100">
                  Purchase
                </button>
              </div>
            </form>
          </div>
        </div>
      </RoleGuard>

      <div className="card border-0 shadow-sm">
        <div className="table-responsive">
          <table className="table mb-0 align-middle">
            <thead>
              <tr>
                <th>Member</th>
                <th>Shares held</th>
                <th className="text-end">Value</th>
              </tr>
            </thead>
            <tbody>
              {summary.breakdown.map((b) => (
                <tr key={b.memberId}>
                  <td className="fw-semibold">{b.name}</td>
                  <td>{b.shareHoldings}</td>
                  <td className="text-end">{formatCurrency(b.shareValue)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
