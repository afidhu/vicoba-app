import React, { useEffect, useState } from 'react';
import { useGroup } from '../context/GroupContext';
import { reportsApi } from '../api/endpoints';
import { formatCurrency, formatDate, toDateInputValue } from '../utils/format';
import '../report-print.css';

interface Summary {
  contributions: { total: number; count: number };
  fines: { totalUnpaid: number; totalPaid: number; count: number };
  loans: { totalDisbursed: number; totalOutstanding: number; count: number };
  expenses: { total: number; count: number };
  cashFlow: { totalIn: number; totalOut: number; netMovement: number };
}

interface AttendanceReport {
  attended: number;
  nonAttendance: number;
  records: {
    meetingId: string;
    meetingTitle?: string | null;
    meetingDate: string;
    memberId: string;
    memberName: string;
    present: boolean;
  }[];
}

export default function Reports() {
  const { activeGroup } = useGroup();
  const [summary, setSummary] = useState<Summary | null>(null);
  const [attendance, setAttendance] = useState<AttendanceReport | null>(null);
  const [loading, setLoading] = useState(true);
  const [range, setRange] = useState({ from: '', to: toDateInputValue() });

  function load() {
    if (!activeGroup) return;
    setLoading(true);
    const params: Record<string, string> = {};
    if (range.from) params.from = range.from;
    if (range.to) params.to = range.to;
    Promise.all([
      reportsApi.summary(activeGroup.id, params),
      reportsApi.attendance(activeGroup.id, params),
    ])
      .then(([{ data: summaryData }, { data: attendanceData }]) => {
        setSummary(summaryData as Summary);
        setAttendance(attendanceData as AttendanceReport);
      })
      .finally(() => setLoading(false));
  }

  function reportRows(): (string | number)[][] {
    if (!summary || !attendance) return [];
    return [
      ['Report', 'Value'],
      ['Contributions', summary.contributions.total],
      ['Fines paid', summary.fines.totalPaid],
      ['Fines outstanding', summary.fines.totalUnpaid],
      ['Loans disbursed', summary.loans.totalDisbursed],
      ['Loans outstanding', summary.loans.totalOutstanding],
      ['Expenses', summary.expenses.total],
      ['Cash received', summary.cashFlow.totalIn],
      ['Cash paid', summary.cashFlow.totalOut],
      ['Net cash movement', summary.cashFlow.netMovement],
      ['Attendance', attendance.attended],
      ['Non-attendance', attendance.nonAttendance],
      [],
      ['Meeting date', 'Meeting', 'Member', 'Status'],
      ...attendance.records.map((record) => [
        formatDate(record.meetingDate),
        record.meetingTitle || 'Group meeting',
        record.memberName,
        record.present ? 'Attendance' : 'Non-attendance',
      ]),
    ];
  }

  function downloadReport(format: 'csv' | 'xls') {
    const rows = reportRows();
    const escapeCsv = (value: string | number) =>
      `"${String(value).replace(/"/g, '""')}"`;
    const content = format === 'csv'
      ? rows.map((row) => row.map(escapeCsv).join(',')).join('\r\n')
      : `<html><head><meta charset="utf-8"></head><body><table>${rows.map((row) =>
          `<tr>${row.map((cell) => `<td>${String(cell).replace(/[&<>"']/g, (character) => ({
            '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;',
          })[character] as string)}</td>`).join('')}</tr>`,
        ).join('')}</table></body></html>`;
    const blob = new Blob([content], {
      type: format === 'csv' ? 'text/csv;charset=utf-8' : 'application/vnd.ms-excel;charset=utf-8',
    });
    const url = URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = `vicoba-report.${format}`;
    link.click();
    URL.revokeObjectURL(url);
  }

  async function downloadPdf() {
    if (!activeGroup || !summary || !attendance) return;

    const { jsPDF } = await import('jspdf');
    const pdf = new jsPDF({ orientation: 'portrait', unit: 'mm', format: 'a4' });
    const pageWidth = pdf.internal.pageSize.getWidth();
    const pageHeight = pdf.internal.pageSize.getHeight();
    const margin = 14;
    const contentWidth = pageWidth - margin * 2;
    const bottom = pageHeight - margin;
    let y = margin;

    pdf.setProperties({
      title: 'Financial & Meeting Attendance Report',
      author: 'VICOBA Manager',
      subject: activeGroup.name,
    });

    pdf.setFont('helvetica', 'bold');
    pdf.setFontSize(10);
    pdf.setTextColor(49, 93, 75);
    pdf.text('VICOBA MANAGER', margin, y + 3);
    y += 10;

    pdf.setFontSize(18);
    pdf.setTextColor(23, 33, 29);
    const titleLines = pdf.splitTextToSize('Financial & Meeting Attendance Report', contentWidth);
    pdf.text(titleLines, margin, y + 4);
    y += titleLines.length * 7 + 3;

    let metadataRows = 1;
    const metadata = [
      { label: 'GROUP', value: activeGroup.name, width: 55 },
      {
        label: 'REPORTING PERIOD',
        value: range.from && range.to
          ? `${formatDate(range.from)} – ${formatDate(range.to)}`
          : range.from
            ? `From ${formatDate(range.from)}`
            : range.to
              ? `Through ${formatDate(range.to)}`
              : 'All dates',
        width: 72,
      },
      { label: 'REPORT DATE', value: formatDate(new Date().toISOString()), width: 43 },
    ];
    const metadataGap = 4;
    let metadataX = margin;
    pdf.setFont('helvetica', 'normal');
    pdf.setFontSize(7.5);
    pdf.setTextColor(83, 97, 90);
    metadata.forEach((item) => {
      pdf.text(item.label, metadataX, y + 2);
      pdf.setFont('helvetica', 'bold');
      pdf.setFontSize(9);
      pdf.setTextColor(23, 33, 29);
      const lines = pdf.splitTextToSize(item.value, item.width);
      metadataRows = Math.max(metadataRows, lines.length);
      pdf.text(lines, metadataX, y + 7);
      metadataX += item.width + metadataGap;
      pdf.setFont('helvetica', 'normal');
      pdf.setFontSize(7.5);
      pdf.setTextColor(83, 97, 90);
    });
    y += Math.max(13, 6 + metadataRows * 4.5) + 3;
    pdf.setDrawColor(49, 93, 75);
    pdf.setLineWidth(0.7);
    pdf.line(margin, y, pageWidth - margin, y);
    y += 7;

    const cards = [
      { title: 'Contributions', rows: [
        { label: 'Total received', value: formatCurrency(summary.contributions.total) },
        { label: 'Records', value: String(summary.contributions.count) },
      ] },
      { title: 'Fines', rows: [
        { label: 'Collected', value: formatCurrency(summary.fines.totalPaid) },
        { label: 'Outstanding', value: formatCurrency(summary.fines.totalUnpaid) },
        { label: 'Records', value: String(summary.fines.count) },
      ] },
      { title: 'Loans', rows: [
        { label: 'Disbursed', value: formatCurrency(summary.loans.totalDisbursed) },
        { label: 'Outstanding', value: formatCurrency(summary.loans.totalOutstanding) },
        { label: 'Loans', value: String(summary.loans.count) },
      ] },
      { title: 'Expenses', rows: [
        { label: 'Total expenses', value: formatCurrency(summary.expenses.total) },
        { label: 'Records', value: String(summary.expenses.count) },
      ] },
      { title: 'Cash Flow', rows: [
        { label: 'In', value: formatCurrency(summary.cashFlow.totalIn) },
        { label: 'Out', value: formatCurrency(summary.cashFlow.totalOut) },
        { label: 'Net movement', value: formatCurrency(summary.cashFlow.netMovement) },
      ] },
      { title: 'Meeting Attendance', rows: [
        { label: 'Attendance', value: String(attendance.attended) },
        { label: 'Non-attendance', value: String(attendance.nonAttendance) },
      ] },
    ];

    function cardHeight(rows: { label: string; value: string }[]) {
      return 12 + rows.length * 5.2 + 3;
    }

    function drawCard(
      title: string,
      rows: { label: string; value: string }[],
      x: number,
      top: number,
      width: number,
      height: number,
    ) {
      pdf.setDrawColor(201, 210, 205);
      pdf.setLineWidth(0.3);
      pdf.roundedRect(x, top, width, height, 2, 2, 'S');
      pdf.setFont('helvetica', 'bold');
      pdf.setFontSize(11);
      pdf.setTextColor(49, 93, 75);
      pdf.text(title, x + 4, top + 6.5);
      pdf.setDrawColor(220, 227, 223);
      pdf.line(x + 4, top + 9, x + width - 4, top + 9);
      pdf.setFontSize(8.5);
      rows.forEach((row, index) => {
        const rowY = top + 14 + index * 5.2;
        pdf.setFont('helvetica', 'normal');
        pdf.setTextColor(23, 33, 29);
        pdf.text(row.label, x + 4, rowY);
        pdf.setFont('helvetica', 'bold');
        pdf.text(row.value, x + width - 4, rowY, { align: 'right' });
      });
    }

    const cardGap = 4;
    const cardWidth = (contentWidth - cardGap) / 2;
    for (let index = 0; index < cards.length; index += 2) {
      const rowCards = cards.slice(index, index + 2);
      const height = Math.max(...rowCards.map((card) => cardHeight(card.rows)));
      if (y + height > bottom) {
        pdf.addPage();
        y = margin;
      }
      rowCards.forEach((card, column) => {
        drawCard(
          card.title,
          card.rows,
          margin + column * (cardWidth + cardGap),
          y,
          cardWidth,
          height,
        );
      });
      y += height + cardGap;
    }

    const columnWidths = [31, 47, 55, contentWidth - 133];
    const tableHeaders = ['Date', 'Meeting', 'Member', 'Status'];

    function drawAttendanceHeading(continued = false) {
      pdf.setFont('helvetica', 'bold');
      pdf.setFontSize(12);
      pdf.setTextColor(49, 93, 75);
      pdf.text(continued ? 'Attendance Details (continued)' : 'Attendance Details', margin, y + 5);
      y += 8;
      pdf.setFillColor(237, 242, 239);
      pdf.setDrawColor(201, 210, 205);
      pdf.setLineWidth(0.25);
      let x = margin;
      tableHeaders.forEach((header, index) => {
        pdf.setFillColor(237, 242, 239);
        pdf.setDrawColor(201, 210, 205);
        pdf.rect(x, y, columnWidths[index], 8, 'FD');
        pdf.setFont('helvetica', 'bold');
        pdf.setFontSize(7.5);
        pdf.setTextColor(23, 33, 29);
        pdf.text(header.toUpperCase(), x + 2, y + 5.2);
        x += columnWidths[index];
      });
      y += 8;
    }

    if (attendance.records.length > 0) {
      if (y + 20 > bottom) {
        pdf.addPage();
        y = margin;
      }
      drawAttendanceHeading();
      attendance.records.forEach((record) => {
        const values = [
          formatDate(record.meetingDate),
          record.meetingTitle || 'Group meeting',
          record.memberName,
          record.present ? 'Attendance' : 'Non-attendance',
        ];
        const wrapped = values.map((value, index) => pdf.splitTextToSize(value, columnWidths[index] - 4));
        const rowHeight = Math.max(8, ...wrapped.map((lines) => lines.length * 4 + 3));
        if (y + rowHeight > bottom) {
          pdf.addPage();
          y = margin;
          drawAttendanceHeading(true);
        }
        let x = margin;
        wrapped.forEach((lines, index) => {
          pdf.setDrawColor(201, 210, 205);
          pdf.rect(x, y, columnWidths[index], rowHeight, 'S');
          pdf.setFont('helvetica', 'normal');
          pdf.setFontSize(8);
          pdf.setTextColor(23, 33, 29);
          pdf.text(lines, x + 2, y + 4.5);
          x += columnWidths[index];
        });
        y += rowHeight;
      });
    }

    pdf.save('vicoba-report.pdf');
  }

  useEffect(load, [activeGroup]);

  return (
    <div>
      <div className="reports-screen">
      <div className="d-flex justify-content-between align-items-center mb-3 flex-wrap gap-2">
        <h4 className="fw-bold mb-0">Reports</h4>
        <div className="d-flex gap-2 align-items-end flex-wrap">
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
        <button className="btn btn-outline-success btn-sm" disabled={!summary || !attendance} onClick={() => downloadReport('csv')}>
          CSV
        </button>
        <button className="btn btn-outline-success btn-sm" disabled={!summary || !attendance} onClick={() => downloadReport('xls')}>
          Excel
        </button>
        <button className="btn btn-outline-secondary btn-sm" onClick={downloadPdf}>
          Print / PDF
        </button>
        </div>
      </div>

      {loading || !summary || !attendance ? (
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
          <div className="col-md-6 col-lg-4">
            <div className="card border-0 shadow-sm h-100">
              <div className="card-body">
                <h6 className="fw-semibold">Meeting attendance</h6>
                <p className="mb-1">Attendance: <strong className="text-success">{attendance.attended}</strong></p>
                <p className="mb-0">Non-attendance: <strong className="text-danger">{attendance.nonAttendance}</strong></p>
              </div>
            </div>
          </div>
          {attendance.records.length > 0 && (
            <div className="col-12">
              <div className="card border-0 shadow-sm">
                <div className="card-header bg-white fw-semibold">Attendance details</div>
                <div className="table-responsive">
                  <table className="table table-sm align-middle mb-0">
                    <thead><tr><th>Meeting date</th><th>Meeting</th><th>Member</th><th>Status</th></tr></thead>
                    <tbody>
                      {attendance.records.map((record, index) => (
                        <tr key={`${record.meetingId}-${record.memberId}-${index}`}>
                          <td>{formatDate(record.meetingDate)}</td>
                          <td>{record.meetingTitle || 'Group meeting'}</td>
                          <td>{record.memberName}</td>
                          <td>
                            <span className={`badge ${record.present ? 'bg-success' : 'bg-secondary'}`}>
                              {record.present ? 'Attendance' : 'Non-attendance'}
                            </span>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              </div>
            </div>
          )}
        </div>
      )}
      </div>

      {!loading && summary && attendance && activeGroup && (
        <article className="print-report" aria-label="VICOBA financial report">
          <header className="print-report-header">
            <div className="print-report-brand">VICOBA Manager</div>
            <h1>Financial &amp; Meeting Attendance Report</h1>
            <div className="print-report-meta">
              <div><span>Group</span><strong>{activeGroup.name}</strong></div>
              <div>
                <span>Reporting period</span>
                <strong>
                  {range.from ? formatDate(range.from) : 'All dates'}
                  {range.to ? ` – ${formatDate(range.to)}` : ''}
                </strong>
              </div>
              <div><span>Report date</span><strong>{formatDate(new Date().toISOString())}</strong></div>
            </div>
          </header>

          <div className="print-report-grid">
            <section className="print-report-section">
              <h2>Contributions</h2>
              <div className="print-report-line"><span>Total received</span><strong>{formatCurrency(summary.contributions.total)}</strong></div>
              <p>{summary.contributions.count} records</p>
            </section>
            <section className="print-report-section">
              <h2>Fines</h2>
              <div className="print-report-line"><span>Collected</span><strong>{formatCurrency(summary.fines.totalPaid)}</strong></div>
              <div className="print-report-line"><span>Outstanding</span><strong>{formatCurrency(summary.fines.totalUnpaid)}</strong></div>
              <p>{summary.fines.count} records</p>
            </section>
            <section className="print-report-section">
              <h2>Loans</h2>
              <div className="print-report-line"><span>Disbursed</span><strong>{formatCurrency(summary.loans.totalDisbursed)}</strong></div>
              <div className="print-report-line"><span>Outstanding</span><strong>{formatCurrency(summary.loans.totalOutstanding)}</strong></div>
              <p>{summary.loans.count} loans</p>
            </section>
            <section className="print-report-section">
              <h2>Expenses</h2>
              <div className="print-report-line"><span>Total expenses</span><strong>{formatCurrency(summary.expenses.total)}</strong></div>
              <p>{summary.expenses.count} records</p>
            </section>
            <section className="print-report-section">
              <h2>Cash Flow</h2>
              <div className="print-report-line"><span>In</span><strong>{formatCurrency(summary.cashFlow.totalIn)}</strong></div>
              <div className="print-report-line"><span>Out</span><strong>{formatCurrency(summary.cashFlow.totalOut)}</strong></div>
              <div className="print-report-line print-report-total"><span>Net movement</span><strong>{formatCurrency(summary.cashFlow.netMovement)}</strong></div>
            </section>
            <section className="print-report-section">
              <h2>Meeting Attendance</h2>
              <div className="print-report-line"><span>Attendance</span><strong>{attendance.attended}</strong></div>
              <div className="print-report-line"><span>Non-attendance</span><strong>{attendance.nonAttendance}</strong></div>
            </section>
          </div>

          {attendance.records.length > 0 && (
            <section className="print-report-section print-attendance-details">
              <h2>Attendance Details</h2>
              <table>
                <thead>
                  <tr><th>Date</th><th>Meeting</th><th>Member</th><th>Status</th></tr>
                </thead>
                <tbody>
                  {attendance.records.map((record, index) => (
                    <tr key={`${record.meetingId}-${record.memberId}-${index}`}>
                      <td>{formatDate(record.meetingDate)}</td>
                      <td>{record.meetingTitle || 'Group meeting'}</td>
                      <td>{record.memberName}</td>
                      <td>{record.present ? 'Attendance' : 'Non-attendance'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </section>
          )}

          <footer className="print-report-footer">VICOBA Manager · Financial records</footer>
        </article>
      )}
    </div>
  );
}
