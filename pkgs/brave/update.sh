#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq gnused nix
# Bump pkgs/brave/default.nix to the latest upstream Brave release.
set -euo pipefail

dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
file="$dir/default.nix"

latest="$(curl -fsSL ${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} \
  https://api.github.com/repos/brave/brave-browser/releases/latest | jq -r .tag_name | sed 's/^v//')"
current="$(sed -n 's/^  version = "\(.*\)";$/\1/p' "$file")"

if [ "$latest" = "$current" ]; then
  echo "brave is already at $current"
  exit 0
fi

prefetch() {
  nix-hash --to-sri --type sha256 "$(nix-prefetch-url --type sha256 \
    "https://github.com/brave/brave-browser/releases/download/v${latest}/brave-browser_${latest}_$1.deb")"
}
amd64="$(prefetch amd64)"
arm64="$(prefetch arm64)"

# Each hash line follows its arch's url line, so swap the hash on the line
# after the matching url.
sed -i \
  -e "s/^  version = \".*\";$/  version = \"$latest\";/" \
  -e "/_amd64\.deb\";$/{n;s|hash = \".*\";|hash = \"$amd64\";|}" \
  -e "/_arm64\.deb\";$/{n;s|hash = \".*\";|hash = \"$arm64\";|}" \
  "$file"

echo "brave: $current -> $latest"
