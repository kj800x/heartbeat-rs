use reqwest::blocking::Client;
use std::time::Duration;
use std::{env, thread};

fn main() {
    // Configuration errors are fatal: fail fast at startup.
    let url = env::var("HEARTBEAT_URL").expect("HEARTBEAT_URL environment variable must be set");
    let sleep = Duration::from_secs(
        env::var("HEARTBEAT_SLEEP")
            .expect("HEARTBEAT_SLEEP environment variable must be set")
            .parse::<u64>()
            .expect("HEARTBEAT_SLEEP environment variable must be a number in seconds"),
    );

    let client = Client::builder()
        .pool_max_idle_per_host(0)
        .timeout(Duration::from_secs(30))
        .build()
        .expect("Failed to create client");

    // Push failures (e.g. Kuma outage) are transient: log and keep beating.
    loop {
        match client.get(&url).send() {
            Ok(response) if response.status().is_success() => println!("beat"),
            Ok(response) => eprintln!("heartbeat push failed: HTTP {}", response.status()),
            Err(err) => eprintln!("heartbeat push failed: {err}"),
        }

        thread::sleep(sleep);
    }
}
