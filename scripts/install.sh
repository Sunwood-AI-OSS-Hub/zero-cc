#!/usr/bin/env bash
set -euo pipefail

# zero-cc installer (uv-style: curl | bash)
#
# What it does:
#  - Installs Claude Code if `claude` is missing (official native installer)
#  - Ensures ~/.local/bin is in PATH (via ~/.bashrc.d/10-path-localbin.sh)
#  - Writes:
#      ~/.bashrc.d/00-llm-secrets.sh
#      ~/.bashrc.d/60-claude-modes.sh
#    and ensures ~/.bashrc sources ~/.bashrc.d/*.sh
#
# Usage (examples):
#   curl -fsSL https://raw.githubusercontent.com/Sunwood-ai-labs/zero-cc/main/script/install.sh | bash
#   ZAI_API_KEY="xxx" curl -fsSL .../install.sh | bash -s -- --force

FORCE=1
NO_BASHRC=0
SKIP_CLAUDE_INSTALL=0

while [ $# -gt 0 ]; do
  case "$1" in
    --force) FORCE=1 ;;
    --no-bashrc) NO_BASHRC=1 ;;
    --skip-claude-install) SKIP_CLAUDE_INSTALL=1 ;;
    -h|--help)
      cat <<'HELP'
Options:
  --force                overwrite existing files (creates backups)
  --no-bashrc            do not modify ~/.bashrc
  --skip-claude-install  do not install Claude Code even if missing

Env:
  ZAI_API_KEY        Z.AI API key (optional; prompts if TTY, else placeholder)
HELP
      exit 0
      ;;
    *)
      echo "[install] unknown option: $1" >&2
      exit 2
      ;;
  esac
  shift
done

timestamp() { date +%Y%m%d-%H%M%S; }
has_tty() { [ -t 0 ] && [ -t 1 ]; }

backup_if_exists() {
  local f="$1"
  if [ -e "$f" ]; then
    cp -a "$f" "${f}.bak.$(timestamp)"
  fi
}

write_file_strict() {
  # $1=target_path $2=file_content $3=mode
  local target_path="$1"
  local file_content="$2"
  local mode="$3"

  if [ -e "$target_path" ] && [ "$FORCE" -ne 1 ]; then
    echo "[install] exists (skip; use --force to overwrite): $target_path" >&2
    return 0
  fi

  backup_if_exists "$target_path"
  umask 077
  printf '%s' "$file_content" > "$target_path"
  chmod "$mode" "$target_path"
}

ensure_bashrc_loader() {
  local bashrc="$1"
  local marker="user snippets (modular)"

  [ -e "$bashrc" ] || touch "$bashrc"

  if grep -q "$marker" "$bashrc"; then
    return 0
  fi

  cat >> "$bashrc" <<'BLOCK'

# ---- user snippets (modular) ----
if [ -d "$HOME/.bashrc.d" ]; then
  for f in "$HOME/.bashrc.d/"*.sh; do
    [ -e "$f" ] || continue
    . "$f"
  done
fi
BLOCK
}

ensure_zshrc_loader() {
  local zshrc="$1"
  local marker="user snippets (modular)"

  [ -e "$zshrc" ] || touch "$zshrc"

  if grep -q "$marker" "$zshrc"; then
    return 0
  fi

  cat >> "$zshrc" <<'BLOCK'

# ---- user snippets (modular) ----
if [ -d "$HOME/.bashrc.d" ]; then
  for f in "$HOME"/.bashrc.d/*.sh; do
    [ -e "$f" ] || continue
    . "$f"
  done
fi
BLOCK
}

pick_zai_key() {
  if [ -n "${ZAI_API_KEY:-}" ]; then
    echo "$ZAI_API_KEY"
    return 0
  fi

  if has_tty; then
    printf "ZAI_API_KEY: " >&2
    # shellcheck disable=SC2162
    read -s key
    echo >&2
    echo "$key"
    return 0
  fi

  echo "YOUR_ZAI_API_KEY"
}


install_claude_if_missing() {
  if [ "$SKIP_CLAUDE_INSTALL" -eq 1 ]; then
    return 0
  fi

  if command -v claude >/dev/null 2>&1; then
    return 0
  fi

  echo "[install] Claude Code not found. Installing via official installer..." >&2
  # Official native install (macOS/Linux/WSL)
  # curl -fsSL https://claude.ai/install.sh | bash
  # Installs symlink to ~/.local/bin/claude (ensure PATH includes ~/.local/bin)
  curl -fsSL https://claude.ai/install.sh | bash

  if ! command -v claude >/dev/null 2>&1; then
    echo "[install] Claude Code install finished but 'claude' is still not in PATH." >&2
    echo "[install] You may need to reload your shell or ensure ~/.local/bin is in PATH." >&2
  fi
}

write_path_snippet() {
  local bashrc_d="$HOME/.bashrc.d"
  mkdir -p "$bashrc_d"
  chmod 700 "$bashrc_d"

  local path_file="$bashrc_d/10-path-localbin.sh"
  local content
  content=$(
    cat <<'EOF'
# Ensure ~/.local/bin is on PATH (Claude Code installer links here)
# Only run in bash/zsh
[ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ] || return 0
case ":$PATH:" in
  *":$HOME/.local/bin:"*) ;;
  *) export PATH="$HOME/.local/bin:$PATH" ;;
esac
EOF
  )
  write_file_strict "$path_file" "$content" 600
}

write_secrets_and_modes() {
  local bashrc_d="$HOME/.bashrc.d"
  mkdir -p "$bashrc_d"
  chmod 700 "$bashrc_d"

  # シークレットファイルは既存の場合はスキップ（上書き防止）
  local secrets_path="$bashrc_d/00-llm-secrets.sh"
  if [ -e "$secrets_path" ]; then
    echo "[install] secrets file exists, skipping: $secrets_path" >&2
  else
    local zai_key
    zai_key="$(pick_zai_key)"

    local secrets_content
    secrets_content=$(
      cat <<EOF
# LLM Secrets (DO NOT SHARE)

# --- Z.AI (Anthropic-compatible endpoint for Claude Code) ---
ZAI_API_KEY="${zai_key}"

# --- OpenRouter (keep for reference) ---
# OPENROUTER_API_KEY="YOUR_OPENROUTER_KEY"
EOF
    )
    write_file_strict "$secrets_path" "$secrets_content" 600
  fi

  local modes_path="$bashrc_d/60-claude-modes.sh"
  local modes_content
  modes_content=$(
    cat <<'EOF'
# ===== Claude Code: mode switching =====
# Only run in bash/zsh
[ -n "$BASH_VERSION" ] || [ -n "$ZSH_VERSION" ] || return 0

# --- Z.AI Anthropic-compatible endpoint ---
# Z.AI docs:
#   ANTHROPIC_BASE_URL=https://api.z.ai/api/anthropic
#   ANTHROPIC_AUTH_TOKEN=your_zai_api_key
#   API_TIMEOUT_MS=3000000 (optional)
ZAI_ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"

# Model mapping (as requested)
ZAI_DEFAULT_HAIKU_MODEL="glm-4.5-air"
ZAI_DEFAULT_SONNET_MODEL="glm-4.7"
ZAI_DEFAULT_OPUS_MODEL="glm-4.7"

# --- OpenRouter config (kept as comments for reference) ---
# OPENROUTER_BASE_URL="https://openrouter.ai/api"
# OPENROUTER_GLM_FREE_MODEL="z-ai/glm-4.5-air:free"
# export ANTHROPIC_BASE_URL="$OPENROUTER_BASE_URL"
# export ANTHROPIC_AUTH_TOKEN="$OPENROUTER_API_KEY"
# export ANTHROPIC_API_KEY=""
# export ANTHROPIC_DEFAULT_OPUS_MODEL="$OPENROUTER_GLM_FREE_MODEL"
# export ANTHROPIC_DEFAULT_SONNET_MODEL="$OPENROUTER_GLM_FREE_MODEL"
# export ANTHROPIC_DEFAULT_HAIKU_MODEL="$OPENROUTER_GLM_FREE_MODEL"


# 1) 通常（Anthropic 側ログイン/サブスク運用想定）
cc_std() (
  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_API_KEY
  unset API_TIMEOUT_MS
  command claude "$@"
)

# 2) GLM (Z.AI Anthropic endpoint)
cc_glm() (
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[cc_glm] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""

  # optional, but recommended by Z.AI docs
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  export ANTHROPIC_DEFAULT_HAIKU_MODEL="$ZAI_DEFAULT_HAIKU_MODEL"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$ZAI_DEFAULT_SONNET_MODEL"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$ZAI_DEFAULT_OPUS_MODEL"

  command claude "$@"
)

# 3) GLM Flash (glm-4.7-flash) - 通常モード
cc_glm_47f() (
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[cc_glm_47f] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""

  # optional, but recommended by Z.AI docs
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  # 固定モデル: glm-4.7-flash
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7-flash"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7-flash"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7-flash"

  command claude "$@"
)

# 4) GLM FlashX (glm-4.7-flashx) - 通常モード
cc_glm_47fx() (
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[cc_glm_47fx] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""

  # optional, but recommended by Z.AI docs
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  # 固定モデル: glm-4.7-flashx
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7-flashx"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7-flashx"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7-flashx"

  command claude "$@"
)

# 5) Dangerous（root/sudo では Claude Code 側で拒否されるため、rootなら自動で非rootに降格）
ccd_std() (

  unset ANTHROPIC_BASE_URL
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_API_KEY
  unset API_TIMEOUT_MS

  command claude --dangerously-skip-permissions "$@"
)

ccd_glm() (

  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[ccd_glm] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  export ANTHROPIC_DEFAULT_HAIKU_MODEL="$ZAI_DEFAULT_HAIKU_MODEL"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="$ZAI_DEFAULT_SONNET_MODEL"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="$ZAI_DEFAULT_OPUS_MODEL"

  command claude --dangerously-skip-permissions "$@"
)

# 6) GLM Flash (glm-4.7-flash) - Dangerous
ccd_glm_47f() (
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[ccd_glm_47f] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  # 固定モデル: glm-4.7-flash
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7-flash"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7-flash"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7-flash"

  command claude --dangerously-skip-permissions "$@"
)

# 7) GLM FlashX (glm-4.7-flashx) - Dangerous
ccd_glm_47fx() (
  # shellcheck disable=SC1090
  . "$HOME/.bashrc.d/00-llm-secrets.sh"

  if [ -z "${ZAI_API_KEY:-}" ]; then
    echo "[ccd_glm_47fx] ZAI_API_KEY が未設定です: ~/.bashrc.d/00-llm-secrets.sh を編集してください" >&2
    exit 2
  fi

  export ANTHROPIC_BASE_URL="$ZAI_ANTHROPIC_BASE_URL"
  export ANTHROPIC_AUTH_TOKEN="$ZAI_API_KEY"
  export ANTHROPIC_API_KEY=""
  export API_TIMEOUT_MS="${API_TIMEOUT_MS:-3000000}"

  # 固定モデル: glm-4.7-flashx
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.7-flashx"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.7-flashx"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.7-flashx"

  command claude --dangerously-skip-permissions "$@"
)

alias cc-st='cc_std'
alias cc-glm='cc_glm'
alias cc-glm-47f='cc_glm_47f'
alias cc-glm-47fx='cc_glm_47fx'
alias ccd-st='ccd_std'
alias ccd-glm='ccd_glm'
alias ccd-glm-47f='ccd_glm_47f'
alias ccd-glm-47fx='ccd_glm_47fx'
EOF
  )
  write_file_strict "$modes_path" "$modes_content" 600
}

write_ccd_glm_agent() {
  local bin_dir="$HOME/.local/bin"
  mkdir -p "$bin_dir"

  local agent_path="$bin_dir/ccd-glm-agent"
  local content
  content=$(
    cat <<'EOF'
#!/usr/bin/env bash
# ccd-glm-agent: シンプルな ccd_glm ラッパー
# ccd_glm 関数を呼び出す実行ファイル

ccd_glm "$@"
EOF
  )

  write_file_strict "$agent_path" "$content" 755
  echo "[install] wrote: $agent_path"
}

main() {
  install_claude_if_missing
  write_path_snippet
  write_secrets_and_modes
  write_ccd_glm_agent

  if [ "$NO_BASHRC" -ne 1 ]; then
    ensure_bashrc_loader "$HOME/.bashrc"
    ensure_zshrc_loader "$HOME/.zshrc"
  fi

  echo "[install] done. Run: source ~/.bashrc  (or source ~/.zshrc)"
  echo "[install] commands: cc-st / cc-glm / ccd-st / ccd-glm"
  echo "[install] verify: claude doctor"
}

main
