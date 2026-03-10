with fact_totals as (
    select
        round(sum(coalesce(transaction_amount, 0))::numeric, 2) as fact_transaction_amount,
        round(sum(coalesce(payment_amount, 0))::numeric, 2) as fact_payment_amount,
        round(sum(coalesce(adjustment_amount, 0))::numeric, 2) as fact_adjustment_amount,
        round(sum(coalesce(outstanding_amount, 0))::numeric, 2) as fact_outstanding_amount
    from {{ ref('fct_claim_line') }}
),
mart_totals as (
    select
        round(sum(coalesce(total_transaction_amount, 0))::numeric, 2) as mart_transaction_amount,
        round(sum(coalesce(total_payment_amount, 0))::numeric, 2) as mart_payment_amount,
        round(sum(coalesce(total_adjustment_amount, 0))::numeric, 2) as mart_adjustment_amount,
        round(sum(coalesce(total_outstanding_amount, 0))::numeric, 2) as mart_outstanding_amount
    from {{ ref('mart_claim_cost_summary') }}
)

select *
from fact_totals f
cross join mart_totals m
where f.fact_transaction_amount <> m.mart_transaction_amount
   or f.fact_payment_amount <> m.mart_payment_amount
   or f.fact_adjustment_amount <> m.mart_adjustment_amount
   or f.fact_outstanding_amount <> m.mart_outstanding_amount