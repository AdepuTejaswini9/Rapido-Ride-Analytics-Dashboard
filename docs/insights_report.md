# Insights Report — Rapido Ride Analytics Dashboard

Analysis period: July 1–31, 2025 · 30,000 rides · 8,676 customers · 900 drivers · 5 zones

Each insight below follows: **Finding → Business Impact → Recommendation.**

---

## 1. Customer-side cancellations outweigh driver-side — the bigger lever is customer-facing

**Finding:** Of all cancelled rides, 59.4% were cancelled by the customer, versus 40.6% cancelled by the driver.

**Business Impact:** Overall cancellation rate is 11.86%, costing an estimated ₹7,50,100 in lost/quoted revenue for the month. Because customer-side cancellations are the larger share, driver-supply initiatives (surge incentives, more drivers online) would only address ~41% of the problem at best.

**Recommendation:** Investigate *why* customers cancel before committing to driver-supply fixes — likely candidates include long wait times (worth cross-referencing against `V_TAT`), price sensitivity at booking, or better alternatives being available. A short in-app cancellation-reason prompt at the point of customer cancellation would directly close this data gap for future analysis.

---

## 2. Bike dominates volume, but revenue scales proportionally — no under-monetized vehicle type

**Finding:** Bike accounts for 21,001 of 30,000 rides (70%) versus Auto's 8,999 (30%). Revenue splits almost identically (₹29.5L Bike vs ₹12.4L Auto), meaning average fare per ride is consistent across both vehicle types.

**Business Impact:** There's no evidence that either vehicle type is being systematically under-priced or over-priced relative to the other — this rules out "shift demand to the higher-margin vehicle type" as a lever, since neither is meaningfully higher-margin per ride.

**Recommendation:** Growth strategy should focus on *volume*, not vehicle-type mix-shifting. Since Bike already dominates demand, marketing/availability efforts aimed at growing Auto ridership would need a different value proposition (comfort, capacity) rather than a revenue-per-ride argument.

---

## 3. Retention is genuinely strong — 87.6% of customers are repeat riders

**Finding:** Customer segmentation shows 12.4% First-time, 62.5% Return (2-4 rides), and 25.1% Regular (5+ rides) customers. Average rides per customer is 3.46.

**Business Impact:** This is a healthy retention profile — the platform is not reliant on constant new-customer acquisition to sustain volume. A quarter of the customer base already rides frequently enough to be a "Regular" segment.

**Recommendation:** Given retention is already strong, marketing spend is likely better allocated toward converting the 12.4% First-time segment into Return riders (e.g., a second-ride incentive) than toward broad top-of-funnel acquisition, which is comparatively less differentiated.

---

## 4. Delhi is the top pickup zone; Hyderabad is the top drop zone — a net-inbound pattern

**Finding:** Delhi leads in pickups; Hyderabad leads in drop-offs, despite all 5 zones having broadly similar total ride volumes (4,872–5,006 rides each).

**Business Impact:** A zone that receives more drop-offs than pickups may end up with excess idle drivers there and a shortage back at the originating zones — a potential driver-repositioning inefficiency, though this dataset doesn't include driver idle-time data to confirm it directly.

**Recommendation:** Worth validating with driver-idle-time or driver-location data (not available in this dataset) before acting — but if the pattern holds, incentivizing return-trip pickups from Hyderabad could reduce driver deadheading.

---

## 5. Driver ratings cluster tightly; very few rides earn a perfect 5.0

**Finding:** Driver ratings are fairly evenly distributed from 3.0 to 4.7 (roughly 2,000–3,000 rides per 0.2-point bucket), with a sharp drop to under 1,000 rides in the 4.7–5.0 bucket.

**Business Impact:** The near-absence of 5.0 ratings could reflect either genuinely inconsistent service quality, or a rating culture where customers rarely give the maximum score — these have very different implications, and this dataset can't distinguish between them.

**Recommendation:** Flag for further investigation with qualitative data (customer feedback text, if collected) before treating this as a driver-quality issue — the pattern alone is not conclusive.

---

## Limitations acknowledged in this analysis

- Single month of data — no seasonal or month-over-month trend claims are made
- `booking_value` does not correlate with `ride_distance` (r ≈ 0.006) — fare-related findings avoid implying a distance-based pricing relationship that isn't present in the data
- Zone-level analysis is limited to 5 broad zones, not granular routes
