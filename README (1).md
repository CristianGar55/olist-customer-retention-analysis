# Olist Customer Retention Analysis

A SQL and Tableau deep-dive into why most customers on a Brazilian e-commerce marketplace never come back, and what that means for the business.

**[View the interactive retention heatmap →](https://public.tableau.com/app/profile/cristian.garcia3939/viz/OlistCustomerRetentionAnalysis/RetentionHeatmap)**

## The question

Most e-commerce dashboards focus on revenue and top products. This project looks at something less obvious but more important long-term: do customers actually come back? And if not, is there anything in the data (delivery speed, review scores, timing) that hints at why.

## The data

The [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle. About 99,000 real orders spread across five separate tables: customers, orders, order items, payments, and reviews. Rather than working off a single pre-cleaned CSV, the database was built from scratch. Schema designed, each table loaded from raw CSVs into MySQL, then joined across tables to answer the questions below. That process alone covers more relational-data ground than a single-table project would.

## What the data shows

**Only about 3% of customers ever placed a second order.** Out of roughly 99,000 customers, just 2,997 came back. When they did return, it took an average of 80 days.

That number is surprising at first, but it tracks for a marketplace like Olist. Most sellers ship one-off products, so there's no built-in reason for a customer to return quickly. Still, an 80-day average return window suggests there's a real opportunity to catch people before they drift away, such as a follow-up email or discount around the 60-70 day mark, before that window closes.

**Delivery speed and review scores showed a small but real connection to repeat behavior.** Customers who came back had orders delivered slightly faster than promised (11.7 days ahead of estimate, versus 10.9 for one-time buyers) and rated their experience a bit higher (4.12 vs. 4.08 average review score). It's not a huge gap, and it's not meant to be oversold here. But it's consistent in the same direction on both metrics, which is enough to say delivery experience is *a* factor, even if it's not *the* factor.

**The cohort heatmap tells the clearest story.** Customers were grouped by the month of their first purchase, then tracked month by month to see how many were still active. Almost every cohort follows the same pattern: a steep drop after month one, then a long tail of a handful of loyal repeat customers. One cohort stands out. Customers who first purchased in July 2018 returned at a noticeably higher rate than any other month, flagged directly on the dashboard as worth a closer look. Was there a promotion running that month? A different product mix? That's the kind of question a real retention team would want answered next.

## Why it matters

A 3% repeat rate means this business is almost entirely dependent on acquiring new customers, not retaining old ones. That's a fragile growth model since every dollar spent on marketing has to work harder if customers rarely come back on their own. The findings here point to two concrete next steps: test a re-engagement campaign timed to the 60-70 day window, and dig into what made that July 2018 cohort different, since whatever happened there might be repeatable.

## How it was built

- Schema designed and five raw CSVs loaded into MySQL
- SQL written using CTEs and window functions (`ROW_NUMBER()`, `TIMESTAMPDIFF`) to build the cohort logic and calculate purchase gaps
- Joins across customers, orders, and reviews to compare repeat vs. one-time buyers
- Interactive cohort retention heatmap built and published in Tableau Public, with an on-chart annotation calling out the July 2018 outlier

## Files in this repo

- `sql/01_setup_and_import.sql`: database schema and CSV import
- `sql/02_analysis_queries.sql`: the three core queries (cohort retention, time between purchases, and delivery/review comparison)
- `data/`: exported results from each query, used to build the Tableau dashboard

## Next steps

Segmenting retention by product category and region would show whether certain types of purchases drive more repeat behavior. The July 2018 cohort is worth digging into to find out what actually happened that month. And the delivery/review gap deserves a proper significance test, since right now it's reported as a real but modest pattern, not a proven cause.
