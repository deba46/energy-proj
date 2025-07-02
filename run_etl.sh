#!/bin/bash
# Notebook Parameters for monthy and daily ingests
HOURS=24
DAYS=30
#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DAILY_NOTEBOOK="$SCRIPT_DIR/notebooks/daily_ingest.ipynb"
MONTHLY_NOTEBOOK="$SCRIPT_DIR/notebooks/monthly_ingest.ipynb"
BI_NOTEBOOK="$SCRIPT_DIR/notebooks/bi_analytics.ipynb"
#DQ_NOTEBOOK="$SCRIPT_DIR/notebooks/data_quality.ipynb"

# Run daily ingestion notebook, it takes daily data from prev 24 hr 
# E.g set it as cron job to run everyday at 8 am : 0 8 * * * /run_etl.sh
papermill "$DAILY_NOTEBOOK" "$SCRIPT_DIR/output/out_daily_$(date +%F).ipynb" \
            -p hours "$HOURS"
if [ $? -ne 0 ]; then
  echo "daily_ingest failed, aborting."
  exit 1
fi
# Run monthly notebook only on the 1st of the month
if [ "$(date +%d)" -eq 1 ]; then
  papermill "$MONTHLY_NOTEBOOK" "$SCRIPT_DIR/output/out_monthly_$(date +%F).ipynb" \
         -p days "$DAYS"
fi
if [ $? -ne 0 ]; then
  echo "monthly_ingest failed, aborting."
  exit 1
fi

# Run BI and SQL queries
papermill "$BI_NOTEBOOK" "$SCRIPT_DIR/output/out_BI_$(date +%F).ipynb" 
           
# RUN DQ -> DQ step called from daily_ingest notebook
# papermill "$DQ_NOTEBOOK" "$SCRIPT_DIR/output/out_DQ_$(date +%F).ipynb" 
           
