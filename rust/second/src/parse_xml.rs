use anyhow::anyhow;

#[cxx::bridge(namespace = "second")]
mod ffi {
    extern "Rust" {
        #[cxx_name = "getRoot"]
        fn get_root() -> Result<Root>;
    }

    #[derive(Debug, Deserialize)]
    struct Root {
        foo: Foo,
        bar: Bar,
    }

    #[derive(Debug, Deserialize)]
    struct Foo {
        integer: i32,
        vec: Vec<String>,
    }

    #[derive(Debug, Deserialize)]
    struct Bar {
        #[serde(rename = "$value")]
        value: f32,
        byte: u8,
    }
}

fn get_root() -> anyhow::Result<ffi::Root> {
    let xml = r#"
        <root>
            <foo integer = "100">
                <vec>hello</vec>
                <vec>world</vec>
            </foo>
            <bar byte = "255">3.14</bar>
        </root>
    "#;
    quick_xml::de::from_str(xml).map_err(|e| anyhow!("{}", e))
}
