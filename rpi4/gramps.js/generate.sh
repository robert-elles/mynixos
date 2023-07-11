#!/usr/bin/env bash
#!/

set -eu -o pipefail

rm -rf gen && mkdir -p gen

node2nix \
    --no-copy-node-env \
    --node-env node-env.nix \
    --lock package-lock.json \
    --input package.json \
    --output gen/packages.nix \
    --composition gen/composition.nix \
    --strip-optional-dependencies \
    --nodejs-18