#!/usr/bin/env bash
set -euo pipefail

TS="$(date +%Y%m%d-%H%M%S)"
ROOT="$HOME/DotfileBackup"
DEST="$ROOT/$TS"
mkdir -p "$DEST"

log(){ printf '[%s] %s\n' "$(date +%H:%M:%S)" "$*"; }

# 1) ~/.zshrc
if [[ -f "$HOME/.zshrc" ]]; then
  cp -a "$HOME/.zshrc" "$DEST/"
  log "Copied ~/.zshrc"
else
  log "No ~/.zshrc found"
fi

# 2) Powerlevel10k config or theme
# p10k wizard usually writes ~/.p10k.zsh (per docs)
if [[ -f "$HOME/.p10k.zsh" ]]; then
  cp -a "$HOME/.p10k.zsh" "$DEST/"
  log "Copied ~/.p10k.zsh"
else
  # Fallback: copy the theme directory used by Oh My Zsh
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
  candidates=(
    "$ZSH_CUSTOM/themes/powerlevel10k"
    "$HOME/.oh-my-zsh/themes/powerlevel10k"
  )

  src_dir=""
  for d in "${candidates[@]}"; do
    [[ -d "$d" ]] && { src_dir="$d"; break; }
  done

  # Last resort: search under ~/.oh-my-zsh for powerlevel10k.zsh-theme
  if [[ -z "$src_dir" && -d "$HOME/.oh-my-zsh" ]]; then
    hit="$(find "$HOME/.oh-my-zsh" -type f -name 'powerlevel10k.zsh-theme' 2>/dev/null | head -n1 || true)"
    [[ -n "$hit" ]] && src_dir="$(dirname "$hit")"
  fi

  if [[ -n "$src_dir" ]]; then
    rsync -a --exclude '.git' "$src_dir" "$DEST/"
    log "Copied theme dir: ${src_dir/#$HOME/~}"
  else
    log "Powerlevel10k theme dir not found under ~/.oh-my-zsh"
  fi
fi

printf '\nBackup complete: %s\n' "$DEST"
