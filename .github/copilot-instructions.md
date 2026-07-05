Copilot instructions for KDE Plasma theme ALTIMIT MINE OS repo

Purpose
- Help maintainers and contributors use Copilot features productively for this repo.

What to suggest
- Create small, focused edits: conversion script improvements, shellcheck fixes, metadata tweaks.
- Prefer changes that assume contents/ already contains converted PNG/OGG assets.
- When proposing code, include short tests or verification steps (e.g., run ./theme_convert.sh contents/sample_hack.theme).

What not to do
- Do not fetch or upload the large Internet Archive assets; the repo expects users to download and extract to contents/ manually.
- Do not commit secrets, personal data, or binary asset dumps into the repository.
- Do not perform git commits or pushes — Copilot may suggest commands, but must not execute or commit them.

Local execution guidance
- Scripts are bash-based. Use a POSIX-ish shell on Linux for testing.
- To reproduce locally:
  1) Place extracted assets under ./contents (see README.md)
  2) Run: ./theme_convert.sh contents/sample_hack.theme "ALTIMIT MINE OS"

Review guidance
- Prefer minimal, well-tested changes. Run shellcheck and keep the script readable with small functions.
- Keep metadata.json and metadata.desktop accurate (Name, Author, Version).

Language style for comments and documentation
- Use only present-tense descriptions of what things ARE, never "now doing this" or references to specific changes.
- Comment code to explain its function and purpose, not to narrate actions or changes being made.
- Avoid change-narrative language (e.g., "was changed to", "added for", "now converts"). Instead, describe the current state and function (e.g., "Converts PNG files to OGG format", "Reads theme metadata from JSON").

Contact
- Note any behavior assumptions in PR descriptions (e.g., contents/ layout, converted file formats).
