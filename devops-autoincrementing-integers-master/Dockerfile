# Use official Ruby image as base
FROM ruby:2.6.3-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    postgresql-client \
    tzdata \
    nodejs \
    yarn \
    git

# Set working directory
WORKDIR /app

# Copy Gemfile and install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle config set --local deployment 'true' \
    && bundle config set --local path 'vendor/bundle' \
    && bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Precompile assets (if any)
RUN bundle exec rake assets:precompile RAILS_ENV=production

# Create production stage
FROM ruby:2.6.3-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-dev \
    postgresql-client \
    tzdata \
    nodejs

# Set working directory
WORKDIR /app

# Copy vendor bundle from base stage
COPY --from=base /app/vendor/bundle /app/vendor/bundle

# Copy application code
COPY . .

# Copy precompiled assets
COPY --from=base /app/public/assets /app/public/assets

# Set environment variables
ENV RAILS_ENV=production
ENV RAILS_SERVE_STATIC_FILES=true
ENV RAILS_LOG_TO_STDOUT=true

# Create non-root user
RUN addgroup -g 1000 -S app && \
    adduser -u 1000 -S app -G app

# Change ownership of the app directory
RUN chown -R app:app /app
USER app

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Start the application
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
