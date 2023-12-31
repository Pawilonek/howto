#!/bin/bash

#
# +----------
# | Configuration
# +----------
# 
# Load configuration from .env file and initialize missing variables
#

scriptPath="$(dirname "$(realpath "$0")")"
envConfigFile="$scriptPath/.env"
cp -n "$scriptPath/.env.example" "$envConfigFile"
eval "$(cat "$scriptPath/.env")"

if [ -z "$OPENAPI_API_KEY" ]; then
    echo "Missing OpenAI API key in .env configuration"
    echo "You can get one here: https://platform.openai.com/api-keys"
    read -r -p "Please enter your API key: " newApiKey

    # todo: Check if the key is value and only then update the confiog
    sed -i "s/^OPENAPI_API_KEY=.*$/OPENAPI_API_KEY=\"$newApiKey\"/" .env

    echo "Done. Now you can run the command once again to start using it."

    exit 1
fi


#
# +----------
# | Prompt
# +----------
# 
# make sure that the command was run with a prompt
#

prompt=$*
if [ -z "$prompt" ]; then
    scriptName="$(basename "$0")"
    echo "Usage: $scriptName <prompt_text>"

    exit 1
fi


#
# +----------
# | Request
# +----------
# 
# Build, send a request to OpenAI API and validate the response
#

payload=$(printf '{
    "model": "%s",
    "messages": [
        {
            "role": "user",
            "content": "Do not include any explanation. Do not use code blocks for code. Give me a working linux command to %s"
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

curlExitCode=$?
if [ $curlExitCode != 0 ]; then
    echo -e "\033[31mCould not get any response from OpenAI API\033[0m"

    exit 1
fi

errorMessage=$(echo "$response" | jq -r '.error.message')
if [ "$errorMessage" != "null" ] || [ -z "$errorMessage" ]; then
    echo -e "\033[31mError response from OpenAI API:\033[0m $errorMessage"

    exit 1
fi

command=$(echo "$response" | jq -r '.choices[0].message.content')
if [ "$command" == "null" ]; then
    echo -e "\033[31mError response from OpenAI API:\033[0m"
    echo "$response" | jq

    exit 1
fi

echo "$command"


#
# +----------
# | Clipboard
# +----------
# 
# Check what command to use and copy the result to clipboard if available
#

clipCommand=""
if command -v clip.exe > /dev/null 2>&1; then
    # Windows (WSL)
    clipCommand="clip.exe"
elif command -v xclip > /dev/null 2>&1; then
    # Linux or OSX
    clipCommand="xclip -selection clipboard"
fi

if [[ -n "$clipCommand" ]]; then
    echo "$command" | $clipCommand
fi

