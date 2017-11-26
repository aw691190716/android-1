
for envf in `test -d device && find -L device -maxdepth 4 -name 'envsetup.sh' 2> /dev/null | sort` \
         `test -d vendor && find -L vendor -maxdepth 4 -name 'envsetup.sh' 2> /dev/null | sort` \
         `test -d product && find -L product -maxdepth 4 -name 'envsetup.sh' 2> /dev/null | sort`
do
    echo "including $envf"
    . $envf
done
unset envf

function finds()
{
    find . -name .repo -prune -o -name .git -prune -o -name out -prune -o -name .ccache -prune -o -type f -name "*" \
        -exec grep --color -n "$@" {} +
}

function mka() {
    local T=$(gettop)
    if [ "$T" ]; then
        case `uname -s` in
            Darwin)
                make -C $T -j `sysctl hw.ncpu|cut -d" " -f2` "$@"
                ;;
            *)
                make -C $T -j$(grep "^processor" /proc/cpuinfo | wc -l) "$@"
                ;;
        esac

    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function build() {
    croot
    export BUILD_NUMBER=$(date +%Y%m%d)
    local start=`date '+%Y-%m-%d-%H-%M'`
    mkdir -p $OUT_DIR/log
    lunch $1
    if [ x"$2" == x ]; then
        mka otapackage 2>&1|tee $OUT_DIR/log/log-$start-.txt
    else
        if [ x"$3" == x"dellog" ]; then
            rm -rf $OUT_DIR/log/log-*
        fi
        mka $2 2>&1|tee $OUT_DIR/log/log-$start-.txt
    fi
    local end=`date '+%Y-%m-%d-%H-%M'`
    mv $OUT_DIR/log/log-$start-.txt $OUT_DIR/log/log-$start-$end.txt
}

function buildshutdown() {
    build $@
    shutdown -h +5
}

function applypath() {
    unset cherries
    local cherries=$(echo $(get_build_var PATH_CHERRIES))
    if [ -z "${cherries}" ]; then
        echo -e "Nothing to cherry-pick!"
    else
        pathpick -a -i ${cherries}
    fi
   unset cherries
}

function pathpick() {
    echo "repo pick" $@
    $(gettop)/vendor/google/build/tools/repopick.py -s auto $@
}

function flashboot()
{
    if [ ! -e "$OUT/boot.img" ];
    then
        echo "No boot.img found. Run make bootimage first."
        return 1
    fi
    adb reboot-bootloader
    fastboot flash boot $OUT/boot.img
    fastboot reboot
}

export OUT_DIR=$(gettop)/out
export WITH_CM_CHARGER=false
export USE_CCACHE=1
export CCACHE_DIR=.ccache
prebuilts/misc/linux-x86/ccache/ccache -M 50G

# Android specific JACK args
if [ -n "$JACK_SERVER_VM_ARGUMENTS" ] && [ -z "$ANDROID_JACK_VM_ARGS" ]; then
    export ANDROID_JACK_VM_ARGS=$JACK_SERVER_VM_ARGUMENTS
fi
