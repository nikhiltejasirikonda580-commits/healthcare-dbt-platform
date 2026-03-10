#!/usr/bin/env bash
set -euo pipefail

DB_CONTAINER="hdbt_postgres"
DB="healthcare"
USER="dbt"

CSV_DIR="data/synthea/csv"

# load each CSV into raw.<filename_without_ext>
for f in "$CSV_DIR"/*.csv; do
  base="$(basename "$f" .csv)"
  table="raw.${base}"

  echo "Loading $f -> $table"

  # Create table with ALL TEXT columns based on header row (raw landing strategy)
  header=$(head -n 1 "$f")
  cols=$(echo "$header" | awk -F',' '{
    for (i=1; i<=NF; i++) {
      gsub(/"/,"",$i);
      printf "\"%s\" text%s", $i, (i<NF?",":"");
    }
  }')

  docker exec -i "$DB_CONTAINER" psql -U "$USER" -d "$DB" <<SQL
drop table if exists ${table};
create table ${table} (${cols});
SQL

  # Copy data (skip header)
  docker exec -i "$DB_CONTAINER" psql -U "$USER" -d "$DB" \
    -c "\copy ${table} from STDIN with (format csv, header true, quote '\"') " < "$f"
done

echo "Done. Loaded Synthea CSVs into raw schema."