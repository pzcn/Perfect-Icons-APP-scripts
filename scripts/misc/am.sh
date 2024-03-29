#!/data/data/com.termux/files/usr/bin/sh
TERMUX_AM_VERSION=0.6.0
AM_APK_PATH="$START_DIR/online-scripts/misc/am.apk"

is_int() {
    case "$1" in
        ''|*[!0-9]*) return 1;;
        *) return 0;;
    esac
}

if [ "$1" = "--version" ]; then
    echo "$TERMUX_AM_VERSION"
    exit 0
fi

# If sdk version is not exported by app, then get value with getprop instead.
if ! is_int "$ANDROID_SDK"; then
    ANDROID_SDK="$(getprop "ro.build.version.sdk")"
    if ! is_int "$ANDROID_SDK"; then
        echo "Failed to get android build version sdk with getprop" 1>&2
        exit 1
    fi
fi

user="$(id -u)"

# Do not use TermuxAm for broadcast commands on Android >= 14 since it
# will trigger the `Sending broadcast <action> with resultTo requires resultToApp`
# exception in logcat by ActivityManagerService and will hang the
# app_process command forever since no result callback is received
# by TermuxAm `IIntentReceiver.performReceive()`.
# - https://github.com/termux/TermuxAm/issues/9#issuecomment-1649867810
if [ "$ANDROID_SDK" -ge 34 ] && [ "$1" = "broadcast" ]; then
    is_int "$user" || user=0
    shift 1 # Remove the first `broadcast` argument

    # Use a subshell with specified redirection to prevent
    # `cmd: Failure calling service activity` error on Android >= 8
    # due to selinux restrictions where the `system_server` source
    # domain does not have access to `untrusted_app_all_devpts`
    # `pty` devices when a source transition is made from `untrusted_app*`
    # domain when `/system/bin/am` is executed.
    # - https://github.com/termux/termux-packages/discussions/8292#discussioncomment-5102555
    output="$(/system/bin/am broadcast --user "$user" "$@" 2>&1 </dev/null)"
    exit_code=$?
    # Do not log `echo: I/0 error` if stdout is closed
    echo "$output" 2>/dev/null
    exit $exit_code
fi

# If apk file is writable and current effective user is not root (0),
# system (1000) and shell (2000), then remove write bit from apk
# permissions for current used for Android >= 14 since it will trigger
# the `SecurityException: Writable dex file '/path/to/am.apk' is not allowed.`
# exception in logcat by SystemClassLoader and cause a SIGABRT for the
# app_process.
# - https://github.com/termux/termux-packages/issues/16255
# - https://developer.android.com/about/versions/14/behavior-changes-14#safer-dynamic-code-loading
# - https://cs.android.com/android/_/android/platform/art/+/03ac3eb0fc36be97f301ac60e85e1bb7ca52fa12
# - https://cs.android.com/android/_/android/platform/art/+/d3a8a9e960d533f39b6bafc785599eae838a6351
# - https://cs.android.com/android/_/android/platform/art/+/03ac3eb0fc36be97f301ac60e85e1bb7ca52fa12:runtime/native/dalvik_system_DexFile.cc;l=335
if [ -w "$AM_APK_PATH" ]; then
    if [ "$user" != "0" ] && [ "$user" != "1000" ] && [ "$user" != "2000" ]; then
        chmod 0400 "$AM_APK_PATH" || exit $?
    fi
fi

export CLASSPATH="$AM_APK_PATH"
unset LD_LIBRARY_PATH LD_PRELOAD
exec /system/bin/app_process -Xnoimage-dex2oat / com.termux.termuxam.Am "$@"
