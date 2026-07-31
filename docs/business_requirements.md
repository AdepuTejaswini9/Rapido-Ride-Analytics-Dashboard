# Business Requirements Document — Rapido Ride Analytics Dashboard

*This document simulates the kind of brief a Data Analyst would typically receive from stakeholders before starting a project — written here to reflect realistic scope-setting practice for a portfolio project.*

## Project Title
Rapido Ride Analytics Dashboard

## Requested By
Operations & Business Analytics function (simulated stakeholder group, for portfolio purposes)

## Background
Rapido-style ride-hailing platforms generate large volumes of transactional data — bookings, cancellations, ratings, payments — but this data is rarely consolidated into a single view that Operations, Revenue, and Driver Relations teams can use for decision-making. This project builds that consolidated view for a representative month of operations.

## Objective
Deliver an analytics solution that answers:
1. What is our current revenue and ride-volume performance?
2. Where and why are we losing rides to cancellation?
3. Which drivers and customers drive the most value, and how are they behaving?
4. Which zones see the highest demand, and are we serving them adequately?

## Scope

**In scope:**
- Bookings, revenue, cancellations, ratings, and location data for July 2025
- Vehicle types: Bike, Auto
- Customer- and driver-level analysis
- SQL-based data validation, Excel pivot analysis, and a Power BI interactive dashboard

**Out of scope:**
- Multi-month or seasonal trend analysis (data covers a single month)
- Driver-side operational data (idle time, GPS tracking, fuel costs)
- Real-time/streaming data — this is a static, point-in-time analysis
- Pricing-model recommendations beyond what current data supports

## Required KPIs
- Total Rides, Completion Rate, Cancellation Rate
- Total Revenue, Average Fare per Ride, Lost Revenue (cancelled/incomplete)
- Repeat Customer Rate, Customer Segmentation (First-time/Return/Regular)
- Driver Utilization (rides per driver), Average Driver/Customer Rating
- Zone-level demand and cancellation rate
- Cancellation attribution (customer-side vs driver-side)

## Deliverables
1. Cleaned, validated dataset (star schema: 1 fact table + 4 dimension tables)
2. SQL query library (schema, validation, business, and advanced analytical queries)
3. Excel workbook with pivot-table analysis and interactive dashboard
4. Power BI interactive dashboard — 6 pages (Home, Overview, Customer, Location, Driver, Cancellations)
5. Data dictionary, source documentation, and written insights report

## Assumptions & Constraints
- Dataset is a public, synthetic dataset (see `data/SOURCE.md`) — not live production data
- Single month of data available; trend analysis limited to day-of-week/day-of-month patterns
- No `city` dimension — all zones are within one operating area

## Timeline
Approx. 6–8 weeks, part-time (see project README for phase-by-phase breakdown)

## Success Criteria
- All KPIs cross-validated between Excel and Power BI (independently computed, matching results)
- Dashboard is fully interactive (slicers, drill-through where applicable, working navigation)
- Findings are supported directly by the data, with known limitations explicitly documented rather than glossed over
