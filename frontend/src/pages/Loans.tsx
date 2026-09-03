import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { loansApi, membersApi } from '../api/endpoints';
import { GroupMember, Loan } from '../types';
import { formatCurrency, formatDate, toDateInputValue } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

export default function Loans() {
  const { activeGroup } = useGroup();
  const [loans, setLoans] = useState<Loan[]>([]);
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [repayError, setRepayError] = useState('');
  const [repayAmounts, setRepayAmounts] = useState<Record<string, string>>({});
  const today = toDateInputValue();
  const [form, setForm] = useState({
    memberId: '',
    principal: '',
    interestRate: '',
    issueDate: today,
    dueDate: today,
  });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    Promise.all([loansApi.list(activeGroup.id), membersApi.list(activeGroup.id)])
      .then(([l, m]) => {
        setLoans(l.data);
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
      await loansApi.create(activeGroup.id, {
        memberId: form.memberId,
        principal: Number(form.principal),
        interestRate: form.interestRate ? Number(form.interestRate) : undefined,
        issueDate: form.issueDate,
        dueDate: form.dueDate,
      });
      setForm({ memberId: '', principal: '', interestRate: '', issueDate: today, dueDate: today });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function handleRepay(loan: Loan) {
    if (!activeGroup) return;
    const amount = Number(repayAmounts[loan.id] || 0);
    if (!amount || amount <= 0) return;
    setRepayError('');
    try {
      await loansApi.repay(activeGroup.id, loan.id, amount);
      setRepayAmounts({ ...repayAmounts, [loan.id]: '' });
      load();
    } catch (err) {
      setRepayError(getApiErrorMessage(err));
    }
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Loans & Repayments</h4>
        <RoleGuard roles={['ADMIN', 'TREASURER']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Issue loan
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-3">
                <label className="form-label">Borrower</label>
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
              <div className="col-md-2">
                <label className="form-label">Principal (TSh)</label>
                <input
                  type="number"
                  min={1}
                  className="form-control"
                  required
                  value={form.principal}
                  onChange={(e) => setForm({ ...form, principal: e.target.value })}
                />
              </div>
              <div className="col-md-2">
                <label className="form-label">
                  Interest %{' '}
                  <small className="text-muted">
                    (default {Number(activeGroup?.loanInterestRate)}%)
                  </small>
                </label>
                <input
                  type="number"
                  min={0}
                  className="form-control"
                  value={form.interestRate}
                  onChange={(e) => setForm({ ...form, interestRate: e.target.value })}
                  placeholder="Optional"
                />
              </div>
              <div className="col-md-2">
                <label className="form-label">Issue date</label>
                <input
                  type="date"
                  className="form-control"
                  required
                  value={form.issueDate}
                  onChange={(e) => setForm({ ...form, issueDate: e.target.value })}
                />
              </div>
              <div className="col-md-2">
                <label className="form-label">Due date</label>
                <input
                  type="date"
                  className="form-control"
                  required
                  value={form.dueDate}
                  onChange={(e) => setForm({ ...form, dueDate: e.target.value })}
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

      {repayError && <div className="alert alert-danger py-2">{repayError}</div>}

      <div className="card border-0 shadow-sm">
        <div className="table-responsive">
          <table className="table mb-0 align-middle">
            <thead>
              <tr>
                <th>Borrower</th>
                <th className="text-end">Principal</th>
                <th>Interest</th>
                <th>Issued</th>
                <th>Due</th>
                <th className="text-end">Outstanding</th>
                <th>Status</th>
                <RoleGuard roles={['ADMIN', 'TREASURER']}>
                  <th>Repay</th>
                </RoleGuard>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={8} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && loans.length === 0 && (
                <tr>
                  <td colSpan={8} className="text-center text-muted py-3">
                    No loans issued yet
                  </td>
                </tr>
              )}
              {loans.map((loan) => (
                <tr key={loan.id}>
                  <td className="fw-semibold">{loan.member?.name}</td>
                  <td className="text-end">{formatCurrency(loan.principal)}</td>
                  <td>{Number(loan.interestRate)}%</td>
                  <td>{formatDate(loan.issueDate)}</td>
                  <td>{formatDate(loan.dueDate)}</td>
                  <td className="text-end fw-semibold">
                    {formatCurrency(loan.outstanding ?? 0)}
                  </td>
                  <td>
                    <span
                      className={`badge ${
                        loan.status === 'PAID'
                          ? 'bg-success'
                          : loan.isOverdue
                          ? 'bg-danger'
                          : 'bg-warning text-dark'
                      }`}
                    >
                      {loan.status === 'PAID' ? 'PAID' : loan.isOverdue ? 'OVERDUE' : 'ACTIVE'}
                    </span>
                  </td>
                  <RoleGuard roles={['ADMIN', 'TREASURER']}>
                    <td>
                      {loan.status !== 'PAID' && (
                        <div className="input-group input-group-sm" style={{ width: 160 }}>
                          <input
                            type="number"
                            min={0}
                            className="form-control"
                            placeholder="Amount"
                            value={repayAmounts[loan.id] || ''}
                            onChange={(e) =>
                              setRepayAmounts({ ...repayAmounts, [loan.id]: e.target.value })
                            }
                          />
                          <button
                            className="btn btn-outline-success"
                            onClick={() => handleRepay(loan)}
                          >
                            Pay
                          </button>
                        </div>
                      )}
                    </td>
                  </RoleGuard>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
