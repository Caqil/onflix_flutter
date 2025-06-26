#!/bin/bash

# PocketBase Content Generator Script
# Requires PocketBase CLI or curl for API requests
# Assumes PocketBase server is running and accessible

# Configuration
PB_URL="http://localhost:8090"  # Update with your PocketBase URL
ADMIN_EMAIL="admin@example.com"  # Update with your admin email
ADMIN_PASSWORD="adminpassword"  # Update with your admin password
CONTENT_COUNT=5  # Number of content items to generate

# Function to check for required dependencies
check_dependencies() {
    command -v curl >/dev/null 2>&1 || { echo "Error: curl is required but not installed."; exit 1; }
    command -v jq >/dev/null 2>&1 || { echo "Error: jq is required but not installed."; exit 1; }
}

# Function to get admin auth token
get_auth_token() {
    response=$(curl -s -X POST "$PB_URL/api/admins/auth-with-password" \
        -H "Content-Type: application/json" \
        -d "{\"email\": \"$ADMIN_EMAIL\", \"password\": \"$ADMIN_PASSWORD\"}")
    
    token=$(echo "$response" | jq -r '.token')
    if [ -z "$token" ] || [ "$token" = "null" ]; then
        echo "Error: Failed to authenticate with PocketBase"
        exit 1
    fi
    echo "$token"
}

# Function to generate random string
generate_random_string() {
    length=$1
    cat /dev/urandom | tr -dc 'a-z0-9' | fold -w "$length" | head -n 1
}

# Function to generate random slug
generate_slug() {
    title=$1
    echo "$title" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | sed 's/[^a-z0-9-]//g'
}

# Function to generate random date within last 5 years (cross-platform)
generate_random_date() {
    current_timestamp=$(date +%s)
    five_years_ago=$((current_timestamp - 5 * 365 * 24 * 3600))
    random_timestamp=$((five_years_ago + RANDOM % (current_timestamp - five_years_ago)))

    # Detect OS and use appropriate date command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS/BSD
        date -r "$random_timestamp" -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || {
            echo "Error: Failed to generate date on macOS/BSD"
            exit 1
        }
    else
        # Linux
        date -u -d "@$random_timestamp" +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || {
            echo "Error: Failed to generate date on Linux"
            exit 1
        }
    fi
}

# Sample data arrays
content_types=("movie" "series" "documentary" "anime" "kids")
ratings=("G" "PG" "PG-13" "R" "TV-Y" "TV-Y7" "TV-G" "TV-PG" "TV-14" "TV-MA")
series_status=("ongoing" "completed" "cancelled" "hiatus")

# Check dependencies
check_dependencies

# Get auth token
AUTH_TOKEN=$(get_auth_token)

# Generate content
for ((i=1; i<=CONTENT_COUNT; i++)); do
    # Generate content data
    title="Sample Content $i"
    slug=$(generate_slug "$title")
    identity="content-$(generate_random_string 8)"  # Generate unique identity
    content_type=${content_types[$RANDOM % ${#content_types[@]}]}
    description="Description for $title. This is a sample $content_type content."
    short_description="Short desc for $title"
    status="published"
    release_date=$(generate_random_date)
    duration=$((RANDOM % 7200 + 300))  # 5-120 minutes
    rating=${ratings[$RANDOM % ${#ratings[@]}]}
    imdb_rating=$(awk -v min=1 -v max=10 'BEGIN{srand(); print min+rand()*(max-min)}')
    is_featured=$((RANDOM % 2))
    is_trending=$((RANDOM % 2))
    
    # Create content record
    content_response=$(curl -s -X POST "$PB_URL/api/collections/content/records" \
        -H "Authorization: $AUTH_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"identity\": \"$identity\",
            \"title\": \"$title\",
            \"slug\": \"$slug\",
            \"description\": \"$description\",
            \"shortDescription\": \"$short_description\",
            \"type\": \"$content_type\",
            \"status\": \"$status\",
            \"releaseDate\": \"$release_date\",
            \"duration\": $duration,
            \"rating\": \"$rating\",
            \"imdbRating\": $imdb_rating,
            \"isFeatured\": $is_featured,
            \"isTrending\": $is_trending,
            \"viewCount\": 0,
            \"likesCount\": 0
        }")
    
    content_id=$(echo "$content_response" | jq -r '.id')
    
    if [ -z "$content_id" ] || [ "$content_id" = "null" ]; then
        echo "Error: Failed to create content '$title'. Response: $content_response"
        continue
    fi
    
    echo "Created content: $title (ID: $content_id, Identity: $identity)"
    
    # If content is a series, create series and seasons
    if [ "$content_type" = "series" ]; then
        total_seasons=$((RANDOM % 3 + 1))
        total_episodes=$((total_seasons * (RANDOM % 10 + 5)))
        
        # Create series record
        series_response=$(curl -s -X POST "$PB_URL/api/collections/series/records" \
            -H "Authorization: $AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"content\": \"$content_id\",
                \"totalSeasons\": $total_seasons,
                \"totalEpisodes\": $total_episodes,
                \"status\": \"${series_status[$RANDOM % ${#series_status[@]}]}\",
                \"firstAirDate\": \"$release_date\"
            }")
        
        series_id=$(echo "$series_response" | jq -r '.id')
        
        if [ -z "$series_id" ] || [ "$series_id" = "null" ]; then
            echo "Error: Failed to create series for '$title'. Response: $series_response"
            continue
        fi
        
        echo "Created series: $title (ID: $series_id)"
        
        # Create seasons and episodes
        for ((s=1; s<=total_seasons; s++)); do
            episodes_per_season=$((total_episodes / total_seasons))
            season_title="Season $s"
            
            # Create season record
            season_response=$(curl -s -X POST "$PB_URL/api/collections/seasons/records" \
                -H "Authorization: $AUTH_TOKEN" \
                -H "Content-Type: application/json" \
                -d "{
                    \"series\": \"$series_id\",
                    \"seasonNumber\": $s,
                    \"title\": \"$season_title\",
                    \"episodeCount\": $episodes_per_season
                }")
            
            season_id=$(echo "$season_response" | jq -r '.id')
            
            if [ -z "$season_id" ] || [ "$season_id" = "null" ]; then
                echo "Error: Failed to create season $s for '$title'. Response: $season_response"
                continue
            fi
            
            echo "Created season: $season_title (ID: $season_id)"
            
            # Create episodes
            for ((e=1; e<=episodes_per_season; e++)); do
                episode_title="Episode $e"
                episode_duration=$((RANDOM % 3600 + 600))  # 10-60 minutes
                
                episode_response=$(curl -s -X POST "$PB_URL/api/collections/episodes/records" \
                    -H "Authorization: $AUTH_TOKEN" \
                    -H "Content-Type: application/json" \
                    -d "{
                        \"season\": \"$season_id\",
                        \"episodeNumber\": $e,
                        \"title\": \"$episode_title\",
                        \"description\": \"Episode $e of $title Season $s\",
                        \"duration\": $episode_duration,
                        \"airDate\": \"$release_date\",
                        \"viewCount\": 0
                    }")
                
                episode_id=$(echo "$episode_response" | jq -r '.id')
                if [ -z "$episode_id" ] || [ "$episode_id" = "null" ]; then
                    echo "Error: Failed to create episode $e for season $s of '$title'. Response: $episode_response"
                    continue
                fi
                
                echo "Created episode: $episode_title (Season $s, ID: $episode_id)"
            done
        done
    fi
done

echo "Content generation completed!"