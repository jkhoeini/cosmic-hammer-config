#!/usr/bin/env sh
# Compile Fennel to Lua. Outputs are replaced only when compilation succeeds,
# so a compile error never leaves a truncated init.lua for the config watcher
# to reload.

set -u

# compile_to TARGET NOISE DEPS-ARGS...
# NOISE=quiet hides deps' stderr unless the build fails.
compile_to() {
  target=$1
  noise=$2
  shift 2
  tmp=$(mktemp) || exit 1
  if [ "$noise" = quiet ]; then
    mise x -- deps --require-as-include "$@" > "$tmp" 2> "$tmp.err"
  else
    mise x -- deps --require-as-include "$@" > "$tmp"
  fi
  status=$?
  if [ "$status" -eq 0 ] && [ -s "$tmp" ]; then
    mv -f "$tmp" "$target"
    rm -f "$tmp.err"
  else
    [ -s "$tmp.err" ] && cat "$tmp.err" >&2
    rm -f "$tmp" "$tmp.err"
    echo "compile.sh: failed to build $target; kept the previous file" >&2
    exit 1
  fi
}

compile_to lib/cljlib-shim.lua quiet -c lib/cljlib-shim.fnl

# Compile main config, skipping the pre-compiled shim
compile_to init.lua loud --skip-include "lib.cljlib-shim" -c core.fnl
