#!/bin/sh
# Runs the disk check code from disk_check.mod on hostile USB and blkid values.
# Usage: tests/test_disk_check_input.sh [path/to/disk_check.mod]
S="$(cd "$(dirname "${1:-amtm_modules/disk_check.mod}")" && pwd)/$(basename "${1:-amtm_modules/disk_check.mod}")"
T="${TMPDIR:-/tmp}/pr-test.$$"; mkdir -p "$T" || exit 1; trap 'rm -rf "$T"' EXIT; rc=0; cd "$T" || exit 1
ok() { echo "PASS $1"; }; no() { echo "FAIL $1"; rc=1; }
check() { if eval "$2"; then ok "$1"; else no "$1"; fi; }

# A crafted USB name is displayed, not run.
grep -E '^[[:space:]]*(eval mounts|eval mtddev|mtddev=)' "$S" > name.sh
usb_dev=sda; usb_name='x$(touch PWN1)'; thisdevsize='1.0 GB'; i=1; . ./name.sh
check "USB name is not run" "[ ! -e PWN1 ]"
check "USB name is shown as text" "[ \"\$mtddev\" = 'sda x\$(touch PWN1) (1.0 GB)' ]"
for name in 'a;touch PWN3' 'a`touch PWN3`' 'a&touch PWN3' 'a|touch PWN3' 'a"b' "a'b" 'a b  c' '$HOME' '*'; do
	usb_name="$name"; want="sda $name (1.0 GB)"; got="$( . ./name.sh 2>/dev/null; printf '%s' "$mtddev" )"
	check "USB name stays literal: $name" '[ "$got" = "$want" ] && [ ! -e PWN3 ]'
done

# blkid output can't add commands to the config, which disk check later sources.
grep -F 'echo blkidExclude="'"'"'$(echo "$exclusion"' "$S" | head -n 1 > uuid.sh
add=.; exclusion="x UUID=\"12ab-34cd\" y'; touch PWN2; '\""; . ./uuid.sh
( . ./disk_check.conf; echo "$blkidExclude" > value ) 2>/dev/null
check "blkid text is not run" "[ ! -e PWN2 ]"
check "UUID is kept" "grep -q 'UUID=\"12ab-34cd\"' value"

# A device with no UUID is still checked; an excluded UUID is still skipped.
{ grep -F 'if [ "$blkidExclude" ] && ' "$S" | head -n 1; echo 'echo EXCLUDED; fi'; } > skip.sh
blkidExclude='UUID="12ab-34cd" '; skip() { . ./skip.sh; }
blkid() { echo '/dev/sdz: TYPE="ext4"'; }
check "device with no UUID is checked" "[ -z \"\$(skip /dev/sdz)\" ]"
blkid() { echo '/dev/sdz: UUID="12ab-34cd" TYPE="ext4"'; }
check "excluded UUID is skipped" "[ \"\$(skip /dev/sdz)\" = EXCLUDED ]"
blkid() { :; }
check "device blkid can't read is checked" "[ -z \"\$(skip /dev/sdz)\" ]"
blkid() { echo '/dev/sdz: UUID="99ff-00aa" TYPE="ext4"'; }
check "device with another UUID is checked" "[ -z \"\$(skip /dev/sdz)\" ]"
for uuid in 1A2B-3C4D 0123456789ABCDEF 12345678-abcd-4ef0-9876-0123456789ab; do
	blkidExclude="UUID=\"aaaa-bbbb\" UUID=\"$uuid\" "
	blkid() { echo "/dev/sdz: LABEL=\"My Disk\" UUID=\"$uuid\" TYPE=\"vfat\""; }
	check "exclusion matches a $(printf '%s' "$uuid" | wc -c | tr -d ' ') character UUID after a label" "[ \"\$(skip /dev/sdz)\" = EXCLUDED ]"
done

# Damage e2fsck -p can't repair is reported.
grep -F 'errDCL=$(tail' "$S" | head -n 1 | sed -E 's/^[[:space:]]*//' > err.sh
echo '/dev/sda1: UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY.' > chk.log; CHKLOG=chk.log; lcDCL=0; . ./err.sh
check "unrepaired damage is reported" "[ -n \"\$errDCL\" ]"
echo 'e2fsck: error while reading block' > chk.log; . ./err.sh
check "plain errors are still reported" "[ -n \"\$errDCL\" ]"
echo '/dev/sda1: clean, 11/65536 files, 12345/262144 blocks' > chk.log; . ./err.sh
check "a clean check reports nothing" "[ -z \"\$errDCL\" ]"

# Choosing a device that is already excluded is recognised, with text after the UUID.
{ grep -F 'if [ -f "${add}"/disk_check.conf ] && grep -q ' "$S" | head -n 1; echo 'echo ALREADY; fi'; } > dup.sh
echo "blkidExclude='UUID=\"12ab-34cd\" '" > disk_check.conf
exclusion='x UUID="12ab-34cd" TYPE="ext4"'
check "already excluded device is recognised" "[ \"\$(. ./dup.sh 2>/dev/null)\" = ALREADY ]"
exclusion='x UUID="99ff-00aa" TYPE="ext4"'
check "a new device is not treated as excluded" "[ -z \"\$(. ./dup.sh 2>/dev/null)\" ]"

exit $rc
