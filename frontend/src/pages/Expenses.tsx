import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { expensesApi } from '../api/endpoints';
import { Expense } from '../types';
import { formatCurrency, formatDate, toDateInputValue } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

export default function Expenses() {
  const { activeGroup } = useGroup();
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ description: '', amount: '', date: toDateInputValue() });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    expensesApi
      .list(activeGroup.id)
      .then(({ data }) => setExpenses(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await expensesApi.create(activeGroup.id, {
        description: form.description,
        amount: Number(form.amount),
        date: form.date,
      });
      setForm({ description: '', amount: '', date: toDateInputValue() });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  const total = expenses.reduce((sum, e) => sum + Number(e.amount), 0);

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Expenses</h4>
        <RoleGuard roles={['ADMIN', 'TREASURER']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Record expense
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-5">
                <label className="form-label">Description</label>
                <input
                  className="form-control"
                  required
                  value={form.description}
                  onChange={(e) => setForm({ ...form, description: e.target.value })}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label">Amount (TSh)</label>
                <input
                  type="number"
                  min={1}
                  className="form-control"
                  required
                  value={form.amount}
                  onChange={(e) => setForm({ ...form, amount: e.target.value })}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label">Date</label>
                <input
                  type="date"
                  className="form-control"
                  required
                  value={form.date}
                  onChange={(e) => setForm({ ...form, date: e.target.value })}
                />
              </div>
              <div className="col-md-1 d-flex align-items-end">
                <button type="submit" className="btn btn-success w-100">
                  Save
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      <div className="card border-0 shadow-sm">
        <div className="card-header bg-white d-flex justify-content-between">
          <span className="fw-semibold">Expense history</span>
          <span className="text-danger fw-semibold">Total: {formatCurrency(total)}</span>
        </div>
        <div className="table-responsive">
          <table className="table mb-0 align-middle">
            <thead>
              <tr>
                <th>Description</th>
                <th>Date</th>
                <th className="text-end">Amount</th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={3} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && expenses.length === 0 && (
                <tr>
                  <td colSpan={3} className="text-center text-muted py-3">
                    No expenses recorded
                  </td>
                </tr>
              )}
              {expenses.map((e) => (
                <tr key={e.id}>
                  <td className="fw-semibold">{e.description}</td>
                  <td>{formatDate(e.date)}</td>
                  <td className="text-end text-danger fw-semibold">{formatCurrency(e.amount)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
