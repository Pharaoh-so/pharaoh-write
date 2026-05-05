#!/usr/bin/env bash
#
# pharaoh-write installer
#
# Copies commands, agents, and skills into ~/.claude/.
#
# Modes:
#   (no flag)        Install only files that don't exist locally. Safe.
#                    Files already present are left untouched.
#
#   --sync-rules     Update all managed files. Preserve protected files
#                    (voice corpus, BRIEF_TEMPLATE.md, phrase-blacklist-local.md).
#                    Use this to pull rule updates without losing personalization.
#
#   --fresh          One-command total reinstall: backup, then wipe everything
#                    pharaoh-write owns (preserving protected files), then install
#                    latest from source. Use after pulling significant updates,
#                    or when migrating from a different agent install.
#
#   --dry-run        Show what would change. No files modified.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"

# ------------------------------------------------------------
# Configuration: what pharaoh-write owns
# ------------------------------------------------------------
#
# Paths managed by this installer. --fresh wipes these (minus protected
# files) before reinstalling. Edit when adding/removing skills.
#
# Anything OUTSIDE these paths is never touched, regardless of flags.

OWNED_AGENTS=("writer-agent.md")
OWNED_COMMANDS=("write.md")
OWNED_SKILLS=(
  "anti-ai-filter"
  "content-frameworks"
  "longform-writing"
  "natural-voice"
  "short-reply"
  "startup-narrative"
  "story-structure"
  "writer-agent"
)

# is_protected <absolute-path> - returns 0 if the path must never be
# overwritten, even by --sync-rules or --fresh. Used to preserve user
# personalization (voice corpus + local additions to phrase blacklist).
is_protected() {
  local path="$1"
  case "${path}" in
    */voice-corpus/*) return 0 ;;
    */BRIEF_TEMPLATE.md) return 0 ;;
    */phrase-blacklist-local.md) return 0 ;;
    *) return 1 ;;
  esac
}

# ------------------------------------------------------------
# Arg parsing
# ------------------------------------------------------------

SYNC_RULES=0
FRESH=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --sync-rules) SYNC_RULES=1; shift ;;
    --fresh|--replace) FRESH=1; shift ;;  # --replace kept as backwards-compat alias
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

if (( SYNC_RULES == 1 && FRESH == 1 )); then
  echo "Error: --sync-rules and --fresh are mutually exclusive." >&2
  exit 1
fi

# ------------------------------------------------------------
# Display setup
# ------------------------------------------------------------

INSTALLED=0
SKIPPED=0
UPDATED=0
REMOVED=0
BACKED_UP=0
BACKUP_DIR=""

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
  echo "Mode:        ${BLUE}--sync-rules${RESET} (update managed files, preserve protected)"
elif (( FRESH == 1 )); then
  echo "Mode:        ${RED}--fresh${RESET} (backup + wipe owned paths + install latest)"
else
  echo "Mode:        default (skip files that already exist)"
fi

if (( DRY_RUN == 1 )); then
  echo "Dry run:     ${YELLOW}YES${RESET} - no files will be modified"
fi
echo ""

# ------------------------------------------------------------
# --fresh: backup + wipe owned paths
# ------------------------------------------------------------

if (( FRESH == 1 )); then
  if [[ -d "${CLAUDE_DIR}/agents" ]] || [[ -d "${CLAUDE_DIR}/skills" ]] || [[ -d "${CLAUDE_DIR}/commands" ]]; then
    BACKUP_DIR="${HOME}/.claude.bak.$(date +%Y%m%d_%H%M%S)"
    if (( DRY_RUN == 1 )); then
      echo "${YELLOW}Would back up existing install to:${RESET} ${BACKUP_DIR}"
    else
      echo "${YELLOW}Backing up existing install to:${RESET} ${BACKUP_DIR}"
      mkdir -p "${BACKUP_DIR}"
      for sub in agents skills commands; do
        if [[ -d "${CLAUDE_DIR}/${sub}" ]]; then
          cp -R "${CLAUDE_DIR}/${sub}" "${BACKUP_DIR}/${sub}"
          BACKED_UP=$((BACKED_UP + 1))
        fi
      done
      echo "  Backed up ${BACKED_UP} directories."
    fi
    echo ""

    # Walk owned paths, remove non-protected files
    echo "${BLUE}Removing stale files from owned paths${RESET}"
    for agent in "${OWNED_AGENTS[@]}"; do
      target="${CLAUDE_DIR}/agents/${agent}"
      if [[ -f "${target}" ]] && ! is_protected "${target}"; then
        if (( DRY_RUN == 1 )); then
          echo "  ${YELLOW}would remove${RESET} ${target#${HOME}/}"
        else
          rm -f "${target}"
          echo "  ${YELLOW}removed${RESET} ${target#${HOME}/}"
        fi
        REMOVED=$((REMOVED + 1))
      fi
    done
    for cmd in "${OWNED_COMMANDS[@]}"; do
      target="${CLAUDE_DIR}/commands/${cmd}"
      if [[ -f "${target}" ]] && ! is_protected "${target}"; then
        if (( DRY_RUN == 1 )); then
          echo "  ${YELLOW}would remove${RESET} ${target#${HOME}/}"
        else
          rm -f "${target}"
          echo "  ${YELLOW}removed${RESET} ${target#${HOME}/}"
        fi
        REMOVED=$((REMOVED + 1))
      fi
    done
    for skill in "${OWNED_SKILLS[@]}"; do
      skill_dir="${CLAUDE_DIR}/skills/${skill}"
      [[ -d "${skill_dir}" ]] || continue
      while IFS= read -r -d '' f; do
        if ! is_protected "${f}"; then
          if (( DRY_RUN == 1 )); then
            echo "  ${YELLOW}would remove${RESET} ${f#${HOME}/}"
          else
            rm -f "${f}"
            echo "  ${YELLOW}removed${RESET} ${f#${HOME}/}"
          fi
          REMOVED=$((REMOVED + 1))
        fi
      done < <(find "${skill_dir}" -type f -print0)
      # Clean up any empty directories left behind (excluding voice-corpus which may have user files)
      if (( DRY_RUN == 0 )); then
        find "${skill_dir}" -type d -empty -not -path "*/voice-corpus*" -delete 2>/dev/null || true
      fi
    done
    echo ""
  fi
fi

# Make sure target directories exist
if (( DRY_RUN == 0 )); then
  mkdir -p "${CLAUDE_DIR}/commands"
  mkdir -p "${CLAUDE_DIR}/agents"
  mkdir -p "${CLAUDE_DIR}/skills"
fi

# ------------------------------------------------------------
# install_file - decides install/update/skip per file
# ------------------------------------------------------------

install_file() {
  local src="$1"
  local dst="$2"

  if [[ -e "${dst}" ]]; then
    # File exists. Decide based on mode.
    local action=""

    if is_protected "${dst}"; then
      # Protected files are never overwritten regardless of mode.
      echo "  ${YELLOW}skip${RESET} ${dst#${HOME}/}  (protected)"
      SKIPPED=$((SKIPPED + 1))
      return
    fi

    if (( FRESH == 1 )); then
      # In fresh mode, file shouldn't exist - we removed everything above.
      # If we're here it's a protected file (handled above) or a path that
      # wasn't in the OWNED_* arrays, OR we're in dry-run mode where the
      # wipe was simulated. Either way, semantically we're installing fresh.
      action="install"
    elif (( SYNC_RULES == 1 )); then
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

# ------------------------------------------------------------
# Install from source
# ------------------------------------------------------------

echo "${BLUE}Commands${RESET}"
for f in "${REPO_DIR}/commands"/*; do
  [[ -f "${f}" ]] || continue
  install_file "${f}" "${CLAUDE_DIR}/commands/$(basename "${f}")"
done

echo ""
echo "${BLUE}Agents${RESET}"
for f in "${REPO_DIR}/agents"/*; do
  [[ -f "${f}" ]] || continue
  install_file "${f}" "${CLAUDE_DIR}/agents/$(basename "${f}")"
done

echo ""
echo "${BLUE}Skills${RESET}"
for skill_dir in "${REPO_DIR}/skills"/*/; do
  [[ -d "${skill_dir}" ]] || continue

  while IFS= read -r -d '' src_file; do
    rel_path="${src_file#${REPO_DIR}/skills/}"
    dst_file="${CLAUDE_DIR}/skills/${rel_path}"
    install_file "${src_file}" "${dst_file}"
  done < <(find "${skill_dir}" -type f -print0)
done

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

echo ""
echo "${BOLD}Done.${RESET}"
echo "  Installed: ${GREEN}${INSTALLED}${RESET}"
echo "  Updated:   ${BLUE}${UPDATED}${RESET}"
echo "  Skipped:   ${YELLOW}${SKIPPED}${RESET}"
if (( FRESH == 1 )); then
  echo "  Removed:   ${RED}${REMOVED}${RESET} (stale files cleared from owned paths)"
  if [[ -n "${BACKUP_DIR}" ]]; then
    echo "  Backed up: ${YELLOW}${BACKED_UP}${RESET} dirs to ${BACKUP_DIR}"
  fi
fi
echo ""

if (( DRY_RUN == 1 )); then
  echo "${YELLOW}Dry run complete. Re-run without --dry-run to apply.${RESET}"
  exit 0
fi

if (( INSTALLED == 0 && UPDATED == 0 && SKIPPED > 0 )); then
  echo "Everything was already installed. To pull updates:"
  echo "  ${BOLD}./install.sh --sync-rules${RESET}     (preserves voice corpus + local customizations)"
  echo "  ${BOLD}./install.sh --fresh${RESET}          (totally fresh install, clears stale files)"
  exit 0
fi

if (( INSTALLED > 0 || (FRESH == 1 && UPDATED > 0) )); then
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

if (( UPDATED > 0 && INSTALLED == 0 && FRESH == 0 )); then
  echo "Rule files updated. Re-open any Claude Code session for the new rules to apply."
fi
