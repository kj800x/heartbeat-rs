use reqwest::blocking::Client;
use std::time::Duration;
use std::{env, thread};

fn main() {
    let client = Client::builder()
        .pool_max_idle_per_host(0)
        .build()
        .expect("Failed to create client");

    loop {
        let response = client
            .get(env::var("HEARTBEAT_URL").expect("HEARTBEAT_URL environment variable must be set"))
            .send()
            .expect("Failed to send request");

        // println!("{:?}", response.status());

        if response.status().is_success() {
            println!("beat");
        } else {
            panic!("HEARTBEAT_URL failed");
        }

        thread::sleep(Duration::from_secs(
            env::var("HEARTBEAT_SLEEP")
                .expect("HEARTBEAT_SLEEP environment variable must be set")
                .parse::<u64>()
                .expect("HEARTBEAT_SLEEP environment variable must be a number in seconds"),
        ));
    }
}
