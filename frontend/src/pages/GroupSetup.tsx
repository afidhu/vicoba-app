import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useGroup } from '../context/GroupContext';
import { useAuth } from '../context/AuthContext';
import { groupsApi } from '../api/endpoints';
import { getApiErrorMessage } from '../api/client';

export default function GroupSetup() {
  const { groups, refreshGroups, setActiveGroupId } = useGroup();
  const { logout } = useAuth();
  const navigate = useNavigate();
  const [showForm, setShowForm] = useState(groups.length === 0);
  const [error, setError] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [form, setForm] = useState({
    name: '',
    location: '',
    meetingDay: 'Saturday',
    weeklyContribution: 5000,
    sharePrice: 10000,
    fineDefaultAmount: 1000,
    loanInterestRate: 10,
  });

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    setError('');
    setSubmitting(true);
    try {
      const { data } = await groupsApi.create(form);
      await refreshGroups();
      await setActiveGroupId(data.id);
      navigate('/dashboard');
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSubmitting(false);
    }
  }

  async function handleSelect(groupId: string) {
    await setActiveGroupId(groupId);
    navigate('/dashboard');
  }

  return (
    <div className="min-vh-100 bg-light py-5">
      <div className="container" style={{ maxWidth: 700 }}>
        <div className="d-flex justify-content-between align-items-center mb-4">
          <h3 className="fw-bold text-success mb-0">🤝 Your VICOBA Groups</h3>
          <button className="btn btn-outline-secondary btn-sm" onClick={() => logout()}>
            Logout
          </button>
        </div>

        {groups.length > 0 && (
          <div className="card mb-4 shadow-sm">
            <div className="card-body">
              <h6 className="fw-semibold mb-3">Select a group</h6>
              <div className="list-group">
                {groups.map((g) => (
                  <button
                    key={g.id}
                    className="list-group-item list-group-item-action d-flex justify-content-between align-items-center"
                    onClick={() => handleSelect(g.id)}
                  >
                    <div>
                      <div className="fw-semibold">{g.name}</div>
                      <small className="text-muted">{g.location || 'No location set'}</small>
                    </div>
                    <span className="badge bg-success-subtle text-success-emphasis">
                      {g._count?.members ?? 0} members
                    </span>
                  </button>
                ))}
              </div>
            </div>
          </div>
        )}

        <div className="card shadow-sm">
          <div className="card-body">
            <div className="d-flex justify-content-between align-items-center">
              <h6 className="fw-semibold mb-0">Create a new group</h6>
              {groups.length > 0 && (
                <button
                  className="btn btn-sm btn-link"
                  onClick={() => setShowForm((v) => !v)}
                >
                  {showForm ? 'Hide' : 'Show form'}
                </button>
              )}
            </div>

            {showForm && (
              <form className="mt-3" onSubmit={handleCreate}>
                {error && <div className="alert alert-danger py-2">{error}</div>}
                <div className="row g-3">
                  <div className="col-md-6">
                    <label className="form-label">Group name</label>
                    <input
                      className="form-control"
                      required
                      value={form.name}
                      onChange={(e) => setForm({ ...form, name: e.target.value })}
                    />
                  </div>
                  <div className="col-md-6">
                    <label className="form-label">Location</label>
                    <input
                      className="form-control"
                      value={form.location}
                      onChange={(e) => setForm({ ...form, location: e.target.value })}
                    />
                  </div>
                  <div className="col-md-6">
                    <label className="form-label">Meeting day</label>
                    <select
                      className="form-select"
                      value={form.meetingDay}
                      onChange={(e) => setForm({ ...form, meetingDay: e.target.value })}
                    >
                      {['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map(
                        (d) => (
                          <option key={d} value={d}>
                            {d}
                          </option>
                        ),
                      )}
                    </select>
                  </div>
                  <div className="col-md-6">
                    <label className="form-label">Weekly contribution (TSh)</label>
                    <input
                      type="number"
                      min={0}
                      className="form-control"
                      value={form.weeklyContribution}
                      onChange={(e) =>
                        setForm({ ...form, weeklyContribution: Number(e.target.value) })
                      }
                    />
                  </div>
                  <div className="col-md-4">
                    <label className="form-label">Share price (TSh)</label>
                    <input
                      type="number"
                      min={0}
                      className="form-control"
                      value={form.sharePrice}
                      onChange={(e) => setForm({ ...form, sharePrice: Number(e.target.value) })}
                    />
                  </div>
                  <div className="col-md-4">
                    <label className="form-label">Default fine (TSh)</label>
                    <input
                      type="number"
                      min={0}
                      className="form-control"
                      value={form.fineDefaultAmount}
                      onChange={(e) =>
                        setForm({ ...form, fineDefaultAmount: Number(e.target.value) })
                      }
                    />
                  </div>
                  <div className="col-md-4">
                    <label className="form-label">Loan interest (%)</label>
                    <input
                      type="number"
                      min={0}
                      className="form-control"
                      value={form.loanInterestRate}
                      onChange={(e) =>
                        setForm({ ...form, loanInterestRate: Number(e.target.value) })
                      }
                    />
                  </div>
                </div>
                <button
                  type="submit"
                  className="btn btn-success mt-4"
                  disabled={submitting}
                >
                  {submitting ? 'Creating...' : 'Create group'}
                </button>
              </form>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
