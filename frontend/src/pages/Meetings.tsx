import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { meetingsApi, membersApi } from '../api/endpoints';
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
  const [selectedMeetingId, setSelectedMeetingId] = useState<string | null>(null);

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
              <RoleGuard
                roles={['ADMIN', 'SECRETARY']}
                fallback={<i className="bi bi-calendar-event text-success fs-5" />}
              >
                <button
                  className="btn btn-sm btn-outline-success"
                  onClick={() => setSelectedMeetingId((current) => current === m.id ? null : m.id)}
                >
                  {selectedMeetingId === m.id ? 'Close attendance' : 'Record attendance'}
                </button>
              </RoleGuard>
            </li>
          ))}
        </ul>
      </div>

      {selectedMeetingId && activeGroup && (
        <AttendancePanel
          groupId={activeGroup.id}
          meetingId={selectedMeetingId}
          onClose={() => setSelectedMeetingId(null)}
        />
      )}
    </div>
  );
}

function AttendancePanel({
  groupId,
  meetingId,
  onClose,
}: {
  groupId: string;
  meetingId: string;
  onClose: () => void;
}) {
  const [members, setMembers] = useState<{ id: string; name: string }[]>([]);
  const [attendance, setAttendance] = useState<Record<string, boolean>>({});
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [saved, setSaved] = useState(false);

  useEffect(() => {
    let current = true;
    setLoading(true);
    setError('');
    Promise.all([meetingsApi.get(groupId, meetingId), membersApi.list(groupId)])
      .then(([{ data: meeting }, { data: groupMembers }]) => {
        if (!current) return;
        setMembers(groupMembers.map(({ id, name }) => ({ id, name })));
        setAttendance(Object.fromEntries(
          groupMembers.map((member) => [
            member.id,
            meeting.attendances?.find((record) => record.memberId === member.id)?.present ?? true,
          ]),
        ));
      })
      .catch((err) => {
        if (current) setError(getApiErrorMessage(err));
      })
      .finally(() => {
        if (current) setLoading(false);
      });
    return () => { current = false; };
  }, [groupId, meetingId]);

  async function saveAttendance() {
    setSaving(true);
    setError('');
    setSaved(false);
    try {
      await meetingsApi.recordAttendance(
        groupId,
        meetingId,
        members.map((member) => ({ memberId: member.id, present: attendance[member.id] })),
      );
      setSaved(true);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setSaving(false);
    }
  }

  return (
    <div className="card border-0 shadow-sm mt-3">
      <div className="card-header bg-white d-flex justify-content-between align-items-center">
        <span className="fw-semibold">Meeting attendance</span>
        <button className="btn-close" aria-label="Close" onClick={onClose} />
      </div>
      <div className="card-body">
        {error && <div className="alert alert-danger py-2">{error}</div>}
        {saved && <div className="alert alert-success py-2">Attendance saved.</div>}
        {loading ? (
          <div className="text-center py-3"><div className="spinner-border spinner-border-sm text-success" /></div>
        ) : members.length === 0 ? (
          <div className="text-muted">No members to record.</div>
        ) : (
          <>
            <div className="table-responsive">
              <table className="table table-sm align-middle mb-3">
                <thead><tr><th>Member</th><th style={{ width: 240 }}>Status</th></tr></thead>
                <tbody>
                  {members.map((member) => (
                    <tr key={member.id}>
                      <td>{member.name}</td>
                      <td>
                        <select
                          className="form-select form-select-sm"
                          value={attendance[member.id] ? 'ATTENDED' : 'NOT_ATTENDED'}
                          onChange={(event) => setAttendance({
                            ...attendance,
                            [member.id]: event.target.value === 'ATTENDED',
                          })}
                        >
                          <option value="ATTENDED">Attendance</option>
                          <option value="NOT_ATTENDED">Non-attendance</option>
                        </select>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            <button className="btn btn-success" onClick={saveAttendance} disabled={saving}>
              {saving ? 'Saving…' : 'Save attendance'}
            </button>
          </>
        )}
      </div>
    </div>
  );
}
