#!/bin/bash
__binary_path=$(cargo test --no-run --lib 2>&1 | sed -n 's/Executable .* (\(.*\))/\1/p')
rsync -vahurz --progress $__binary_path dedecta:/tmp/test
cmd="ssh dedecta -T /tmp/test -- --color=always --nocapture $@"
echo "running $cmd"
$cmd
