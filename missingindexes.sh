#!/bin/bash

DB_USERNAME=`kubectl get secret platformstorage-postgres -o jsonpath='{.data.user}'|base64 -d`
DB_PASSWORD=`kubectl get secret platformstorage-postgres -o jsonpath='{.data.password}'|base64 -d`

function vs_query() {
  echo $1
  echo $DB_PASSWORD | kubectl exec -i platform-postgresql-0 -- psql -U $DB_USERNAME -d validationserviceimpl -c "$2"
}

echo "Adding missing indexes"

vs_query "i1" "create index idx_calculation_contribution_calculation_id on calculation_contribution(calculation_id);"
vs_query "i2" "create index idx_contribution_fact_contribution_id on contribution_fact(calculation_contribution_id);"
vs_query "i3" "create index idx_total_fact_calculation_id on total_fact(calculation_id);"

echo "Done"
