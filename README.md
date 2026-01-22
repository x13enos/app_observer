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

## Docker (Server Deployment)

### 1. Pull or build the image

```bash
# Option A: Pull from registry
docker pull x3enos/app-observer

# Option B: Build locally
git clone <your-repo-url>
cd app-observer
docker build -t app-observer .
```

### 2. Create the environment file

Create `/home/your-user/app-observer/.env`:

```bash
TG_TOKEN=your_telegram_bot_token
LIST_OF_APPS=example.com,api.example.com,app.example.com
```

### 3. Create chat_ids.txt

```bash
touch /home/your-user/app-observer/chat_ids.txt
```

### 4. Test manually

```bash
docker run --rm \
  --env-file /home/your-user/app-observer/.env \
  --mount type=bind,source=/home/your-user/app-observer/chat_ids.txt,target=/app/chat_ids.txt \
  x3enos/app-observer
```

### 5. Set up cron

Run this command to add a cron job that runs every 5 minutes:

```bash
(crontab -l 2>/dev/null; echo "*/5 * * * * docker run --rm --env-file /home/your-user/app-observer/.env --mount type=bind,source=/home/your-user/app-observer/chat_ids.txt,target=/app/chat_ids.txt x3enos/app-observer >> /var/log/app-observer.log 2>&1") | crontab -
```

Replace `/home/your-user/app-observer/` with your actual path before running.
That's an example with my version - x3enos/app-observer, you can also change this to your local build.

Verify it was added:

```bash
crontab -l
```

Check logs:

```bash
tail -f /var/log/app-observer.log
```

### Troubleshooting

| Error | Solution |
|-------|----------|
| `bad URI (is not URI?)` | Remove quotes from values in `.env` file |
| `No such file` for chat_ids.txt | Ensure the file exists before mounting |

## GitHub Actions

The workflow runs every hour and can also be triggered manually.

**Limitation:** GitHub Actions has throttling on scheduled workflows. For public repositories, scheduled workflows may be delayed or skipped during periods of high load. Additionally, GitHub may disable scheduled workflows on repositories with no activity for 60 days. This makes Actions unsuitable for frequent monitoring (e.g., every 5 minutes) — use the Docker/cron approach instead for more reliable, higher-frequency checks.

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
| `Dockerfile` | Container image for server deployment |
| `entrypoint.sh` | Runs both scripts in sequence |

