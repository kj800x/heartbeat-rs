FROM rust:1.85 AS builder

WORKDIR /usr/src/heartbeat-rs

# Cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo 'fn main() { println!("placeholder"); }' > src/main.rs
RUN cargo build --release && rm -r src

# Copy actual source and build
COPY . .
RUN cargo build --release


FROM alpine:latest

# Install libgcc for unwinding support (used by Rust binaries with panic=unwind)
RUN apk add --no-cache libgcc

COPY --from=builder /usr/src/heartbeat-rs/target/release/heartbeat-rs /usr/local/bin/heartbeat-rs

CMD ["heartbeat-rs"]
