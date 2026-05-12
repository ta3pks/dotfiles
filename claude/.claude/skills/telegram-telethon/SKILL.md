---
name: telegram-telethon
description: Send messages, read chats, and look up Telegram contacts using a Telethon user session (not the bot API). Use when the user asks to message a Telegram contact, read a TG chat, or anything requiring user-level Telegram access.
version: 1.0
---

# Telegram Telethon — User-Session Messaging

Telethon operates as a real user account (MTProto), not a bot. Use it whenever the action requires user-level access — messaging contacts who never started a bot chat, reading conversation history, listing dialogs, looking up contacts by name.

## When to Use

- Sending messages to contacts (with or without prior bot interaction)
- Looking up contacts / dialogs by name or ID
- Reading recent messages from a chat/channel
- Downloading media (voice notes, photos) from a chat
- Any Telegram action requiring user-level access, not bot-level

## Credentials & Session

The operator must provision two things locally before this skill works:

- **API credentials JSON** with `api_id` and `api_hash` (from <https://my.telegram.org>)
- **Session file** path where Telethon stores the authenticated user session (`.session` SQLite)

Ask the operator for the exact paths during setup; do not assume. Common locations: `~/.config/telethon/`, `~/.telegram/`, or a project-local `./.tg/`. Once authorized once interactively, the session file is reusable headlessly.

```python
import json
from telethon.sync import TelegramClient

CRED_PATH = '/path/to/telegram-api.json'   # operator-provided
SESSION = '/path/to/telegram-session'      # operator-provided (no .session suffix)

with open(CRED_PATH) as f:
    cred = json.load(f)

client = TelegramClient(SESSION, cred['api_id'], cred['api_hash'])
client.connect()
# ... do work ...
client.disconnect()
```

If the session file does not exist yet, `client.start()` (or `client.connect()` + sign-in flow) prompts for phone number + login code. That must run interactively at least once — do not attempt this autonomously.

## List Dialogs (Recent Chats)

Fastest way to discover entity IDs for a contact:

```python
import json
from telethon.sync import TelegramClient

with open(CRED_PATH) as f: cred = json.load(f)
client = TelegramClient(SESSION, cred['api_id'], cred['api_hash'])
client.connect()

for dialog in client.iter_dialogs(limit=20):
    entity_id = dialog.entity.id
    name = dialog.name or 'Unknown'
    is_bot = getattr(dialog.entity, 'bot', False)
    msgs = client.get_messages(dialog.entity, limit=1)
    last_date = msgs[0].date.strftime('%m-%d %H:%M') if msgs else 'never'
    last_text = (msgs[0].text or '[media]')[:60] if msgs else ''
    print(f'[{entity_id}] {name} (bot={is_bot}) last=[{last_date}] {last_text}')

client.disconnect()
```

## Read Conversation History

```python
msgs = client.get_messages(ENTITY_ID, limit=30)  # int ID, username, or 'me'
for m in reversed(msgs):  # reverse for chronological order
    time = m.date.strftime('%m-%d %H:%M')
    text = (m.text or '[media]')[:500]
    sender = 'Me' if m.out else 'Other'
    print(f'[{time}] {sender}: {text}')
```

`'me'` = Saved Messages (your own self-chat), NOT any other entity. Use the dialog listing above to find real entity IDs.

## Send Message

```python
client.send_message(ENTITY_ID, "Hello!")
```

`send_message` accepts integer IDs, usernames (`'durov'`), or full entity objects. Markdown rendering: pass `parse_mode='md'` if you need formatting.

## Search Contacts

```python
from telethon.tl.functions.contacts import GetContactsRequest

contacts = client(GetContactsRequest(hash=0))  # hash=0 forces full refresh
for c in contacts.contacts:
    user = next((u for u in contacts.users if u.id == c.user_id), None)
    if user:
        print(f'{user.id}: {(user.first_name or "")} {(user.last_name or "")}')
```

## Download Media (Voice Messages, Photos)

```python
msgs = client.get_messages(ENTITY_ID, limit=10)
for m in msgs:
    if m.media and not m.out:
        path = client.download_media(m, file='/tmp/tg_media')
        if path:
            print(f'Downloaded: {path}')
```

Voice notes come down as `.oga` (Ogg/Opus). To transcribe, convert to WAV via `ffmpeg -i input.oga -ar 16000 output.wav` and send to your transcription provider of choice (Whisper API, local whisper-cli, etc.).

## Pitfalls

- **Sandbox/agent environments often lack `telethon`.** Run via `python3 -c "..."` or `python3 /tmp/script.py` on the host — not inside ephemeral execution sandboxes. If you see `ModuleNotFoundError: No module named 'telethon'`, install with `pip install --user telethon` or use the host shell.
- **Quoting hell with non-ASCII text + emojis.** Write scripts to `/tmp/foo.py` and `python3 /tmp/foo.py` rather than wrestling with shell quoting for Russian/Turkish/emoji message bodies.
- **Bot API ≠ user session.** Bot API (`python-telegram-bot`, `aiogram`) cannot message users who haven't started a chat with the bot. Telethon user session has no such restriction. If the task is bot-level (manage bot commands, webhook handling) use a bot library with the bot token instead.
- **`get_messages('me')` returns Saved Messages**, not "messages addressed to me from anywhere". Don't confuse the two.
- **`GetContactsRequest(hash=0)`** forces a full contact refresh; non-zero hash returns a delta from the server's cached state.
- **Bot↔user conversation history is not fully readable from a user session.** Telethon sees one side (user → bot messages); bot-side replies appear via the dialog with the bot but two-way history may be incomplete. If you need full bot conversation logs, query the bot's own datastore.
- **Active/in-progress sessions** of any bot framework usually live in memory and are not flushed to disk until session-end. Don't expect to read live state from an on-disk database.
- **Voice transcription endpoint flakiness.** Cloud STT providers occasionally 403 specific source IPs (residential, VPN, datacenter). If one provider rejects, try a different network path or local Whisper before declaring it broken — and retest periodically since blocks expire.

## Async vs Sync

Telethon supports both. `from telethon.sync import TelegramClient` gives a sync wrapper (blocks). For async, use `from telethon import TelegramClient` and `await client.connect()`, `await client.get_messages(...)`, etc. Pick one mode per script; mixing causes deadlocks.

## Polling Pattern (Watching for New Messages)

For cron-style polling of a chat:

1. Keep a **state file** with the last processed message ID or timestamp: `~/.local/state/tg-<chat>-last.txt`
2. On each poll: `client.get_messages(ENTITY, min_id=last_seen_id)` (or filter by date)
3. Process new messages, then atomically write the new high-water mark
4. Skip silently when nothing new — do not spam logs/notifications

Use `min_id` rather than `limit=N` for correctness — `limit` slides when new messages arrive and you may miss or double-process.
