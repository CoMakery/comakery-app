export function toSnakeCase(string) {
  return string.replace(/([A-Z])/g, '_$1').toLowerCase()
}
