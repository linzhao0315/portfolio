#!/bin/bash
# Downloads 4 missing Figma screenshots to portfolio-assets/
# Usage: FIGMA_API_KEY=your_token_here bash download-missing.sh
#
# Get your Personal Access Token from:
# Figma → Account Settings → Personal Access Tokens

FILE_KEY="TPmBUB4olYPMF6glEhBGDG"
OUT_DIR="$(dirname "$0")"

if [ -z "$FIGMA_API_KEY" ]; then
  echo "Error: FIGMA_API_KEY is required."
  echo "Usage: FIGMA_API_KEY=your_token bash download-missing.sh"
  exit 1
fi

declare -A NODES=(
  ["ds-color-accessibility.png"]="18829:465"
  ["ds-type-guidelines.png"]="17279:6478"
  ["ds-spacing-guidelines.png"]="17285:6981"
  ["ds-color-guidelines.png"]="18296:7293"
)

for FILENAME in "${!NODES[@]}"; do
  NODE_ID="${NODES[$FILENAME]}"
  ENCODED_ID=$(echo "$NODE_ID" | sed 's/:/%3A/g')
  echo "Fetching export URL for $FILENAME (node $NODE_ID)..."

  RESP=$(curl -s \
    "https://api.figma.com/v1/images/${FILE_KEY}?ids=${ENCODED_ID}&format=png&scale=2" \
    -H "X-Figma-Token: $FIGMA_API_KEY")

  URL=$(echo "$RESP" | python3 -c "import sys,json; d=json.load(sys.stdin); imgs=d.get('images',{}); k=list(imgs.keys())[0] if imgs else ''; print(imgs.get(k,''))")

  if [ -z "$URL" ]; then
    echo "  Error: could not get URL for $FILENAME"
    echo "  Response: $RESP"
  else
    echo "  Downloading $URL..."
    curl -sL "$URL" -o "${OUT_DIR}/${FILENAME}"
    echo "  Saved: ${OUT_DIR}/${FILENAME}"
  fi
done

echo "Done."
