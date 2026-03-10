{{ config(materialized='table') }}

with claim_rollup as (

    select
        service_month,
        place_of_service,
        procedure_code,
        claim_type,
        count(*) as claim_line_count,
        count(distinct claim_id) as distinct_claim_count,
        count(distinct patient_id) as unique_patient_count,
        count(distinct provider_id) as unique_provider_count,
        sum(coalesce(unit_count, 0)) as total_units,
        sum(coalesce(transaction_amount, 0)) as total_transaction_amount,
        sum(coalesce(payment_amount, 0)) as total_payment_amount,
        sum(coalesce(adjustment_amount, 0)) as total_adjustment_amount,
        sum(coalesce(transfer_amount, 0)) as total_transfer_amount,
        sum(coalesce(outstanding_amount, 0)) as total_outstanding_amount,
        sum(coalesce(resolved_amount, 0)) as total_resolved_amount,
        sum(coalesce(unresolved_amount, 0)) as total_unresolved_amount
    from {{ ref('fct_claim_line') }}
    group by 1, 2, 3, 4

),

final as (

    select
        md5(concat_ws(
            '||',
            claim_rollup.service_month::text,
            claim_rollup.place_of_service,
            claim_rollup.procedure_code,
            claim_rollup.claim_type
        )) as claim_cost_summary_sk,
        claim_rollup.service_month,
        claim_rollup.place_of_service,
        claim_rollup.procedure_code,
        claim_rollup.claim_type,
        claim_rollup.claim_line_count,
        claim_rollup.distinct_claim_count,
        claim_rollup.unique_patient_count,
        claim_rollup.unique_provider_count,
        claim_rollup.total_units,
        claim_rollup.total_transaction_amount,
        claim_rollup.total_payment_amount,
        claim_rollup.total_adjustment_amount,
        claim_rollup.total_transfer_amount,
        claim_rollup.total_outstanding_amount,
        claim_rollup.total_resolved_amount,
        claim_rollup.total_unresolved_amount
    from claim_rollup

)

select * from final