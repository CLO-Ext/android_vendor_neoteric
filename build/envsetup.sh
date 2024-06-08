function __print_aospa_functions_help() {
cat <<EOF
Additional Paranoid Android functions:
- clodiff:         Utility to diff CLO history to AOSPA.
- clomerge:        Utility to merge CLO tags.
- repopick:        Utility to fetch changes from Gerrit.
- sort-blobs-list: Sort proprietary-files.txt sections with LC_ALL=C.
EOF
}

red='\033[0;31m'
nocol='\033[0m'

function clodiff()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/aospa/build/tools/diff-clo.py $target_branch
}

function clomerge()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/aospa/build/tools/merge-clo.py $target_branch
}

function sort-blobs-list() {
    T=$(gettop)
    $T/tools/extract-utils/sort-blobs-list.py $@
}

export SKIP_ABI_CHECKS="true"

if [ $(ls ${ANDROID_BUILD_TOP}/certs 2>/dev/null | wc -l ) -eq 0 ]; then
    echo -e "$red**********************************************"
    echo    "   SIGNING KEYS NOT FOUND!, GENERATING THEM"
    echo -e "**********************************************$nocol"
    certs_dir="${ANDROID_BUILD_TOP}/certs"
    mkdir -p "$certs_dir"
    subject=""
    echo "Sample subject: '/C=US/ST=California/L=Mountain View/O=Android/OU=Android/CN=Android/emailAddress=android@android.com'"
    echo "$red C should only have 2 characters for ex:- C=IN not C=IND $nocol"
    echo "Now enter subject details for your keys:"
    for entry in C ST L O OU CN emailAddress; do
        echo -n "$entry:"
        read -r val
        subject+="/$entry=$val"
    done
    keys=( releasekey platform shared media networkstack testkey sdk_sandbox bluetooth )
    for key in ${keys[@]}; do
        ./development/tools/make_key "$certs_dir"/$key "$subject"
    done
fi
