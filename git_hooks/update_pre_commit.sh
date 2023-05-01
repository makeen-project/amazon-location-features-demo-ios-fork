#!/bin/sh

project_root=$(git rev-parse --show-toplevel)
src_pre_commit="${project_root}/git_hooks/pre-commit"
dst_pre_commit="${project_root}/.git/hooks/pre-commit"

if [ ! -f "$src_pre_commit" ]; then
  echo "Error: Source pre-commit file not found at $src_pre_commit"
  exit 1
fi

if [ ! -d "${project_root}/.git/hooks" ]; then
  mkdir -p "${project_root}/.git/hooks"
fi

# Check if the destination file exists
if [ ! -f "$dst_pre_commit" ]; then
  echo "Creating .git/hooks/pre-commit from git_hooks/pre-commit"
  cp "$src_pre_commit" "$dst_pre_commit"
  chmod +x "$dst_pre_commit"
else
  # Compare files and update if needed
  if ! cmp -s "$src_pre_commit" "$dst_pre_commit"; then
    echo "Updating .git/hooks/pre-commit from git_hooks/pre-commit"
    cp "$src_pre_commit" "$dst_pre_commit"
    chmod +x "$dst_pre_commit"
  fi
fi
