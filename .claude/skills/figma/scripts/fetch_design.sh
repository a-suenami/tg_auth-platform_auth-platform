#!/bin/bash
# Figma Design Fetcher
# Usage: ./fetch_design.sh <file_key> [node_id]

set -e

FILE_KEY="$1"
NODE_ID="$2"

if [ -z "$FIGMA_TOKEN" ]; then
  echo "Error: FIGMA_TOKEN environment variable is not set" >&2
  exit 1
fi

if [ -z "$FILE_KEY" ]; then
  echo "Usage: $0 <file_key> [node_id]" >&2
  echo "" >&2
  echo "Extract from Figma URL:" >&2
  echo "  https://www.figma.com/design/{file_key}/...?node-id={node_id}" >&2
  exit 1
fi

API_BASE="https://api.figma.com/v1"

if [ -z "$NODE_ID" ]; then
  # Fetch entire file
  echo "Fetching file: $FILE_KEY" >&2
  curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
    "$API_BASE/files/$FILE_KEY"
else
  # Fetch specific node
  # Convert node-id format (2-2 -> 2:2)
  NODE_ID_API=$(echo "$NODE_ID" | tr '-' ':')
  echo "Fetching node: $NODE_ID_API from file: $FILE_KEY" >&2
  curl -s -H "X-Figma-Token: $FIGMA_TOKEN" \
    "$API_BASE/files/$FILE_KEY/nodes?ids=$NODE_ID_API"
fi
