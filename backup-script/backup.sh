#!/bin/bash

# Create backup directory if it doesn't exist
mkdir -p /backups

echo "Starting backup at $(date)"

# Set the timestamp for the backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/backups/mysql_backup_$TIMESTAMP.sql.gz"

# Wait for MySQL to be fully available
echo "Waiting for MySQL to be available..."
until mysqladmin ping -h"$MYSQL_HOST" --silent -u"root" -p"$MYSQL_ROOT_PASSWORD"; do
  echo "MySQL is unavailable - waiting 5s"
  sleep 5
done

# Perform the backup
echo "Starting MySQL backup..."
mysqldump --host=$MYSQL_HOST --user=root --password=$MYSQL_ROOT_PASSWORD --all-databases | gzip > $BACKUP_FILE

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $BACKUP_FILE"
  
  # Clean up old backups
  echo "Checking for old backups to clean up..."
  find /backups -name "mysql_backup_*.sql.gz" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
  echo "Removed backups older than $BACKUP_RETENTION_DAYS days"
else
  echo "Backup failed!"
fi

# If we're not running with a schedule, just exit
if [ -z "$BACKUP_SCHEDULE" ]; then
  echo "No schedule set. Exiting after initial backup."
  exit 0
fi

# If we're here, we should set up a periodic backup using a simple loop
echo "Setting up scheduled backups with interval: $BACKUP_SCHEDULE"
echo "Use CTRL+C to stop the backup process"

# Convert cron-like schedule to seconds for sleep
# This is a simplified version that only handles common patterns
if [[ "$BACKUP_SCHEDULE" == "0 0 * * *" ]]; then
  # Daily at midnight
  SLEEP_TIME=$((24*60*60))
  echo "Schedule interpreted as: Daily (every 24 hours)"
elif [[ "$BACKUP_SCHEDULE" =~ 0\ \*/([0-9]+)\ \*\ \*\ \* ]]; then
  # Every X hours
  HOURS="${BASH_REMATCH[1]}"
  SLEEP_TIME=$((HOURS*60*60))
  echo "Schedule interpreted as: Every $HOURS hours"
elif [[ "$BACKUP_SCHEDULE" =~ \*/([0-9]+)\ \*\ \*\ \*\ \* ]]; then
  # Every X minutes
  MINUTES="${BASH_REMATCH[1]}"
  SLEEP_TIME=$((MINUTES*60))
  echo "Schedule interpreted as: Every $MINUTES minutes"
else
  # Default to daily
  SLEEP_TIME=$((24*60*60))
  echo "Schedule format not recognized, defaulting to daily backups"
fi

echo "Starting backup loop with interval of $SLEEP_TIME seconds"

# Infinite loop to perform backups
while true; do
  echo "Next backup scheduled at: $(date -d "+$SLEEP_TIME seconds")"
  sleep $SLEEP_TIME
  
  # Perform the backup again
  TIMESTAMP=$(date +%Y%m%d_%H%M%S)
  BACKUP_FILE="/backups/mysql_backup_$TIMESTAMP.sql.gz"
  
  echo "Starting scheduled backup at $(date)"
  mysqldump --host=$MYSQL_HOST --user=root --password=$MYSQL_ROOT_PASSWORD --all-databases | gzip > $BACKUP_FILE
  
  # Check if backup was successful
  if [ $? -eq 0 ]; then
    echo "Scheduled backup completed successfully: $BACKUP_FILE"
    
    # Clean up old backups
    find /backups -name "mysql_backup_*.sql.gz" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
    echo "Removed backups older than $BACKUP_RETENTION_DAYS days"
  else
    echo "Scheduled backup failed!"
  fi
done