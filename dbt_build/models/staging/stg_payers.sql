{{ config(materialized='view') }}

select
    "Id"::text as payer_id,
    "NAME"::text as payer_name,
    "OWNERSHIP"::text as ownership_type,
    "ADDRESS"::text as address,
    "CITY"::text as city,
    "STATE_HEADQUARTERED"::text as state_headquartered,
    "ZIP"::text as zip_code,
    "PHONE"::text as phone,
    nullif("AMOUNT_COVERED", '')::numeric as amount_covered,
    nullif("AMOUNT_UNCOVERED", '')::numeric as amount_uncovered,
    nullif("REVENUE", '')::numeric as revenue,
    nullif("COVERED_ENCOUNTERS", '')::int as covered_encounters,
    nullif("UNCOVERED_ENCOUNTERS", '')::int as uncovered_encounters,
    nullif("COVERED_MEDICATIONS", '')::int as covered_medications,
    nullif("UNCOVERED_MEDICATIONS", '')::int as uncovered_medications,
    nullif("COVERED_PROCEDURES", '')::int as covered_procedures,
    nullif("UNCOVERED_PROCEDURES", '')::int as uncovered_procedures,
    nullif("COVERED_IMMUNIZATIONS", '')::int as covered_immunizations,
    nullif("UNCOVERED_IMMUNIZATIONS", '')::int as uncovered_immunizations,
    nullif("UNIQUE_CUSTOMERS", '')::int as unique_customers,
    nullif("QOLS_AVG", '')::numeric as qols_avg,
    nullif("MEMBER_MONTHS", '')::int as member_months
from {{ source('synthea', 'payers') }}