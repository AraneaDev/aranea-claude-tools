<div align="center">

# Aranea Claude tools

**Small, focused Claude Code plugins.**
**Local-first, no telemetry, no API key.**

[![License](https://img.shields.io/github/license/AraneaDev/aranea-claude-tools?label=license&color=yellow)](./LICENSE)
[![Last commit](https://img.shields.io/github/last-commit/AraneaDev/aranea-claude-tools?label=last%20commit)](https://github.com/AraneaDev/aranea-claude-tools/commits/main)
[![Conventional Commits](https://img.shields.io/badge/commits-conventional-fe5196?logo=conventionalcommits&logoColor=white)](https://www.conventionalcommits.org/)
[![Plugins](https://img.shields.io/badge/plugins-2-364fc7)](#what-is-here)

</div>

---

> **Aranea** is Latin for the orb-weaver. She builds in one pass, sits still, and reads the whole
> web through a single thread. The tools here are meant to work the same way: quiet until
> something touches them, and then precise about what it was.

> [!IMPORTANT]
> **This marketplace has been superseded by the one on
> [aranea-development.nl](https://aranea-development.nl/skills).** It carries the same plugins,
> plus the skills and prompts, under a marketplace named `aranea`.
>
> Nothing new is published here. This one keeps working, see [Doing nothing](#doing-nothing).

This repository is a marketplace, not a plugin. It holds no plugin code of its own, only the
manifest pointing at each plugin's own repository, so every plugin releases on its own cadence and
you add one marketplace rather than one per tool.

---

## Install

```bash
claude plugin marketplace add https://aranea-development.nl/plugins/marketplace.json
claude plugin install claude-timestamp@aranea
claude plugin install kanon@aranea
```

The same steps work as slash commands inside a session, if you do not have the standalone CLI:

```text
/plugin marketplace add https://aranea-development.nl/plugins/marketplace.json
/plugin install kanon@aranea
```

Hooks bind when a session starts, so start a new session after installing anything.

## Moving over

An install id carries the name of the marketplace it came from, and there is no redirect at that
level. Moving over means leaving the old one, adding the new one, and installing again:

```text
/plugin uninstall kanon
/plugin uninstall claude-timestamp
/plugin marketplace remove aranea-claude-tools
/plugin marketplace add https://aranea-development.nl/plugins/marketplace.json
/plugin install kanon@aranea
/plugin install claude-timestamp@aranea
```

Uninstall the plugins before you remove the marketplace. A plugin that loses the marketplace it
came from can no longer update itself.

## Doing nothing

This marketplace keeps working. Its manifest still points at each plugin's own repository, so if
you already added it you keep getting updates. The only thing you miss is what is published from
now on, which is the skills and prompts and anything added after them.

## What is here

### [claude-timestamp](https://github.com/AraneaDev/claude-timestamp)

**Every message stamped with the time it happened and how long it took.**

Puts your local time on every assistant message, shows how long each turn took, colours the slow
ones and names the tool that caused them, marks where you stepped away, and closes the session
with a summary of where its time actually went. Claude is told when each prompt was sent, so it
can reason about when things happened.

### [kanon](https://github.com/AraneaDev/kanon)

**Every rule governing this session, named, including the ones you thought loaded and didn't.**

Records every instruction file that loads into a session and says where each one came from: your
own `~/.claude` setup, the project, or a dependency that shipped a `CLAUDE.md` and never mentioned
it. Names the launch-time files you expected that never arrived, and admits when its own model of
the loader disagrees with what it observed.

## Adding a plugin

Add an entry to `.claude-plugin/marketplace.json` pointing at the plugin's own repository:

```json
{
  "name": "your-plugin",
  "source": { "source": "github", "repo": "AraneaDev/your-plugin" },
  "description": "One line, plain, no hype."
}
```

The plugin repository keeps its own `.claude-plugin/plugin.json` and needs no marketplace manifest
of its own. Bump the plugin count badge above while you are here.

## License

MIT.
