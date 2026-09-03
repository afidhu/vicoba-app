import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { membersApi } from '../api/endpoints';
import { GroupMember, GroupRole } from '../types';
import { getApiErrorMessage } from '../api/client';
import { formatDate } from '../utils/format';
import RoleGuard from '../components/RoleGuard';

const ROLES: GroupRole[] = ['ADMIN', 'TREASURER', 'SECRETARY', 'MEMBER'];

export default function Members() {
  const { activeGroup } = useGroup();
  const [members, setMembers] = useState<GroupMember[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ name: '', phone: '', role: 'MEMBER' as GroupRole });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    membersApi
      .list(activeGroup.id)
      .then(({ data }) => setMembers(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await membersApi.create(activeGroup.id, form);
      setForm({ name: '', phone: '', role: 'MEMBER' });
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
              <div className="col-md-4">
                <label className="form-label">Name</label>
                <input
                  className="form-control"
                  required
                  value={form.name}
                  onChange={(e) => setForm({ ...form, name: e.target.value })}
                />
              </div>
              <div className="col-md-4">
                <label className="form-label">Phone</label>
                <input
                  className="form-control"
                  value={form.phone}
                  onChange={(e) => setForm({ ...form, phone: e.target.value })}
                />
              </div>
              <div className="col-md-3">
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
                  <td className="fw-semibold">{m.name}</td>
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
    </div>
  );
}
