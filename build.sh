#!/usr/bin/env bash
# Clone the pinned Pumpkin tag, apply Squash patches in order, and build a
# release binary. Usage: ./build.sh [output-dir]
# The default output dir is <repo>/build/Pumpkin.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
PREFIX=${1:-"$ROOT/build/Pumpkin"}
TAG='0.2.2+26.3-26.60'
SHA='eda69440e6369c5f8a05c3f69fc809c40dab93a6'
UPSTREAM='https://github.com/Pumpkin-MC/Pumpkin.git'

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "build.sh needs $1 on PATH" >&2
    exit 1
  }
}

need git
need cargo

if [[ ! -d $PREFIX/.git ]]; then
  mkdir -p "$(dirname "$PREFIX")"
  git clone --branch "$TAG" --depth 1 "$UPSTREAM" "$PREFIX"
fi

cd "$PREFIX"

if ! git cat-file -e "$SHA^{commit}" 2>/dev/null; then
  git fetch --depth 1 origin "refs/tags/$TAG:refs/tags/$TAG"
fi

# Drop any earlier apply so this is safe to re-run. Keep target/ so rebuilds
# stay incremental.
git checkout --detach "$SHA"
git reset --hard "$SHA"
git clean -fdx --exclude=target --exclude=.cargo

got=$(git rev-parse HEAD)
if [[ $got != "$SHA" ]]; then
  echo "expected $SHA, got $got" >&2
  exit 1
fi

shopt -s nullglob
patches=("$ROOT"/patches/*.patch)
if ((${#patches[@]} == 0)); then
  echo "no patches in $ROOT/patches" >&2
  exit 1
fi

for p in "${patches[@]}"; do
  echo "applying $(basename "$p")"
  git apply --check "$p"
  git apply "$p"
done

echo "patches applied cleanly on $TAG ($SHA)"
cargo build --release -p pumpkin

bin=$PREFIX/target/release/pumpkin
if [[ ! -x $bin ]]; then
  echo "build finished but $bin is missing" >&2
  exit 1
fi
echo "binary: $bin"
