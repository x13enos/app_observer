# app-observer

A lightweight Ruby uptime monitor that pings your apps and sends Telegram alerts when any go down.

## How it works

1. **Fetches chat IDs** — Collects Telegram chat IDs from users who have messaged your bot
2. **Pings apps** — Makes HTTP requests to each app in your list
3. **Sends alerts** — Notifies all registered Telegram chats when an app is unreachable

## Setup

### Prerequisites

- Ruby 3.4+
- Bundler

### Local run

1. Install dependencies:

```bash
bundle install
```

2. Create a `.env` file (gitignored) with:

```bash
TG_TOKEN=your_telegram_bot_token
LIST_OF_APPS=example.com,api.example.com,app.example.com
```

3. Fetch chat IDs (users must message your bot first):

```bash
ruby chat_fetcher.rb
```

4. Run the observer:

```bash
ruby observer.rb
```

## GitHub Actions

The workflow runs every 5 minutes and can also be triggered manually.

Add these repository secrets:

| Secret | Description |
|--------|-------------|
| `TG_TOKEN` | Telegram Bot API token |
| `LIST_OF_APPS` | Comma-separated list of domains to monitor |

Chat IDs are cached between workflow runs.

## Files

| File | Purpose |
|------|---------|
| `observer.rb` | Main script — pings apps and sends alerts |
| `chat_fetcher.rb` | Fetches chat IDs from Telegram bot updates |
| `chat_ids.txt` | Stores registered chat IDs (auto-generated) |

