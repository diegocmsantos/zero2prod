# Builder stage
FROM rust:1.83.0 AS builder
WORKDIR /app
RUN apt-get update && apt-get install lld clang -y
COPY . .
ENV SQLX_OFFLINE=true
RUN cargo sqlx prepare
RUN cargo build --release
# Runtime stage
FROM rust:1.83.0-slim AS runtime
WORKDIR /app
# Copy the compiled binary from the builder environment
# to our runtime environment
COPY --from=builder /app/target/release/zero2prod zero2prod
# We need the configuration file at runtime!
COPY configuration configuration
ENV APP_ENVIRONMENT=production
ENTRYPOINT ["./zero2prod"]
