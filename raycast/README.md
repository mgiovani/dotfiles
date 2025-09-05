# Raycast Configuration

This directory contains Raycast-related configurations for the dotfiles setup.

## What's Included

- `extensions-list.md` - List of recommended public extensions
- Configuration templates (no sensitive data)

## What's NOT Included (Privacy & Security)

The following are intentionally excluded from this public repository:
- Personal API keys
- Company-specific extensions
- Private shortcuts and workflows
- Personal preferences and settings
- Authentication tokens

## Setup Instructions

1. **Install Raycast**: Already included in the Brewfile
2. **Install Extensions**: Follow the list in `extensions-list.md`
3. **Configure Manually**: Set up API keys and personal preferences through Raycast UI
4. **Use Raycast Sync**: Enable Raycast's built-in sync for personal backup

## Manual Configuration Steps

After installation:

1. Open Raycast preferences (`⌘` + `,`)
2. Set up your preferred hotkey (default: `⌘` + `Space`)
3. Configure extensions with your API keys
4. Set up custom aliases and shortcuts
5. Enable Raycast sync for cross-device consistency

## Privacy Note

Raycast stores personal data locally. For privacy and security:
- Never commit actual Raycast preference files
- Use environment variables for API keys where possible
- Keep sensitive configurations in your personal sync, not in dotfiles