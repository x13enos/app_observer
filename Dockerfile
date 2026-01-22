FROM --platform=linux/amd64 ruby:3.4-slim

WORKDIR /app

# Install build dependencies for native gems
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy application
COPY observer.rb chat_fetcher.rb entrypoint.sh ./
RUN chmod +x entrypoint.sh

# Create empty chat_ids.txt if it doesn't exist
RUN touch chat_ids.txt

# Run both scripts: fetch chat IDs, then observe
CMD ["./entrypoint.sh"]
