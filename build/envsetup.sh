function __print_neoteric_functions_help() {
cat <<EOF
Additional Neoteric OS functions:
- mergeclo: Merge in a newer caf tag across the source
              usage: mergeclo --system-tag <clo tag> --vendor-tag <clo tag>
EOF
}

function mergeclo() {
    ./vendor/neoteric/scripts/manifest_merger/target/release/manifest_merger $*
}

export SKIP_ABI_CHECKS="true"
