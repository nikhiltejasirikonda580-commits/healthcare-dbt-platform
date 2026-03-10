{{
    config(
        materialized='incremental',
        unique_key='claim_transaction_id'
    )
}}

with base as (

    select *
    from {{ ref('stg_claims_transactions') }}

    {% if is_incremental() %}
      where service_from_date >= (
          select coalesce(max(service_from_date), '1900-01-01'::date)
          from {{ this }}
      )
    {% endif %}

),

final as (

    select
        claim_transaction_id,
        claim_id,
        charge_id,
        patient_id,
        provider_id,
        supervising_provider_id,
        claim_type,
        transaction_method,
        service_from_date,
        service_to_date,
        service_month,
        place_of_service,
        procedure_code,
        modifier_1,
        modifier_2,
        diagnosis_ref_1,
        diagnosis_ref_2,
        diagnosis_ref_3,
        diagnosis_ref_4,
        department_id,
        appointment_id,
        patient_insurance_id,
        fee_schedule_id,
        transfer_out_id,
        transfer_type,
        line_note,
        notes,
        unit_count,
        unit_amount,
        transaction_amount,
        payment_amount,
        adjustment_amount,
        transfer_amount,
        outstanding_amount,
        is_paid_claim_line,
        is_outstanding_claim_line,
        coalesce(payment_amount, 0) + coalesce(adjustment_amount, 0) + coalesce(transfer_amount, 0) as resolved_amount,
        coalesce(transaction_amount, 0) - (
            coalesce(payment_amount, 0)
            + coalesce(adjustment_amount, 0)
            + coalesce(transfer_amount, 0)
        ) as unresolved_amount
    from base

)

select * from final