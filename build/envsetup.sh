function __print_neoteric_functions_help() {
cat <<EOF
Additional Neoteric functions:
- clodiff:         Utility to diff CLO history to Neoteric.
- clomerge:        Utility to merge CLO tags.
- roomservice:     Utility to sync device dependencies.
- sort-blobs-list: Sort proprietary-files.txt sections with LC_ALL=C.
EOF
}

red='\033[0;31m'
cyan='\033[0;36m'
nocol='\033[0m'

function clodiff()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/neoteric/build/tools/diff-clo.py $target_branch
}

function clomerge()
{
    target_branch=$1
    set_stuff_for_environment
    T=$(gettop)
    python3 $T/vendor/neoteric/build/tools/merge-clo.py $target_branch
}

function roomservice() {
    if [ -z "$TARGET_PRODUCT" ]; then
        echo -e "$red*******************************************************************************************************"
        echo    " SEEMS LIKE LUNCH COMMAND HAS NOT BEEN EXECUTED YET, EXECUTE LUNCH TO PROPERLY SETUP BUILD ENVIRONMENT "
        echo -e "*******************************************************************************************************$nocol"
        return
    fi
    T=$(gettop)
    TARGET_MANUFACTURER=$(get_build_var PRODUCT_MANUFACTURER 2>/dev/null)
    if [ -f "device/$TARGET_MANUFACTURER/$TARGET_PRODUCT/neoteric.dependencies" ]; then
        python3 $T/vendor/neoteric/build/tools/roomservice.py device/$TARGET_MANUFACTURER/$TARGET_PRODUCT
    else
    	echo -e "$red*******************************************************************************************"
        echo    " MAKE SURE TO SETUP ROOMSERVICE CONFIGURATION IN DEVICE TREES BEFORE EXECUTING ROOMSERVICE "
        echo -e "*******************************************************************************************$nocol"
        return
    fi
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
    echo -e "$cyan***********************************************************" 
    echo    "  C should only have 2 characters for ex:- C=IN not C=IND"
    echo -e "***********************************************************$nocol"
    echo "Now enter subject details for your keys:"
    for entry in C ST L O OU CN emailAddress; do
        echo -n "$entry:"
        read -r val
        subject+="/$entry=$val"
    done
    keys=( releasekey platform shared media networkstack testkey sdk_sandbox bluetooth nfc )
    for key in ${keys[@]}; do
        ./development/tools/make_key "$certs_dir"/$key "$subject"
    done
fi

export FILE_NAME_TAG=eng.nobody
export BUILD_USERNAME=nobody
export BUILD_HOSTNAME=android-build

if [ -n "$TARGET_PRODUCT" ]; then
    roomservice
fi
