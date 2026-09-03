import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { transactionsApi } from '../api/endpoints';
import { Transaction, TransactionType } from '../types';
import { formatCurrency, formatDate } from '../utils/format';

const TYPES: TransactionType[] = [
  'CONTRIBUTION',
  'SHARE_PURCHASE',
  'FINE',
  'LOAN_DISBURSEMENT',
  'LOAN_REPAYMENT',
  'EXPENSE',
];

export default function Transactions() {
  const { activeGroup } = useGroup();
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [typeFilter, setTypeFilter] = useState('');

  useEffect(() => {
    if (!activeGroup) return;
    setLoading(true);
    transactionsApi
      .list(activeGroup.id, typeFilter ? { type: typeFilter } : undefined)
      .then(({ data }) => setTransactions(data))
      .finally(() => setLoading(false));
  }, [activeGroup, typeFilter]);

  return (
    <div>
      <div className="d-flex justify-content-between align-items-center mb-3">
        <h4 className="fw-bold mb-0">Transaction History</h4>
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
