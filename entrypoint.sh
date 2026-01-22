#!/bin/sh
set -e

echo "Fetching chat IDs..."
ruby chat_fetcher.rb

echo "Running observer..."
ruby observer.rb
