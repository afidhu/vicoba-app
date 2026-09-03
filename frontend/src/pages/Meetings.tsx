import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { meetingsApi } from '../api/endpoints';
import { Meeting } from '../types';
import { formatDate, toDateInputValue } from '../utils/format';
import { getApiErrorMessage } from '../api/client';
import RoleGuard from '../components/RoleGuard';

export default function Meetings() {
  const { activeGroup } = useGroup();
  const [meetings, setMeetings] = useState<Meeting[]>([]);
  const [loading, setLoading] = useState(true);
  const [showForm, setShowForm] = useState(false);
  const [error, setError] = useState('');
  const [form, setForm] = useState({ date: toDateInputValue(), notes: '' });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    meetingsApi
      .list(activeGroup.id)
      .then(({ data }) => setMeetings(data))
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  async function handleCreate(e: React.FormEvent) {
    e.preventDefault();
    if (!activeGroup) return;
    setError('');
    try {
      await meetingsApi.create(activeGroup.id, form);
      setForm({ date: toDateInputValue(), notes: '' });
      setShowForm(false);
      load();
    } catch (err) {
      setError(getApiErrorMessage(err));
    }
  }

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Meetings</h4>
        <RoleGuard roles={['ADMIN', 'SECRETARY']}>
          <button className="btn btn-success" onClick={() => setShowForm((v) => !v)}>
            <i className="bi bi-plus-lg me-1" /> Record meeting
          </button>
        </RoleGuard>
      </div>

      {showForm && (
        <div className="card border-0 shadow-sm mb-3">
          <div className="card-body">
            {error && <div className="alert alert-danger py-2">{error}</div>}
            <form className="row g-3" onSubmit={handleCreate}>
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
              <div className="col-md-7">
                <label className="form-label">Notes</label>
                <input
                  className="form-control"
                  value={form.notes}
                  onChange={(e) => setForm({ ...form, notes: e.target.value })}
                  placeholder="Optional meeting notes"
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
        <ul className="list-group list-group-flush">
          {loading && (
            <li className="list-group-item text-center py-3">
              <div className="spinner-border spinner-border-sm text-success" />
            </li>
          )}
          {!loading && meetings.length === 0 && (
            <li className="list-group-item text-center text-muted py-3">
              No meetings recorded
            </li>
          )}
          {meetings.map((m) => (
            <li key={m.id} className="list-group-item d-flex justify-content-between align-items-center">
              <div>
                <div className="fw-semibold">{formatDate(m.date)}</div>
                <small className="text-muted">{m.notes || 'No notes'}</small>
              </div>
              <i className="bi bi-calendar-event text-success fs-5" />
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
