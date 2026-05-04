#!/usr/bin/env bash
#
# pharaoh-write installer
#
# Copies commands, agents, and skills into ~/.claude/.
# Skips any file that already exists - never overwrites.
# Re-run safely after pulling updates.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# Counters
INSTALLED=0
SKIPPED=0

# Color output (disabled if not a terminal)
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  RESET=""
fi

echo "${BOLD}pharaoh-write installer${RESET}"
echo "Source:      ${REPO_DIR}"
echo "Destination: ${CLAUDE_DIR}"
echo ""

# Make sure target directories exist
mkdir -p "${CLAUDE_DIR}/commands"
mkdir -p "${CLAUDE_DIR}/agents"
mkdir -p "${CLAUDE_DIR}/skills"

# install_file <source> <destination>
# Skips if destination already exists.
install_file() {
  local src="$1"
  local dst="$2"

  if [[ -e "${dst}" ]]; then
    echo "  ${YELLOW}skip${RESET} ${dst#${HOME}/}  (already exists)"
    SKIPPED=$((SKIPPED + 1))
    return
  fi

  mkdir -p "$(dirname "${dst}")"
  cp "${src}" "${dst}"
  echo "  ${GREEN}install${RESET} ${dst#${HOME}/}"
  INSTALLED=$((INSTALLED + 1))
}

# Install commands
echo "${BLUE}Commands${RESET}"
for f in "${REPO_DIR}/commands"/*; do
  [[ -f "${f}" ]] || continue
  install_file "${f}" "${CLAUDE_DIR}/commands/$(basename "${f}")"
done

# Install agents
echo ""
echo "${BLUE}Agents${RESET}"
for f in "${REPO_DIR}/agents"/*; do
  [[ -f "${f}" ]] || continue
  install_file "${f}" "${CLAUDE_DIR}/agents/$(basename "${f}")"
done

# Install skills (recursive — skill dirs may contain subdirectories like voice-corpus)
echo ""
echo "${BLUE}Skills${RESET}"
for skill_dir in "${REPO_DIR}/skills"/*/; do
  [[ -d "${skill_dir}" ]] || continue
  skill_name="$(basename "${skill_dir}")"

  # Walk every file in the skill directory tree
  while IFS= read -r -d '' src_file; do
    rel_path="${src_file#${REPO_DIR}/skills/}"
    dst_file="${CLAUDE_DIR}/skills/${rel_path}"
    install_file "${src_file}" "${dst_file}"
  done < <(find "${skill_dir}" -type f -print0)
done

# Summary
echo ""
echo "${BOLD}Done.${RESET}"
echo "  Installed: ${GREEN}${INSTALLED}${RESET}"
echo "  Skipped:   ${YELLOW}${SKIPPED}${RESET} (already existed — left untouched)"
echo ""

if (( INSTALLED == 0 && SKIPPED > 0 )); then
  echo "Everything was already installed. To force a reinstall, delete the conflicting"
  echo "files first and re-run this script."
  exit 0
fi

if (( INSTALLED > 0 )); then
  cat <<EOF
Next steps:

  1. Open a Claude Code session
  2. Type ${BOLD}/write${RESET} to verify the slash command is available
  3. Seed your voice corpus at:
     ${CLAUDE_DIR}/skills/writer-agent/voice-corpus/
  4. Customize ${CLAUDE_DIR}/skills/natural-voice/SKILL.md with your vocabulary

Docs: see README.md in this repo for usage and customization.
EOF
fi
