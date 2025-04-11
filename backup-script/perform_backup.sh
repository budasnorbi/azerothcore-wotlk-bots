#!/bin/bash

# Set the timestamp for the backup filename
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="/backups/mysql_backup_$TIMESTAMP.sql.gz"

# Perform the backup
echo "Starting backup at $(date)"
mysqldump --host=$MYSQL_HOST --user=root --password=$MYSQL_ROOT_PASSWORD --databases acore_auth acore_characters | gzip > $BACKUP_FILE

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "Backup completed successfully: $BACKUP_FILE"
  
  # Clean up old backups
  find /backups -name "mysql_backup_*.sql.gz" -type f -mtime +$BACKUP_RETENTION_DAYS -delete
  echo "Removed backups older than $BACKUP_RETENTION_DAYS days"
else
  echo "Backup failed!"
fi
