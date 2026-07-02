#!/usr/bin/env bash
# Sync skill directories from ~/.cursor/skills into this repository root.
set -eo pipefail

SOURCE="${HOME}/.cursor/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"

report_list() {
  local name=$1
  eval "local items=(\"\${${name}[@]}\")"
  if ((${#items[@]} > 0)); then
    local IFS=', '
    echo "${items[*]}"
  else
    echo "(none)"
  fi
}

is_skill_dir() {
  local dir="$1"
  [[ -d "${dir}" && -f "${dir}/SKILL.md" ]]
}

if [[ ! -d "${SOURCE}" ]]; then
  echo "error: source directory not found: ${SOURCE}" >&2
  exit 1
fi

copied=()
updated=()
removed=()
unchanged=()

shopt -s nullglob
for src in "${SOURCE}"/*/; do
  name="$(basename "${src}")"

  # Skip hidden dirs and non-skill folders.
  [[ "${name}" == .* ]] && continue
  is_skill_dir "${src}" || continue

  dest_dir="${DEST}/${name}"

  if [[ ! -d "${dest_dir}" ]]; then
    copied+=("${name}")
  elif diff -qr \
    --exclude='.DS_Store' \
    --exclude='.git' \
    "${src}" "${dest_dir}" >/dev/null 2>&1; then
    unchanged+=("${name}")
    continue
  else
    updated+=("${name}")
  fi

  mkdir -p "${dest_dir}"
  rsync -a --delete \
    --exclude='.DS_Store' \
    --exclude='.git' \
    "${src}/" "${dest_dir}/"
done

# Remove repo skills that no longer exist locally.
for dest_dir in "${DEST}"/*/; do
  name="$(basename "${dest_dir}")"

  [[ "${name}" == .* ]] && continue
  is_skill_dir "${dest_dir}" || continue
  [[ -d "${SOURCE}/${name}" ]] && continue

  removed+=("${name}")
  rm -rf "${dest_dir}"
done

echo "Sync complete: ${DEST}"
echo "source: ${SOURCE}"
echo ""
echo "added:     $(report_list copied)"
echo "updated:   $(report_list updated)"
echo "unchanged: $(report_list unchanged)"
echo "removed:   $(report_list removed)"
