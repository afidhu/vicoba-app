import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { membersApi, transactionsApi } from '../api/endpoints';
import { GroupMember, GroupRole, Transaction } from '../types';
import { getApiErrorMessage } from '../api/client';
import { formatCurrency, formatDate } from '../utils/format';
import RoleGuard from '../components/RoleGuard';

const ROLES: GroupRole[] = ['ADMIN', 'TREASURER', 'SECRETARY', 'MEMBER'];

export default function Members() {
  const { activeGroup } = useGroup();
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ name: '', phone: '', nidaNumber: '', role: 'MEMBER' as GroupRole });
  const [createLogin, setCreateLogin] = useState(false);
  const [loginForm, setLoginForm] = useState({ email: '', password: '' });
  const [selectedMember, setSelectedMember] = useState<GroupMember | null>(null);
  const [recentTransactions, setRecentTransactions] = useState<Transaction[]>([]);
  const [recentTransactionsLoading, setRecentTransactionsLoading] = useState(false);
  const [recentTransactionsError, setRecentTransactionsError] = useState('');

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    membersApi
      .list(activeGroup.id)
      .then(({ data }) => setMembers(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  useEffect(() => {
    if (!activeGroup || !selectedMember) return;
    let current = true;
    setRecentTransactions([]);
    setRecentTransactionsLoading(true);
    setRecentTransactionsError('');
    transactionsApi.list(activeGroup.id, { memberId: selectedMember.id })
      .then(({ data }) => {
        if (current) setRecentTransactions(data.slice(0, 10));
      })
      .catch((err) => {
        if (current) setRecentTransactionsError(getApiErrorMessage(err));
      })
      .finally(() => {
        if (current) setRecentTransactionsLoading(false);
      });
    return () => { current = false; };
  }, [activeGroup?.id, selectedMember?.id]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await membersApi.create(activeGroup.id, {
        ...form,
        ...(createLogin ? loginForm : {}),
      });
      setForm({ name: '', phone: '', nidaNumber: '', role: 'MEMBER' });
      setLoginForm({ email: '', password: '' });
      setCreateLogin(false);
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  async function toggleActive(member: GroupMember) {
    if (!activeGroup) return;
    await membersApi.update(activeGroup.id, member.id, { isActive: !member.isActive });
    load();
  }

  async function changeRole(member: GroupMember, role: GroupRole) {
    if (!activeGroup) return;
    await membersApi.update(activeGroup.id, member.id, { role });
    load();
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Members</h4>
        <RoleGuard roles={['ADMIN', 'SECRETARY']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Add member
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
              <div className="col-md-3">
                <label className="form-label">Name</label>
                <input
                  className="form-control"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label">Phone</label>
                <input
                  className="form-control"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                />
              </div>
              <div className="col-md-3">
                <label className="form-label">NIDA number</label>
                <input
                  className="form-control"
                  value={form.nidaNumber}
                  onChange={(e) => setForm({ ...form, nidaNumber: e.target.value })}
                />
              </div>
              <div className="col-md-2">
                <label className="form-label">Role</label>
                <select
                  className="form-select"
                  value={form.role}
                  onChange={(e) => setForm({ ...form, role: e.target.value as GroupRole })}
                >
                  {ROLES.map((r) => (
                    <option key={r} value={r}>
                      {r}
                    </option>
                  ))}
                </select>
              </div>
              <div className="col-md-1 d-flex align-items-end">
                <button type="submit" className="btn btn-success w-100">
                  Save
                </button>
              </div>
              <div className="col-12">
                <div className="form-check">
                  <input
                    type="checkbox"
                    className="form-check-input"
                    id="createLogin"
                    checked={createLogin}
                    onChange={(e) => setCreateLogin(e.target.checked)}
                  />
                  <label className="form-check-label" htmlFor="createLogin">
                    Create a login for this member (lets them sign in to the app)
                  </label>
                </div>
              </div>
              {createLogin && (
                <>
                  <div className="col-md-4">
                    <label className="form-label">Email address</label>
                    <input
                      type="email"
                      className="form-control"
                      required={createLogin}
                      value={loginForm.email}
                      onChange={(e) => setLoginForm({ ...loginForm, email: e.target.value })}
                    />
                  </div>
                  <div className="col-md-4">
                    <label className="form-label">Password</label>
                    <input
                      type="password"
                      className="form-control"
                      required={createLogin}
                      minLength={6}
                      placeholder="At least 6 characters"
                      value={loginForm.password}
                      onChange={(e) => setLoginForm({ ...loginForm, password: e.target.value })}
                    />
                  </div>
                </>
              )}
            </form>
          </div>
        </div>
      )}

      <div className="card border-0 shadow-sm">
        <div className="table-responsive">
          <table className="table mb-0 align-middle">
            <thead>
              <tr>
                <th>Name</th>
                <th>Phone</th>
                <th>Role</th>
                <th>Shares</th>
                <th>Joined</th>
                <th>Status</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {loading && (
                <tr>
                  <td colSpan={7} className="text-center py-3">
                    <div className="spinner-border spinner-border-sm text-success" />
                  </td>
                </tr>
              )}
              {!loading && members.length === 0 && (
                <tr>
                  <td colSpan={7} className="text-center text-muted py-3">
                    No members yet
                  </td>
                </tr>
              )}
              {members.map((m) => (
                <tr key={m.id}>
                  <td>
                    <button
                      className="btn btn-link p-0 fw-semibold text-decoration-none"
                      onClick={() => setSelectedMember(m)}
                    >
                      {m.name}
                    </button>
                  </td>
                  <td>{m.phone || '-'}</td>
                  <td>
                    <RoleGuard
                      roles={['ADMIN', 'SECRETARY']}
                      fallback={<span className="badge bg-light text-dark border">{m.role}</span>}
                    >
                      <select
                        className="form-select form-select-sm"
                        style={{ width: 130 }}
                        value={m.role}
                        disabled={m.role === 'OWNER'}
                        onChange={(e) => changeRole(m, e.target.value as GroupRole)}
                      >
                        {m.role === 'OWNER' && <option value="OWNER">OWNER</option>}
                        {ROLES.map((r) => (
                          <option key={r} value={r}>
                            {r}
                          </option>
                        ))}
                      </select>
                    </RoleGuard>
                  </td>
                  <td>{m.shareHoldings}</td>
                  <td>{formatDate(m.joinedAt)}</td>
                  <td>
                    <span className={`badge ${m.isActive ? 'bg-success' : 'bg-secondary'}`}>
                      {m.isActive ? 'Active' : 'Inactive'}
                    </span>
                  </td>
                  <td>
                    <RoleGuard roles={['ADMIN', 'SECRETARY']}>
                      {m.role !== 'OWNER' && (
                        <button
                          className="btn btn-sm btn-outline-secondary"
                          onClick={() => toggleActive(m)}
                        >
                          {m.isActive ? 'Deactivate' : 'Activate'}
                        </button>
                      )}
                    </RoleGuard>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {selectedMember && (
        <div
          className="modal d-block"
          role="dialog"
          aria-modal="true"
          aria-labelledby="member-profile-title"
          style={{ backgroundColor: 'rgba(0, 0, 0, 0.45)' }}
        >
          <div className="modal-dialog modal-lg modal-dialog-centered modal-dialog-scrollable">
            <div className="modal-content">
              <div className="modal-header">
                <div>
                  <h5 className="modal-title fw-bold" id="member-profile-title">Member Profile</h5>
                  <div className="text-muted">{selectedMember.name}</div>
                </div>
                <button
                  type="button"
                  className="btn-close"
                  aria-label="Close"
                  onClick={() => setSelectedMember(null)}
                />
              </div>
              <div className="modal-body">
                <div className="row g-2 mb-4">
                  <div className="col-sm-4"><span className="text-muted">Phone:</span> {selectedMember.phone || '-'}</div>
                  <div className="col-sm-4"><span className="text-muted">NIDA:</span> {selectedMember.nidaNumber || '-'}</div>
                  <div className="col-sm-4"><span className="text-muted">Role:</span> {selectedMember.role}</div>
                  <div className="col-sm-4"><span className="text-muted">Shares:</span> {selectedMember.shareHoldings}</div>
                </div>
                <h6 className="fw-semibold mb-3">Recent Transactions</h6>
                {recentTransactionsLoading ? (
                  <div className="text-center py-3"><div className="spinner-border spinner-border-sm text-success" /></div>
                ) : recentTransactionsError ? (
                  <div className="alert alert-danger py-2">{recentTransactionsError}</div>
                ) : recentTransactions.length === 0 ? (
                  <div className="text-muted py-2">No transactions recorded for this member.</div>
                ) : (
                  <div className="table-responsive">
                    <table className="table table-sm align-middle mb-0">
                      <thead>
                        <tr><th>Date</th><th>Type</th><th>Description</th><th className="text-end">Amount</th></tr>
                      </thead>
                      <tbody>
                        {recentTransactions.map((transaction) => (
                          <tr key={transaction.id}>
                            <td>{formatDate(transaction.createdAt)}</td>
                            <td>{transaction.type.replace(/_/g, ' ')}</td>
                            <td>{transaction.description || '-'}</td>
                            <td className={`text-end fw-semibold ${transaction.direction === 'IN' ? 'text-success' : 'text-danger'}`}>
                              {transaction.direction === 'IN' ? '+' : '-'}{formatCurrency(transaction.amount)}
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
