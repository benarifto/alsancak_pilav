/**
 * Format a number as Turkish Lira price string.
 * e.g. formatPrice(150) → "150 TL"
 */
export function formatPrice(value) {
  if (value === null || value === undefined) return '— TL'
  const num = parseFloat(value)
  if (isNaN(num)) return '— TL'
  return num % 1 === 0
    ? `${num.toFixed(0)} TL`
    : `${num.toFixed(2).replace('.', ',')} TL`
}

/**
 * Format a date in Turkish locale.
 * e.g. formatDate('2024-01-15') → "15 Ocak 2024"
 */
export function formatDate(dateStr) {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('tr-TR', {
    day: 'numeric',
    month: 'long',
    year: 'numeric',
  })
}

/**
 * Truncate text to a max length with ellipsis.
 */
export function truncate(text, maxLength = 80) {
  if (!text) return ''
  return text.length > maxLength ? text.slice(0, maxLength).trimEnd() + '…' : text
}
