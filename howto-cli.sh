#!/bin/bash

API_ENDPOINT="https://api.openai.com/v1/chat/completions"
API_KEY="<api-key>"

prompt=$*

if [ -z "$prompt" ]; then
  echo "Usage: $0 <prompt_text>"

  exit 1
fi


payload=$(printf '{
    "model": "gpt-4",
    "messages": [
        {
            "role": "user",
            "content": "Do not include any explanation. Give me a working linux command to %s"
        }
    ]
}' "$prompt")

response=$(curl --request POST \
    --url $API_ENDPOINT \
    --header "Content-Type: application/json" \
    --header "Authorization: Bearer $API_KEY" \
    --max-time 10 \
    --silent \
    --data "$payload" \
)

echo "$response" | jq -r '.choices[0].message.content'

