function __print_zephyrus_functions_help() {
cat <<EOF
Additional Paranoid Android functions:
- clomerge:        Utility to merge CLO tags.
- repopick:        Utility to fetch changes from Gerrit.
- sort-blobs-list: Sort proprietary-files.txt sections with LC_ALL=C.
EOF
}

function clomerge()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/zephyrus/build/tools/merge-clo.py $target_branch
}

export SKIP_ABI_CHECKS="true"
