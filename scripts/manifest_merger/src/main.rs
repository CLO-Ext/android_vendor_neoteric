/*
 * Copyright (C) 2022 FlamingoOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

use clap::Parser;
use manifest::Manifest;
use merge::merge_aosp;
use reqwest::Client;
use std::option::Option;

mod git;
#[macro_use]
mod macros;
mod manifest;
mod merge;

#[derive(Parser)]
struct Args {
    /// Source directory of the rom
    #[arg(long, default_value_t = String::from("./"))]
    source_dir: String,

    /// Location of the manifest dir
    #[arg(short, long, default_value_t = String::from("./.repo/manifests"))]
    manifest_dir: String,

    /// CLO system tag that should be merged across the rom
    #[arg(short, long)]
    system_tag: Option<String>,

    /// CLO system tag that should be merged across the rom
    #[arg(short, long)]
    vendor_tag: Option<String>,

    /// Number of threads to use.
    #[arg(short, long, default_value_t = num_cpus::get())]
    threads: usize,

    /// Whether to push the changes to the remote
    #[arg(short, long, default_value_t = false)]
    push: bool,

    #[arg(long)]
    aosp: bool,
}

#[tokio::main]
async fn main() -> Result<(), String> {
    let args = Args::parse();

    if !args.system_tag.is_some() && !args.vendor_tag.is_some() {
        return Err(String::from(
            "No tags specified. Specify atleast one of -s or -v",
        ));
    }

    let system_manifest = args
        .system_tag
        .as_ref()
        .map(|tag| Manifest::new(&args.manifest_dir, "system", Some(tag.to_owned())));
    let vendor_manifest = args
        .vendor_tag
        .as_ref()
        .map(|tag| Manifest::new(&args.manifest_dir, "vendor", Some(tag.to_owned())));

    if args.aosp && system_manifest.is_some() {
        merge_aosp(&args.source_dir, &system_manifest, args.threads, args.push)?;
        return Ok(());
    }

    let client = Client::new();

    let (system_update, vendor_update) = futures::join!(
        manifest::update(&client, &system_manifest),
        manifest::update(&client, &vendor_manifest)
    );
    system_update?;
    vendor_update?;

    let default_manifest = Manifest::new(&args.manifest_dir, "default", None);
    manifest::update_default(
        default_manifest,
        &system_manifest,
        &vendor_manifest,
        args.push,
    )?;

    let neoteric_manifest = Manifest::new(&args.manifest_dir, "neoteric", None);
    merge::merge_upstream(
        &args.source_dir,
        neoteric_manifest,
        &system_manifest,
        &vendor_manifest,
        args.threads,
        args.push,
    )?;

    Ok(())
}
