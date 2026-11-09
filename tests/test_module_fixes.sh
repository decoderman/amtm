#!/bin/sh
# Runs code from amtm's modules on the failure cases they need to survive.
# Usage: tests/test_module_fixes.sh [path/to/amtm_modules]
M="$(cd "${1:-amtm_modules}" && pwd)"
T="${TMPDIR:-/tmp}/pr-test.$$"; mkdir -p "$T" || exit 1; trap 'rm -rf "$T"' EXIT; rc=0; cd "$T" || exit 1
ok() { echo "PASS $1"; }; no() { echo "FAIL $1"; rc=1; }
check() { if eval "$2"; then ok "$1"; else no "$1"; fi; }

# An unmounted disk doesn't remove the swap entry; a mounted disk with no file does.
awk '/^\tremove_swap_entries\(\)\{$/{f=1} f{print} f&&/^\t}$/{exit}' "$M/swap.mod" | sed "s#/jffs/scripts/post-mount#$T/post-mount#g; s#/proc/mounts#$T/mounts#g" > swap.sh
. ./swap.sh; r_m() { :; }
echo 'swapon /tmp/mnt/usb/myswap.swp # Added by amtm' > post-mount; echo '/dev/sda2 /tmp/mnt/other ext4 rw 0 0' > mounts
remove_swap_entries
check "unmounted disk keeps swap entry" "grep -q swapon post-mount"
echo '/dev/sda1 /tmp/mnt/usb ext4 rw 0 0' > mounts; remove_swap_entries
check "mounted disk without file drops entry" "! grep -q swapon post-mount"
echo '# nothing about swap' > post-mount; remove_swap_entries
check "post-mount with no entry is left alone" "grep -q 'nothing about swap' post-mount"

# A file name on the disk isn't run.
grep -F 'eval swapfile$i=' "$M/swap.mod" | head -n 1 > name.sh; i=1; swapfile='x;touch PWN1;.swp'; . ./name.sh
check "swap file name is not run" "[ ! -e PWN1 ]"
check "swap file name is kept" "[ \"\$swapfile1\" = 'x;touch PWN1;.swp' ]"
for name in 'a`touch PWN1`.swp' 'a$(touch PWN1).swp' 'my swap.swp' 'a"b.swp' "a'b.swp"; do
	swapfile="$name"; . ./name.sh 2>/dev/null
	check "swap file name stays literal: $name" '[ "$swapfile1" = "$name" ] && [ ! -e PWN1 ]'
done

# The Entware folder search expands its wildcard.
mkdir -p entware.arm/bin; : > entware.arm/bin/opkg; opkgPath=.
grep -F 'opkgUnknown=$(' "$M/mount-entware.mod" | head -n 1 | sed 's#/usr/bin/find#find#' > find.sh; . ./find.sh
check "Entware folder is found" "[ -n \"\$opkgUnknown\" ]"
opkgPath=./nothing-here; mkdir -p "$opkgPath"; . ./find.sh
check "no Entware folder finds nothing" "[ -z \"\$opkgUnknown\" ]"

# The email password isn't word-split or expanded.
grep -F '[ "$writePW" = 1 ] && ' "$M/email.mod" | head -n 1 | sed -E 's#\| */usr/sbin/openssl.*#> pw.out#' > pw.sh
writePW=1; PASSWORD='a  b*'; touch abc; . ./pw.sh
check "password stays exact" "[ \"\$(cat pw.out)\" = 'a  b*' ]"
for PASSWORD in '-n' '-e' 'a\tb' '$HOME' '"quoted"' "it's" ' leading' 'trailing '; do
	. ./pw.sh; got="$(cat pw.out; printf x)"
	check "password stays exact: $PASSWORD" '[ "$got" = "${PASSWORD}x" ]'
done

# dos2unix isn't run over the encrypted password.
grep -E '^s_p\(\)' "$M/amtm.mod" | head -n 1 > sp.sh; . ./sp.sh
d_t_u() { echo "$1" >> touched; }
mkdir -p tree/mail; : > tree/mail/emailpw.enc; : > tree/script.mod; s_p tree
check "encrypted password left alone" "! grep -q emailpw.enc touched"
check "scripts are still converted" "grep -q script.mod touched"
: > tree/mail/report.enc.txt; mkdir -p tree/a/b; : > tree/a/b/deep.enc; : > touched; s_p tree
check "encrypted files are skipped at any depth" "! grep -q 'deep.enc$' touched"
check "only the .enc suffix is skipped" "grep -q report.enc.txt touched"

# A remote version can't carry commands into the file amtm later sources.
amtmRemotever='version=9.9$(touch PWN2)'
grep -E '^[[:space:]]*(amtmRemotever="\$\{amtmRemotever#version=\}"|case "\$amtmRemotever" in)' "$M/amtm.mod" > ver.sh; . ./ver.sh
printf 'x="%s"\n' "$amtmRemotever" > avail; . ./avail
check "remote version can't run commands" "[ ! -e PWN2 ]"
amtmRemotever='version=7.1.3'; . ./ver.sh
check "normal version is kept" "[ \"\$amtmRemotever\" = 7.1.3 ]"
for bad in '9.9`touch PWN2`' '9.9;touch PWN2' '9.9"' '9 9' '9.9|x' '9.9&x'; do
	amtmRemotever="version=$bad"; . ./ver.sh
	check "unsafe version is discarded: $bad" '[ "$amtmRemotever" = 0 ]'
done
amtmRemotever='version=7.1.3-beta_1'; . ./ver.sh
check "tagged version is kept" "[ \"\$amtmRemotever\" = 7.1.3-beta_1 ]"

# Changing the schedule twice leaves one current value.
add=.; asuUpdDay=Monday; asuUpdDOW=Mon
grep -F 'asuUpdDay=\"$asuUpdDay\"' "$M/amtm.mod" | head -n 1 | sed -E 's/^[[:space:]]*//' > sched.sh
. ./sched.sh; asuUpdDay=Friday; asuUpdDOW=Fri; . ./sched.sh; . ./amtmUpdate.conf 2>/dev/null
check "new schedule is the one read back" "[ \"\$asuUpdDay\" = Friday ] && [ \"\$asuUpdDOW\" = Fri ]"
check "schedule is stored once" "[ \"\$(grep -c '^asuUpdDay=' amtmUpdate.conf)\" = 1 ] && [ \"\$(grep -c '^asuUpdDOW=' amtmUpdate.conf)\" = 1 ]"
{ echo 'keepMe="yes"'; cat amtmUpdate.conf; } > conf.new; mv conf.new amtmUpdate.conf; asuUpdDay=Sunday; asuUpdDOW=Sun; . ./sched.sh
check "other settings survive a schedule change" "grep -q '^keepMe=\"yes\"$' amtmUpdate.conf"

exit $rc
