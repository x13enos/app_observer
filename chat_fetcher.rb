# frozen_string_literal: true

require "bundler/setup"

require "dotenv/load"
require "httpx"
require "json"
require "socket"

def env!(key)
  ENV[key] || abort("Missing ENV var #{key}. Set it in your shell or add it to a .env file.")
end

HTTP = HTTPX.plugin(:follow_redirects).with(ip_families: [Socket::AF_INET], resolver_class: :system)

TG_TOKEN = env!("TG_TOKEN")
CHAT_IDS_FILE = "chat_ids.txt".freeze

# Fetch latest updates from Telegram
puts "Fetching Telegram updates..."
tg_url = "https://api.telegram.org/bot#{TG_TOKEN}/getUpdates"
response = HTTP.get(tg_url)

if response.status != 200
  abort("Failed to fetch updates: #{response.status}")
end

updates = response.json["result"]
puts "Found #{updates.length} updates"

# Extract unique chat IDs
chat_ids = updates
  .filter_map { |update| update.dig("message", "chat", "id") }
  .uniq

puts "Extracted #{chat_ids.length} unique chat IDs"

# Store chat IDs in a file
File.write(CHAT_IDS_FILE, chat_ids.join("\n"))
puts "Saved chat IDs to #{CHAT_IDS_FILE}"

puts "Done!"
