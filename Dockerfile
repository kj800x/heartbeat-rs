FROM rust:1.85 AS builder

WORKDIR /usr/src/heartbeat-rs
COPY . .

RUN cargo install --path .


FROM alpine:latest

COPY --from=builder /usr/src/heartbeat-rs/target/release/heartbeat-rs heartbeat-rs

CMD ["heartbeat-rs"]
