#!/usr/bin/env bash
#!/

set -eu -o pipefail

rm -rf gen && mkdir -p gen

node2nix \
    # --no-copy-node-env \
    --lock package-lock.json \
    --input package.json \
    --node-env gen/node-env.nix \
    --composition gen/composition.nix \
    --output gen/packages.nix \
    --nodejs-18 \
    --development \
    # --strip-optional-dependencies \