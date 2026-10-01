#!/usr/bin/env sh
# Run every deterministic Fennel harness with strict globals, then reject
# mangled unbound identifiers (kebab-case/predicate names) in init.lua.
# Exits non-zero on any failure.

cd "$(dirname "$0")/.." || exit 1

failed=0
for harness in test/*.fnl; do
  if output=$(fennel --globals hs --add-fennel-path "./?.fnl;./?/init.fnl" "$harness" 2>&1); then
    echo "ok   $harness"
  else
    echo "FAIL $harness"
    echo "$output" | sed 's/^/     /'
    failed=1
  fi
done

if grep -q "__fnl_global__" init.lua; then
  echo "FAIL init.lua references unbound kebab-case identifiers (run ./compile.sh after fixing):"
  grep -o "__fnl_global__[A-Za-z0-9_]*" init.lua | sort -u | sed 's/^/     /'
  failed=1
fi

exit $failed
