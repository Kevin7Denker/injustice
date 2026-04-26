# ── Stage 1: Build Flutter web ──
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy dependency files first for layer caching
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the source
COPY . .

# Build optimized web release with CanvasKit renderer
RUN flutter build web --release --web-renderer canvaskit

# ── Stage 2: Serve with nginx ──
FROM nginx:alpine

# Remove default nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy the built Flutter web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Copy custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Railway injects PORT env var — nginx will read it
# Default to 8080 if not set
ENV PORT=8080

# Substitute $PORT into nginx config at runtime
CMD sh -c "envsubst '\$PORT' < /etc/nginx/conf.d/default.conf > /etc/nginx/conf.d/default.conf.tmp && \
    mv /etc/nginx/conf.d/default.conf.tmp /etc/nginx/conf.d/default.conf && \
    nginx -g 'daemon off;'"
