import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { dashboardApi } from '../api/endpoints';
import { DashboardSummary } from '../types';
import { formatCurrency, formatDate } from '../utils/format';

function StatCard({
  label,
  value,
  icon,
  variant,
}: {
  label: string;
  value: string;
  icon: string;
  variant: string;
}) {
  return (
    <div className="col-md-4 col-lg-2-4">
      <div className="card border-0 shadow-sm h-100">
        <div className="card-body">
          <div
            className={`rounded-circle bg-${variant}-subtle text-${variant}-emphasis d-inline-flex align-items-center justify-content-center mb-2`}
            style={{ width: 40, height: 40 }}
          >
            <i className={`bi ${icon}`} />
          </div>
          <div className="text-muted small">{label}</div>
          <div className="fs-5 fw-bold">{value}</div>
        </div>
      </div>
    </div>
  );
}

export default function Dashboard() {
  const { activeGroup } = useGroup();
  const [summary, setSummary] = useState<DashboardSummary | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    if (!activeGroup) return;
    setLoading(true);
    dashboardApi
      .get(activeGroup.id)
      .then(({ data }) => setSummary(data))
      .finally(() => setLoading(false));
  }, [activeGroup]);

  if (loading || !summary) {
    return <div className="spinner-border text-success" role="status" />;
  }

  return (
    <div>
      <h4 className="fw-bold mb-1">{summary.group.name}</h4>
      <p className="text-muted">
        {summary.group.location} &bull; Meets {summary.group.meetingDay || 'N/A'}
      </p>

      <div className="row g-3 mb-4">
        <StatCard
          label="Active members"
          value={`${summary.counts.activeMembers}/${summary.counts.totalMembers}`}
          icon="bi-people-fill"
          variant="success"
        />
        <StatCard
          label="Total contributions"
          value={formatCurrency(summary.totals.totalContributions)}
          icon="bi-piggy-bank-fill"
          variant="primary"
        />
        <StatCard
          label="Share capital"
          value={formatCurrency(summary.totals.totalShareCapital)}
          icon="bi-pie-chart-fill"
          variant="info"
        />
        <StatCard
          label="Outstanding loans"
          value={formatCurrency(summary.totals.outstandingLoans)}
          icon="bi-cash-coin"
          variant="warning"
        />
        <StatCard
          label="Unpaid fines"
          value={formatCurrency(summary.totals.unpaidFines)}
          icon="bi-exclamation-triangle-fill"
          variant="danger"
        />
      </div>

      <div className="row g-4">
        <div className="col-md-7">
          <div className="card border-0 shadow-sm">
            <div className="card-header bg-white fw-semibold">Recent transactions</div>
            <div className="table-responsive">
              <table className="table mb-0">
                <thead>
                  <tr>
                    <th>Date</th>
                    <th>Type</th>
                    <th>Member</th>
                    <th className="text-end">Amount</th>
                  </tr>
                </thead>
                <tbody>
                  {summary.recentTransactions.length === 0 && (
                    <tr>
                      <td colSpan={4} className="text-center text-muted py-3">
                        No transactions yet
                      </td>
                    </tr>
                  )}
                  {summary.recentTransactions.map((t) => (
                    <tr key={t.id}>
                      <td>{formatDate(t.createdAt)}</td>
                      <td>
                        <span className="badge bg-light text-dark border">
                          {t.type.replace('_', ' ')}
                        </span>
                      </td>
                      <td>{t.member?.name || '-'}</td>
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

        <div className="col-md-5">
          <div className="card border-0 shadow-sm">
            <div className="card-header bg-white fw-semibold">Group rules</div>
            <ul className="list-group list-group-flush">
              <li className="list-group-item d-flex justify-content-between">
                <span>Weekly contribution</span>
                <strong>{formatCurrency(summary.group.weeklyContribution)}</strong>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span>Share price</span>
                <strong>{formatCurrency(summary.group.sharePrice)}</strong>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span>Default fine</span>
                <strong>{formatCurrency(summary.group.fineDefaultAmount)}</strong>
              </li>
              <li className="list-group-item d-flex justify-content-between">
                <span>Loan interest rate</span>
                <strong>{Number(summary.group.loanInterestRate)}%</strong>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  );
}
