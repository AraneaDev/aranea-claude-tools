# Aranea Claude tools

Small, focused Claude Code plugins. Local-first, no telemetry, no API key.

This repository is a marketplace. It holds no plugin code of its own, only the
manifest that points at each plugin's own repository, so every plugin releases
on its own cadence.

## Install

Add the marketplace once:

```bash
/plugin marketplace add AraneaDev/aranea-claude-tools
```

Then install what you want:

```bash
/plugin install claude-timestamp@aranea-claude-tools
/plugin install kanon@aranea-claude-tools
```

## What is here

| Plugin | What it does | Repository |
| --- | --- | --- |
| **claude-timestamp** | Stamps every message with the local time and how long the turn took, names the tool behind a slow turn, and reports where a session's time went. | [AraneaDev/claude-timestamp](https://github.com/AraneaDev/claude-timestamp) |
| **kanon** | Reports every instruction file governing a session, where each one came from, and the ones you expected that never loaded. Names a dependency's `CLAUDE.md` as foreign when it reaches your context. | [AraneaDev/kanon](https://github.com/AraneaDev/kanon) |

## Adding a plugin

Add an entry to `.claude-plugin/marketplace.json` pointing at the plugin's own
repository:

```json
{
  "name": "your-plugin",
  "source": { "source": "github", "repo": "AraneaDev/your-plugin" },
  "description": "One line, plain, no hype."
}
```

The plugin repository keeps its own `.claude-plugin/plugin.json`. It does not
need a marketplace manifest of its own.

## License

MIT.
