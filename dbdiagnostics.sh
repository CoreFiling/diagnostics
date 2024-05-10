#!/bin/bash

echo "Starting database diagnostics"

DB_USERNAME=`kubectl get secret platformstorage-postgres -o jsonpath='{.data.user}'|base64 -d`
DB_PASSWORD=`kubectl get secret platformstorage-postgres -o jsonpath='{.data.password}'|base64 -d`

function vs_query() {
  echo $1
  echo $DB_PASSWORD | kubectl exec -i platform-postgresql-0 -- psql -U $DB_USERNAME -d validationserviceimpl -c "$2" 2>/dev/null
}

echo "Obtaining statistics from affected database"

for table in calculation calculation_contribution contribution_fact databasechangelog databasechangeloglock filing_version issue message message_cause node total_fact; do
  vs_query "$table count" "select count(*) from $table"
done

vs_query "sizing data" "select table_name, pg_size_pretty(pg_total_relation_size(quote_ident(table_name))), pg_total_relation_size(quote_ident(table_name)) from information_schema.tables where table_schema = 'public' order by 3 desc;"

