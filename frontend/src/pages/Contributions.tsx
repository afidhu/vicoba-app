import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { contributionsApi, membersApi } from '../api/endpoints';
import { Contribution, GroupMember } from '../types';
import { formatCurrency, formatDate, toDateInputValue } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

export default function Contributions() {
  const { activeGroup } = useGroup();
  const [contributions, setContributions] = useState<Contribution[]>([]);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({
    memberId: '',
    amount: '',
    weekEnding: toDateInputValue(),
  });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    Promise.all([
      contributionsApi.list(activeGroup.id),
      membersApi.list(activeGroup.id),
    ])
      .then(([c, m]) => {
        setContributions(c.data);
        setMembers(m.data.filter((mm) => mm.isActive));
      })
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await contributionsApi.create(activeGroup.id, {
        memberId: form.memberId,
        amount: form.amount ? Number(form.amount) : undefined,
        weekEnding: form.weekEnding,
      });
      setForm({ memberId: '', amount: '', weekEnding: toDateInputValue() });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Weekly Contributions</h4>
        <RoleGuard roles={['ADMIN', 'TREASURER']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Record contribution
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-4">
                <label className="form-label">Member</label>
                <select
                  className="form-select"
                  required
                  value={form.memberId}
                  onChange={(e) => setForm({ ...form, memberId: e.target.value })}
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
                <label className="form-label">
                  Amount{' '}
                  <small className="text-muted">
                    (defaults to {formatCurrency(activeGroup?.weeklyContribution)})
                  </small>
                </label>
                <input
                  type="number"
                  className="form-control"
                  min={0}
                  value={form.amount}
                  onChange={(e) => setForm({ ...form, amount: e.target.value })}
                  placeholder="Optional"
                />
              </div>
              <div className="col-md-3">
                <label className="form-label">Week ending</label>
                <input
                  type="date"
                  className="form-control"
                  required
                  value={form.weekEnding}
                  onChange={(e) => setForm({ ...form, weekEnding: e.target.value })}
                />
              </div>
              <div className="col-md-2 d-flex align-items-end">
                <button type="submit" className="btn btn-success w-100">
                  Save
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="card border-0 shadow-sm">
        <div className="table-responsive">
          <table className="table mb-0 align-middle">
            <thead>
              <tr>
                <th>Member</th>
                <th>Week ending</th>
                <th className="text-end">Amount</th>
                <th>Recorded on</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={4} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && contributions.length === 0 && (
                <tr>
                  <td colSpan={4} className="text-center text-muted py-3">
                    No contributions recorded yet
                  </td>
                </tr>
              )}
              {contributions.map((c) => (
                <tr key={c.id}>
                  <td className="fw-semibold">{c.member?.name}</td>
                  <td>{formatDate(c.weekEnding)}</td>
                  <td className="text-end text-success fw-semibold">
                    {formatCurrency(c.amount)}
                  </td>
                  <td>{formatDate(c.createdAt)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
