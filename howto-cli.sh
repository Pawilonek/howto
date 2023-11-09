#!/bin/bash

# Load config file
scriptPath="$(dirname "$(realpath "$0")")"
cp -n "$scriptPath/.env.example" "$scriptPath/.env"
source $scriptPath/.env

if [ -z "$OPENAPI_API_KEY" ]; then
    echo "Missing API key in .env configuration" >&2

    exit 1
fi

prompt=$*
if [ -z "$prompt" ]; then
    scriptName=$(basename $0)
    echo "Usage: $scriptName <prompt_text>"

    exit 1
fi

payload=$(printf '{
    "model": "%s",
    "messages": [
        {
            "role": "user",
            "content": "Do not include any explanation. Give me a working linux command to %s"
        }
    ]
}' "$OPENAPI_MODEL" "$prompt")

response=$(curl --request POST \
    --url "https://api.openai.com/v1/chat/completions" \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $OPENAPI_API_KEY" \
    --max-time 10 \
    --silent \
    --data "$payload" \
)

echo "$response" | jq -r '.choices[0].message.content'

