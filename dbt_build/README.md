![dbt](https://img.shields.io/badge/dbt-Analytics%20Engineering-orange)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Database-blue)
![CI](https://img.shields.io/badge/CI-GitHub%20Actions-black)
![Docs](https://img.shields.io/badge/docs-GitHub%20Pages-green)

# Healthcare dbt Analytics Platform

A production-style **analytics engineering project** built with **dbt + PostgreSQL + Docker** using **synthetic healthcare data (Synthea)**.

This project demonstrates how to design a modern healthcare analytics warehouse using layered dbt models, Slowly Changing Dimensions (SCD Type 2), incremental fact tables, automated data quality testing, and CI/CD pipelines.

---

## Tech Stack

- dbt
- PostgreSQL
- Docker
- GitHub Actions (CI/CD)
- GitHub Pages (dbt docs hosting)
- Synthea synthetic healthcare dataset

---

## Architecture

---



                ┌──────────────────────┐
                │   docker network     │
                └─────────┬────────────┘
                          │
        ┌─────────────────┴─────────────────┐
        │                                   │
┌───────────────┐                  ┌────────────────┐
│  postgres     │                  │   dbt container │
│  raw schema   │◄──── models ─────│  dbt build     │
│  stg schema   │                  │  dbt test      │
│  core schema  │                  │  dbt docs      │
│  mart schema  │                  └────────────────┘
└───────────────┘


# Project Structure


healthcare-dbt-platform
│
├── Data Source
│   └── Synthea CSV Files
│       └── Loaded into PostgreSQL (raw schema)
│
├── Local Runtime
│   ├── Docker
│   │   ├── PostgreSQL
│   │   ├── dbt Container
│   │   └── Adminer
│
├── dbt Project (dbt_build/)
│   ├── sources
│   │   └── raw healthcare data
│   │
│   ├── staging
│   │   └── cleaning, renaming, typing, standardization
│   │
│   ├── core
│   │   ├── dimensions
│   │   ├── fact tables
│   │   └── bridge tables
│   │
│   ├── marts
│   │   ├── Patient 360
│   │   ├── Utilization
│   │   ├── Condition Burden
│   │   ├── Provider Performance
│   │   └── Claim Cost Summary
│   │
│   ├── macros
│   ├── seeds
│   ├── tests
│   └── analyses
│
├── Snapshots
│   └── SCD Type 2 history tracking
│       ├── patients
│       ├── providers
│       ├── payers
│       └── organizations
│
├── Quality & Validation
│   ├── schema tests
│   ├── custom generic tests
│   └── singular business-rule tests
│
├── CI/CD
│   └── GitHub Actions
│       ├── dbt build
│       ├── dbt test
│       ├── dbt snapshot
│       └── dbt docs generate
│
└── Documentation
    └── GitHub Pages
        └── dbt docs + lineage graph


## Data Model

### Dimensions
- dim_patient
- dim_provider
- dim_organization
- dim_payer

### Fact Tables
- fct_encounter
- fct_condition
- fct_medication
- fct_claim_line

### Bridge Tables
- bridge_patient_payer_coverage

### Analytics Marts
- mart_patient_360
- mart_utilization_monthly
- mart_condition_burden
- mart_provider_performance
- mart_claim_cost_summary

---

## Advanced dbt Features

### Incremental Models
Large fact tables are built using incremental strategies for better performance.

### Snapshots (SCD Type 2)
Historical changes are tracked for:
- patients
- providers
- payers
- organizations

Snapshots maintain history using dbt-managed columns such as:
- dbt_valid_from
- dbt_valid_to

---

## Data Quality Testing

The project includes over **100 automated tests**, including:

- not_null
- unique
- relationships
- custom generic tests
- business rule validation tests

Examples include:
- encounter cost reconciliation
- date range validation
- non-negative financial values
- mart-to-fact consistency checks

---

## CI/CD

GitHub Actions automatically runs:

- dbt deps
- dbt build
- dbt test
- dbt docs generate

on every push and pull request.

Documentation is automatically deployed via **GitHub Pages**.

---

## Running the Project Locally

Start the environment:

docker compose -f docker/docker-compose.yml up -d --build

Run dbt models:

docker exec -it hdbt_dbt bash -lc "cd /workspace/dbt_build && dbt build"

Run snapshots:

docker exec -it hdbt_dbt bash -lc "cd /workspace/dbt_build && dbt snapshot"

Run tests:

docker exec -it hdbt_dbt bash -lc "cd /workspace/dbt_build && dbt test"

---

## dbt Documentation

Interactive lineage and model documentation will be available via GitHub Pages once deployed.

https://nikhiltejasirikonda580-commits.github.io/healthcare-dbt-platform/#!/overview

---

## Dataset

Synthetic healthcare data generated using **Synthea**.

https://synthetichealth.github.io/synthea/

---

## Why This Project

This project demonstrates **production-style analytics engineering practices**, including:

- layered dbt modeling
- warehouse data modeling
- automated data quality testing
- historical tracking with SCD Type 2
- CI/CD pipelines for analytics workflows
- documentation and lineage visibility

---

## Future Improvements

Potential enhancements:

- Source freshness monitoring
- dbt exposures for BI dashboards
- semantic layer metrics
- healthcare quality metrics marts
- incremental snapshot strategies