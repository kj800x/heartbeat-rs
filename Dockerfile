FROM rust:1.85

WORKDIR /usr/src/heartbeat-rs
COPY . .

RUN cargo install --path .

CMD ["heartbeat-rs"]
