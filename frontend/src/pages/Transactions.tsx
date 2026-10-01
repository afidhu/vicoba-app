import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { transactionsApi } from '../api/endpoints';
import { Transaction, TransactionType } from '../types';
import { formatCurrency, formatDate } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

const TYPES: TransactionType[] = [
  'CONTRIBUTION',
  'SHARE_PURCHASE',
  'FINE',
  'LOAN_DISBURSEMENT',
  'LOAN_REPAYMENT',
  'EXPENSE',
  'OTHER',
];

export default function Transactions() {
  const { activeGroup } = useGroup();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [typeFilter, setTypeFilter] = useState('');
  const [showForm, setShowForm] = useState(false);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ direction: 'IN' as 'IN' | 'OUT', amount: '', description: '' });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    transactionsApi
      .list(activeGroup.id, typeFilter ? { type: typeFilter } : undefined)
      .then(({ data }) => setTransactions(data))
      .finally(() => setLoading(false));
  }

  useEffect(() => {
    load();
  }, [activeGroup, typeFilter]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    setSaving(true);
    try {
      await transactionsApi.createOther(activeGroup.id, {
        direction: form.direction,
        amount: Number(form.amount),
        description: form.description,
      });
      setForm({ direction: 'IN', amount: '', description: '' });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Transaction History</h4>
        <div className="d-flex gap-2">
          <RoleGuard roles={['ADMIN', 'TREASURER']}>
            <button className="btn btn-success" onClick={() => setShowForm((value) => !value)}>
              <i className="bi bi-plus-lg me-1" /> Record other transaction
            </button>
          </RoleGuard>
          <select
            className="form-select"
            style={{ width: 220 }}
            value={typeFilter}
            onChange={(e) => setTypeFilter(e.target.value)}
          >
            <option value="">All types</option>
            {TYPES.map((t) => (
              <option key={t} value={t}>
                {t.replace('_', ' ')}
              </option>
            ))}
          </select>
        </div>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-3">
                <label className="form-label">Direction</label>
                <select
                  className="form-select"
                  value={form.direction}
                  onChange={(e) => setForm({ ...form, direction: e.target.value as 'IN' | 'OUT' })}
                >
                  <option value="IN">Income</option>
                  <option value="OUT">Other outgoing transaction</option>
                </select>
              </div>
              <div className="col-md-3">
                <label className="form-label">Amount (TSh)</label>
                <input
                  type="number"
                  min="0.01"
                  step="0.01"
                  required
                  className="form-control"
                  value={form.amount}
                  onChange={(e) => setForm({ ...form, amount: e.target.value })}
                />
              </div>
              <div className="col-md-4">
                <label className="form-label">Description / reference</label>
                <input
                  required
                  className="form-control"
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                />
              </div>
              <div className="col-md-2 d-flex align-items-end">
                <button type="submit" className="btn btn-success w-100" disabled={saving}>
                  {saving ? 'Saving…' : 'Save'}
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
                <th>Date</th>
                <th>Type</th>
                <th>Member</th>
                <th>Description</th>
                <th className="text-end">Amount</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={5} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && transactions.length === 0 && (
                <tr>
                  <td colSpan={5} className="text-center text-muted py-3">
                    No transactions yet
                  </td>
                </tr>
              )}
              {transactions.map((t) => (
                <tr key={t.id}>
                  <td>{formatDate(t.createdAt)}</td>
                  <td>
                    <span className="badge bg-light text-dark border">
                      {t.type.replace('_', ' ')}
                    </span>
                  </td>
                  <td>{t.member?.name || '-'}</td>
                  <td>{t.description || '-'}</td>
                  <td
                    className={`text-end fw-semibold ${
                      t.direction === 'IN' ? 'text-success' : 'text-danger'
                    }`}
                  >
                    {t.direction === 'IN' ? '+' : '-'}
                    {formatCurrency(t.amount)}
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
