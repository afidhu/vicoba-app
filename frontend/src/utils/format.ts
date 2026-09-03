export function formatCurrency(value: string | number | undefined | null): string {
  const num = Number(value ?? 0);
  return new Intl.NumberFormat('en-TZ', {
    style: 'currency',
    currency: 'TZS',
    maximumFractionDigits: 0,
  }).format(num);
}

export function formatDate(value: string | undefined | null): string {
  if (!value) return '-';
  return new Date(value).toLocaleDateString('en-GB', {
    day: '2-digit',
    month: 'short',
    year: 'numeric',
  });
}

export function toDateInputValue(value: string | Date = new Date()): string {
  const d = new Date(value);
  return d.toISOString().slice(0, 10);
}
