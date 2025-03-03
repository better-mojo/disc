use std::collections::HashMap;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let resp = reqwest::get("https://httpbin.org/ip")
        .await?
        .json::<HashMap<String, String>>()
        .await?;

    println!("http get response:\n{resp:#?}");


    // ref: https://docs.rs/reqwest/latest/reqwest/#forms
    // This will POST a body of `foo=bar&baz=quux`
    let params = [("foo", "bar"), ("baz", "quux")];
    let client = reqwest::Client::new();
    let res1 = client.post("http://httpbin.org/post")
        .form(&params)
        .send()
        .await?;

    println!("http post + form response:\n{res1:#?}");


    // ref: https://docs.rs/reqwest/latest/reqwest/#json
    // This will POST a body of `{"lang":"rust","body":"json"}`
    let mut map = HashMap::new();
    map.insert("lang", "rust");
    map.insert("body", "json");

    let client = reqwest::Client::new();
    let res2 = client.post("http://httpbin.org/post")
        .json(&map)
        .send()
        .await?;

    println!("http post + json response:\n{res2:#?}");


    Ok(())
}
