# frozen_string_literal: true

require "bundler/setup"

require "dotenv/load"
require "httpx"
require "socket"

def env!(key)
  ENV[key] || abort("Missing ENV var #{key}. Set it in your shell or add it to a .env file.")
end

HTTP = HTTPX.plugin(:follow_redirects)

LIST_OF_APPS = env!("LIST_OF_APPS")
TG_TOKEN = env!("TG_TOKEN")

# 1. Ping all the apps to see if they are alive, and collect the results
puts "Pinging apps..."
apps = LIST_OF_APPS.split(",")
results = []
apps.each do |app|
  app = app.strip
  resp = HTTP.get("https://#{app}")
  results << { app: app, status: resp.status == 200 ? "alive" : "dead" }
end

# 2. For each app that is not alive, send a message to all the Telegram chats
dead_apps = results.select { |r| r[:status] == "dead" }

if dead_apps.empty?
  puts "All apps are alive!"
  exit
end

puts "Dead apps: #{dead_apps.map { |r| r[:app] }.join(", ")}"

chats = File.read("chat_ids.txt").split("\n").map(&:to_i).reject(&:zero?)
puts "Sending to #{chats.length} Telegram chats..."

dead_apps.each do |result|
  chats.each do |chat|
    tg_url = "https://api.telegram.org/bot#{TG_TOKEN}/sendMessage"
    HTTP.post(
      tg_url,
      json: { chat_id: chat, text: "⚠️ App *#{result[:app]}* is not alive", parse_mode: "Markdown" }
    )
  end
end

puts "Done!"