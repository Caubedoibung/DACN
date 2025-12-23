/**
 * Date helper utilities for Vietnam timezone (UTC+7)
 * Ensures consistent date handling across the application
 */

/**
 * Get current date in Vietnam timezone (UTC+7) in YYYY-MM-DD format
 * This should be used instead of new Date().toISOString().split('T')[0]
 * @returns {string} Date string in YYYY-MM-DD format (Vietnam timezone)
 */
function getVietnamDate() {
  return new Date().toLocaleDateString('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh' });
}

/**
 * Get Vietnam date for a specific date object
 * @param {Date} date - Date object to convert
 * @returns {string} Date string in YYYY-MM-DD format (Vietnam timezone)
 */
function toVietnamDate(date) {
  if (!date) return getVietnamDate();
  return new Date(date).toLocaleDateString('sv-SE', { timeZone: 'Asia/Ho_Chi_Minh' });
}

/**
 * SQL query fragment to get current date in Vietnam timezone
 * Use this in PostgreSQL queries instead of CURRENT_DATE
 * @returns {string} SQL fragment
 */
function vietnamDateSQL() {
  return "(CURRENT_TIMESTAMP AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date";
}

/**
 * SQL query fragment to convert a timestamp column to Vietnam timezone date
 * @param {string} columnName - Name of the timestamp column
 * @returns {string} SQL fragment
 */
function toVietnamDateSQL(columnName) {
  return `(${columnName} AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')::date`;
}

/**
 * SQL query fragment to convert a timestamp column to Vietnam timezone datetime
 * @param {string} columnName - Name of the timestamp column
 * @returns {string} SQL fragment
 */
function toVietnamTimestampSQL(columnName) {
  return `(${columnName} AT TIME ZONE 'UTC' AT TIME ZONE 'Asia/Ho_Chi_Minh')`;
}

module.exports = {
  getVietnamDate,
  toVietnamDate,
  vietnamDateSQL,
  toVietnamDateSQL,
  toVietnamTimestampSQL
};
