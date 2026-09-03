import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { finesApi, membersApi } from '../api/endpoints';
import { Fine, FineStatus, GroupMember } from '../types';
import { formatCurrency, formatDate } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

const STATUS_VARIANT: Record<FineStatus, string> = {
  UNPAID: 'danger',
  PAID: 'success',
  WAIVED: 'secondary',
};

export default function Fines() {
  const { activeGroup } = useGroup();
  const [fines, setFines] = useState<Fine[]>([]);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ memberId: '', reason: '', amount: '' });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    Promise.all([finesApi.list(activeGroup.id), membersApi.list(activeGroup.id)])
      .then(([f, m]) => {
        setFines(f.data);
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
      await finesApi.create(activeGroup.id, {
        memberId: form.memberId,
        reason: form.reason,
        amount: form.amount ? Number(form.amount) : undefined,
      });
      setForm({ memberId: '', reason: '', amount: '' });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function updateStatus(fine: Fine, status: FineStatus) {
    if (!activeGroup) return;
    await finesApi.updateStatus(activeGroup.id, fine.id, status);
    load();
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Fines</h4>
        <RoleGuard roles={['ADMIN', 'TREASURER', 'SECRETARY']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Record fine
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-3">
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
              <div className="col-md-5">
                <label className="form-label">Reason</label>
                <input
                  className="form-control"
                  required
                  placeholder="e.g. Missed contribution"
                  value={form.reason}
                  onChange={(e) => setForm({ ...form, reason: e.target.value })}
                />
              </div>
              <div className="col-md-2">
                <label className="form-label">
                  Amount{' '}
                  <small className="text-muted">
                    (default {formatCurrency(activeGroup?.fineDefaultAmount)})
                  </small>
                </label>
                <input
                  type="number"
                  min={0}
                  className="form-control"
                  value={form.amount}
                  onChange={(e) => setForm({ ...form, amount: e.target.value })}
                  placeholder="Optional"
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
                <th>Reason</th>
                <th className="text-end">Amount</th>
                <th>Status</th>
                <th>Date</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={6} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && fines.length === 0 && (
                <tr>
                  <td colSpan={6} className="text-center text-muted py-3">
                    No fines recorded
                  </td>
                </tr>
              )}
              {fines.map((f) => (
                <tr key={f.id}>
                  <td className="fw-semibold">{f.member?.name}</td>
                  <td>{f.reason}</td>
                  <td className="text-end">{formatCurrency(f.amount)}</td>
                  <td>
                    <span className={`badge bg-${STATUS_VARIANT[f.status]}`}>{f.status}</span>
                  </td>
                  <td>{formatDate(f.createdAt)}</td>
                  <td>
                    <RoleGuard roles={['ADMIN', 'TREASURER']}>
                      {f.status === 'UNPAID' && (
                        <div className="btn-group btn-group-sm">
                          <button
                            className="btn btn-outline-success"
                            onClick={() => updateStatus(f, 'PAID')}
                          >
                            Mark paid
                          </button>
                          <button
                            className="btn btn-outline-secondary"
                            onClick={() => updateStatus(f, 'WAIVED')}
                          >
                            Waive
                          </button>
                        </div>
                      )}
                    </RoleGuard>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
