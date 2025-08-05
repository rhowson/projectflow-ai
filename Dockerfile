# ProjectFlow AI - Production Dockerfile
# Multi-stage build for optimized production deployment

# Stage 1: Build the Flutter web app
FROM cirrusci/flutter:stable AS builder

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Build arguments for environment variables
ARG CLAUDE_API_KEY
ARG USE_DEMO_MODE=false
ARG ENVIRONMENT=production
ARG DEBUG_MODE=false
ARG ENABLE_ANALYTICS=true
ARG ENABLE_CRASHLYTICS=true

# Build the web app for production
RUN flutter build web --release \
    --web-renderer canvaskit \
    --dart-define=CLAUDE_API_KEY=$CLAUDE_API_KEY \
    --dart-define=USE_DEMO_MODE=$USE_DEMO_MODE \
    --dart-define=ENVIRONMENT=$ENVIRONMENT \
    --dart-define=DEBUG_MODE=$DEBUG_MODE \
    --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
    --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS

# Stage 2: Production server
FROM nginx:alpine

# Copy built web app
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Create non-root user
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Set permissions
RUN chown -R appuser:appgroup /usr/share/nginx/html && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/ || exit 1

# Start nginx
CMD ["nginx", "-g", "daemon off;"]