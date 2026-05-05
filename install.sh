#!/usr/bin/env bash
#
# pharaoh-write installer
#
# Copies commands, agents, and skills into ~/.claude/.
#
# Default behavior: skips any file that already exists - never overwrites.
# Re-run safely after pulling updates.
#
# Flags:
#   --sync-rules   Overwrite SKILL.md / phrase-blacklist.md / writer-agent.md only.
#                  Voice corpus and personalized files (anything outside SKILL.md
#                  in skills/, plus all of voice-corpus/) are preserved.
#                  Use this to pull rule updates without losing personalization.
#
#   --replace      Back up the existing install to ~/.claude.bak.<timestamp>/
#                  then overwrite everything. Use when migrating from a different
#                  agent install or doing a clean reset.
#
#   --dry-run      Show what would be installed/skipped/overwritten, change nothing.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# Mode flags
SYNC_RULES=0
REPLACE=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sync-rules) SYNC_RULES=1; shift ;;
    --replace) REPLACE=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,21p' "${BASH_SOURCE[0]}" | sed 's/^# \?//'
      exit 0
      ;;
    *)
      echo "Unknown flag: $1" >&2
      echo "Use --help for usage." >&2
      exit 1
      ;;
  esac
done

if (( SYNC_RULES == 1 && REPLACE == 1 )); then
  echo "Error: --sync-rules and --replace are mutually exclusive." >&2
  exit 1
fi

# Counters
INSTALLED=0
SKIPPED=0
UPDATED=0
BACKED_UP=0

# Color output (disabled if not a terminal)
if [[ -t 1 ]]; then
  GREEN=$'\033[0;32m'
  YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'
  RED=$'\033[0;31m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN=""; YELLOW=""; BLUE=""; RED=""; BOLD=""; RESET=""
fi

echo "${BOLD}pharaoh-write installer${RESET}"
echo "Source:      ${REPO_DIR}"
echo "Destination: ${CLAUDE_DIR}"

if (( SYNC_RULES == 1 )); then
  echo "Mode:        ${BLUE}--sync-rules${RESET} (overwrite rule files only, preserve personalization)"
elif (( REPLACE == 1 )); then
  echo "Mode:        ${RED}--replace${RESET} (backup + overwrite everything)"
else
  echo "Mode:        default (skip existing files)"
fi

if (( DRY_RUN == 1 )); then
  echo "Dry run:     ${YELLOW}YES${RESET} - no files will be modified"
fi
echo ""

# In --replace mode, back up the existing install first
if (( REPLACE == 1 && DRY_RUN == 0 )); then
  if [[ -d "${CLAUDE_DIR}/agents" ]] || [[ -d "${CLAUDE_DIR}/skills" ]] || [[ -d "${CLAUDE_DIR}/commands" ]]; then
    BACKUP_DIR="${HOME}/.claude.bak.$(date +%Y%m%d_%H%M%S)"
    echo "${YELLOW}Backing up existing install to:${RESET} ${BACKUP_DIR}"
    mkdir -p "${BACKUP_DIR}"
    for sub in agents skills commands; do
      if [[ -d "${CLAUDE_DIR}/${sub}" ]]; then
        cp -R "${CLAUDE_DIR}/${sub}" "${BACKUP_DIR}/${sub}"
        BACKED_UP=$((BACKED_UP + 1))
      fi
    done
    echo "  Backed up ${BACKED_UP} directories."
    echo ""
  fi
fi

# Make sure target directories exist
if (( DRY_RUN == 0 )); then
  mkdir -p "${CLAUDE_DIR}/commands"
  mkdir -p "${CLAUDE_DIR}/agents"
  mkdir -p "${CLAUDE_DIR}/skills"
fi

# is_rule_file <path> - returns 0 if the path is a rule file (subject to --sync-rules overwrite)
# Rule files: SKILL.md, phrase-blacklist.md, check.py, agents/*.md, commands/*.md
# Voice corpus and BRIEF_TEMPLATE.md are NOT rule files.
is_rule_file() {
  local path="$1"
  case "${path}" in
    */SKILL.md) return 0 ;;
    */phrase-blacklist.md) return 0 ;;
    */check.mjs) return 0 ;;
    */agents/*.md) return 0 ;;
    */commands/*.md) return 0 ;;
    *) return 1 ;;
  esac
}

# install_file <source> <destination>
install_file() {
  local src="$1"
  local dst="$2"

  if [[ -e "${dst}" ]]; then
    # File exists. Decide based on mode.
    if (( REPLACE == 1 )); then
      action="overwrite"
    elif (( SYNC_RULES == 1 )) && is_rule_file "${dst}"; then
      action="update"
    else
      echo "  ${YELLOW}skip${RESET} ${dst#${HOME}/}  (already exists)"
      SKIPPED=$((SKIPPED + 1))
      return
    fi

    if (( DRY_RUN == 1 )); then
      echo "  ${BLUE}would ${action}${RESET} ${dst#${HOME}/}"
    else
      mkdir -p "$(dirname "${dst}")"
      cp "${src}" "${dst}"
      echo "  ${BLUE}${action}${RESET} ${dst#${HOME}/}"
    fi
    UPDATED=$((UPDATED + 1))
    return
  fi

  # File does not exist - install it
  if (( DRY_RUN == 1 )); then
    echo "  ${GREEN}would install${RESET} ${dst#${HOME}/}"
  else
    mkdir -p "$(dirname "${dst}")"
    cp "${src}" "${dst}"
    echo "  ${GREEN}install${RESET} ${dst#${HOME}/}"
  fi
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

# Install skills (recursive - skill dirs may contain subdirectories like voice-corpus)
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
echo "  Updated:   ${BLUE}${UPDATED}${RESET}"
echo "  Skipped:   ${YELLOW}${SKIPPED}${RESET}"
if (( REPLACE == 1 && BACKED_UP > 0 )); then
  echo "  Backed up: ${YELLOW}${BACKED_UP}${RESET} directories to ${BACKUP_DIR}"
fi
echo ""

if (( DRY_RUN == 1 )); then
  echo "${YELLOW}Dry run complete. Re-run without --dry-run to apply.${RESET}"
  exit 0
fi

if (( INSTALLED == 0 && UPDATED == 0 && SKIPPED > 0 )); then
  echo "Everything was already installed. To pull rule updates only, run:"
  echo "  ${BOLD}./install.sh --sync-rules${RESET}"
  echo "To force a full reinstall, run:"
  echo "  ${BOLD}./install.sh --replace${RESET}"
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

if (( UPDATED > 0 && INSTALLED == 0 )); then
  echo "Rule files updated. Re-open any Claude Code session for the new rules to apply."
fi
