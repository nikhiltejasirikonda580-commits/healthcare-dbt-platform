import csv
import os
from pathlib import Path

import psycopg2

DATA_DIR = Path("data/synthea/csv")

TABLES = [
    "patients",
    "providers",
    "organizations",
    "payers",
    "payer_transitions",
    "encounters",
    "conditions",
    "medications",
    "observations",
    "immunizations",
    "devices",
    "supplies",
    "allergies",
    "careplans",
    "claims_transactions",
]

conn = psycopg2.connect(
    host="localhost",
    port=5432,
    dbname="healthcare",
    user="dbt",
    password="dbt",
)
conn.autocommit = True


def quote_ident(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


with conn.cursor() as cur:
    cur.execute("create schema if not exists raw;")

    for table in TABLES:
        csv_path = DATA_DIR / f"{table}.csv"
        if not csv_path.exists():
            raise FileNotFoundError(f"Missing expected file: {csv_path}")

        with csv_path.open("r", newline="", encoding="utf-8") as f:
            reader = csv.reader(f)
            headers = next(reader)

        column_defs = ", ".join(f'{quote_ident(col)} text' for col in headers)

        cur.execute(f'drop table if exists raw.{quote_ident(table)} cascade;')
        cur.execute(f'create table raw.{quote_ident(table)} ({column_defs});')

        with csv_path.open("r", encoding="utf-8") as f:
            cur.copy_expert(
                f"""
                copy raw.{quote_ident(table)}
                from stdin
                with csv header quote '"'
                """,
                f,
            )

conn.close()
print("Loaded raw CSV data into Postgres.")