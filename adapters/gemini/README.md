# SpecOS — Gemini CLI adapter

Gemini CLI loads custom commands from `~/.gemini/commands/` as `.toml` files.

The installer generates these files dynamically from `skills/*.md`. Format:

```toml
description = "SpecOS: <skill description>"
prompt = '''
<full skill content>
'''
```

TOML literal multiline strings (`'''`) require no escaping — raw markdown content is preserved as-is.

After install, commands are available as `/specos-lead`, `/specos-dev`, etc.

If commands don't appear after install, run `/commands reload` inside Gemini CLI.
