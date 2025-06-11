# =================================================
# Stage 1: Build statically linked binary with musl
# =================================================
FROM rust:1.85-alpine AS builder

WORKDIR /usr/src

# Install required build dependencies
RUN apk add --no-cache musl-dev pkgconfig openssl-dev libc-dev gcc
RUN rustup target add x86_64-unknown-linux-musl

# Pre-cache rust dependencies
RUN cargo new heartbeat-rs
WORKDIR /usr/src/heartbeat-rs
COPY Cargo.toml Cargo.lock ./
RUN cargo build --release --target x86_64-unknown-linux-musl

# Copy actual source and rebuild
COPY . .
RUN touch src/main.rs && cargo build --release --target x86_64-unknown-linux-musl


# =====================================================
# Stage 2: Copy static binary into minimal Alpine image
# =====================================================
FROM alpine:latest

# Just to be safe: ensure we have minimal runtime utilities (not strictly needed)
RUN apk add --no-cache ca-certificates

COPY --from=builder /usr/src/heartbeat-rs/target/x86_64-unknown-linux-musl/release/heartbeat-rs /usr/local/bin/heartbeat-rs

ENTRYPOINT ["/usr/local/bin/heartbeat-rs"]
