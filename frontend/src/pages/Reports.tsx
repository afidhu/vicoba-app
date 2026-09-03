import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { reportsApi } from '../api/endpoints';
import { formatCurrency, toDateInputValue } from '../utils/format';

interface Summary {
  contributions: { total: number; count: number };
  fines: { totalUnpaid: number; totalPaid: number; count: number };
  loans: { totalDisbursed: number; totalOutstanding: number; count: number };
  expenses: { total: number; count: number };
  cashFlow: { totalIn: number; totalOut: number; netMovement: number };
}

export default function Reports() {
  const { activeGroup } = useGroup();
  const [summary, setSummary] = useState<Summary | null>(null);
  const [loading, setLoading] = useState(true);
  const [range, setRange] = useState({ from: '', to: toDateInputValue() });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    const params: Record<string, string> = {};
    if (range.from) params.from = range.from;
    if (range.to) params.to = range.to;
    reportsApi
      .summary(activeGroup.id, params)
      .then(({ data }) => setSummary(data as Summary))
      .finally(() => setLoading(false));
  }

  useEffect(load, [activeGroup]);

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h4 className="fw-bold mb-0">Reports</h4>
        <form className="d-flex gap-2 align-items-end" onSubmit={(e) => { e.preventDefault(); load(); }}>
          <div>
            <label className="form-label small mb-0">From</label>
            <input
              type="date"
              className="form-control form-control-sm"
              value={range.from}
              onChange={(e) => setRange({ ...range, from: e.target.value })}
            />
          </div>
          <div>
            <label className="form-label small mb-0">To</label>
            <input
              type="date"
              className="form-control form-control-sm"
              value={range.to}
              onChange={(e) => setRange({ ...range, to: e.target.value })}
            />
          </div>
          <button type="submit" className="btn btn-success btn-sm">
            Apply
          </button>
        </form>
      </div>

      {loading || !summary ? (
        <div className="spinner-border text-success" role="status" />
      ) : (
        <div className="row g-3">
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Contributions</h6>
                <p className="mb-1">Total: <strong>{formatCurrency(summary.contributions.total)}</strong></p>
                <p className="mb-0 text-muted">{summary.contributions.count} records</p>
              </div>
            </div>
          </div>
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Fines</h6>
                <p className="mb-1">Paid: <strong className="text-success">{formatCurrency(summary.fines.totalPaid)}</strong></p>
                <p className="mb-1">Unpaid: <strong className="text-danger">{formatCurrency(summary.fines.totalUnpaid)}</strong></p>
                <p className="mb-0 text-muted">{summary.fines.count} records</p>
              </div>
            </div>
          </div>
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Loans</h6>
                <p className="mb-1">Disbursed: <strong>{formatCurrency(summary.loans.totalDisbursed)}</strong></p>
                <p className="mb-1">Outstanding: <strong className="text-warning">{formatCurrency(summary.loans.totalOutstanding)}</strong></p>
                <p className="mb-0 text-muted">{summary.loans.count} loans</p>
              </div>
            </div>
          </div>
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Expenses</h6>
                <p className="mb-1">Total: <strong className="text-danger">{formatCurrency(summary.expenses.total)}</strong></p>
                <p className="mb-0 text-muted">{summary.expenses.count} records</p>
              </div>
            </div>
          </div>
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Cash flow</h6>
                <p className="mb-1">In: <strong className="text-success">{formatCurrency(summary.cashFlow.totalIn)}</strong></p>
                <p className="mb-1">Out: <strong className="text-danger">{formatCurrency(summary.cashFlow.totalOut)}</strong></p>
                <p className="mb-0">Net: <strong>{formatCurrency(summary.cashFlow.netMovement)}</strong></p>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
