#!/bin/bash
__binary_path=$(cargo test --no-run --lib 2>&1 | sed -n 's/Executable .* (\(.*\))/\1/p')
rsync -vahurz --progress $__binary_path REDACTED_PROJECT:/tmp/test
cmd="ssh REDACTED_PROJECT -T /tmp/test -- --color=always --nocapture $@"
echo "running $cmd"
$cmd
