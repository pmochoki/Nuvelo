import { formatNumber, formatPrice } from "../utils/format.js";
import { tf } from "./i18n.js";

/**
 * @deprecated use formatNumber from "../utils/format.js"
 */
export const formatInteger = formatNumber;

/**
 * @deprecated use formatPrice from "../utils/format.js"
 */
export function formatHufPrice(amount) {
  return formatPrice(amount, "HUF");
}

export { formatMoneyAmount, formatPrice, formatNumber } from "../utils/format.js";

/**
 * Like tf() but formats numeric `{n}` (and optional extra vars) with formatNumber.
 * @param {string} key
 * @param {number|string} numVal — value for `{n}`
 * @param {Record<string, string | number>} [extra]
 */
export function tfn(key, numVal, extra = {}) {
  const num = Number(numVal);
  const n =
    numVal !== null &&
    numVal !== undefined &&
    numVal !== "" &&
    Number.isFinite(num)
      ? formatNumber(Math.round(num))
      : String(numVal ?? "");
  return tf(key, { ...extra, n });
}
