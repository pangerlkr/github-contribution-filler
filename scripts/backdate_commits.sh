#!/bin/bash

# Backdate Commits Script with Custom Date Range
# This script creates commits for every day from a custom start date to end date
# to fill in the GitHub contribution graph

# WARNING: This is for educational/personal purposes only
# Artificially inflating GitHub contributions is not recommended

# Usage: ./backdate_commits.sh [START_DATE] [END_DATE]
# Date format: YYYY-MM-DD
# Example: ./backdate_commits.sh 2025-01-01 2025-12-31

# Function to validate date format
validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    # Additional validation using date command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -j -f "%Y-%m-%d" "$date" "+%Y-%m-%d" &>/dev/null
    else
        date -d "$date" "+%Y-%m-%d" &>/dev/null
    fi
    return $?
}

# Parse command-line arguments or use defaults
if [ $# -eq 0 ]; then
    # No arguments provided, use default range
    START_DATE="2025-06-01"
    END_DATE="2026-07-20"
    echo "No date range specified. Using default:"
elif [ $# -eq 2 ]; then
    START_DATE="$1"
    END_DATE="$2"
    
    # Validate dates
    if ! validate_date "$START_DATE"; then
        echo "Error: Invalid START_DATE format. Use YYYY-MM-DD"
        echo "Example: ./backdate_commits.sh 2025-01-01 2025-12-31"
        exit 1
    fi
    
    if ! validate_date "$END_DATE"; then
        echo "Error: Invalid END_DATE format. Use YYYY-MM-DD"
        echo "Example: ./backdate_commits.sh 2025-01-01 2025-12-31"
        exit 1
    fi
else
    echo "Usage: ./backdate_commits.sh [START_DATE] [END_DATE]"
    echo "Date format: YYYY-MM-DD"
    echo "Example: ./backdate_commits.sh 2025-01-01 2025-12-31"
    echo ""
    echo "Or run without arguments to use default range (2025-06-01 to 2026-07-20)"
    exit 1
fi

echo "===" GitHub Contribution Backfill Script ==="
echo "Start Date: $START_DATE"
echo "End Date: $END_DATE"
echo ""
echo "This will create commits for every day in the specified range."
echo "Each day will have 1-460 random commits with randomized timestamps."
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Create logs directory if it doesn't exist
mkdir -p daily-logs

# Convert dates to seconds since epoch
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    START_SECONDS=$(date -j -f "%Y-%m-%d" "$START_DATE" "+%s")
    END_SECONDS=$(date -j -f "%Y-%m-%d" "$END_DATE" "+%s")
else
    # Linux
    START_SECONDS=$(date -d "$START_DATE" "+%s")
    END_SECONDS=$(date -d "$END_DATE" "+%s")
fi

# Calculate total days
TOTAL_DAYS=$(( (END_SECONDS - START_SECONDS) / 86400 + 1 ))

echo ""
echo "Total days to backfill: $TOTAL_DAYS"
echo "Starting backfill process..."
echo ""

# Counter for progress
COUNTER=0
CURRENT_SECONDS=$START_SECONDS

# Loop through each day
while [ $CURRENT_SECONDS -le $END_SECONDS ]; do
    # Get current date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CURRENT_DATE=$(date -j -f "%s" "$CURRENT_SECONDS" "+%Y-%m-%d")
    else
        CURRENT_DATE=$(date -d "@$CURRENT_SECONDS" "+%Y-%m-%d")
    fi
    
    # Random number of commits per day (1-460)
    NUM_COMMITS=$((RANDOM % 460 + 1))
    
    # Create log file for this day
    LOG_FILE="daily-logs/$CURRENT_DATE.md"
    echo "# Daily Learning Log - $CURRENT_DATE" > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "## Activity Summary" >> "$LOG_FILE"
    echo "- Number of commits: $NUM_COMMITS" >> "$LOG_FILE"
    echo "- Automated backfill entry" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "## Notes" >> "$LOG_FILE"
    echo "This entry was created as part of the GitHub contribution backfill process." >> "$LOG_FILE"
    
    # Create multiple commits for this day
    for ((COMMIT_NUM=1; COMMIT_NUM<=NUM_COMMITS; COMMIT_NUM++)); do
        # Randomize the hour and minute for each commit
        HOUR=$((RANDOM % 24))
        MINUTE=$((RANDOM % 60))
        SECOND=$((RANDOM % 60))
        TIME_STR=$(printf "%02d:%02d:%02d" $HOUR $MINUTE $SECOND)
        
        # Add and commit with the backdated timestamp
        git add "$LOG_FILE"
        
        # Set both author and committer dates to the backdated timestamp
        GIT_AUTHOR_DATE="$CURRENT_DATE $TIME_STR" \
        GIT_COMMITTER_DATE="$CURRENT_DATE $TIME_STR" \
        git commit -m "Daily learning log for $CURRENT_DATE - Entry $COMMIT_NUM/$NUM_COMMITS" >/dev/null 2>&1
    done
    
    # Progress indicator
    COUNTER=$((COUNTER + 1))
    if [ $((COUNTER % 10)) -eq 0 ]; then
        PERCENT=$((COUNTER * 100 / TOTAL_DAYS))
        echo "Progress: $COUNTER/$TOTAL_DAYS days ($PERCENT%) – Current date: $CURRENT_DATE – $NUM_COMMITS commits created"
    fi
    
    # Move to next day
    CURRENT_SECONDS=$((CURRENT_SECONDS + 86400))
done

echo ""
echo "✓ Backfill complete! Created commits for $TOTAL_DAYS days."
echo "✓ Remember: Genuine contributions are always better than backdated ones!"
echo ""
echo "Next steps:"
echo "1. Review the changes: git log --oneline"
echo "2. Push to GitHub: git push origin main"
echo "3. Check your contribution graph on GitHub"
