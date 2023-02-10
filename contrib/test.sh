#!/bin/sh

set -ex

FEATURES="proxy base64 json-using-serde"

cargo --version
rustc --version

# Make all cargo invocations verbose
export CARGO_TERM_VERBOSE=true

# Defaults / sanity checks
cargo build
cargo test

if [ "$DO_LINT" = true ]
then
    cargo clippy --features="$FEATURES" --all-targets
fi

if [ "$DO_FEATURE_MATRIX" = true ]; then
    # All features
    cargo build --features="$FEATURES"
    cargo test --features="$FEATURES"
    # Single features
    for feature in ${FEATURES}
    do
        cargo build --features="$feature"
        cargo test --features="$feature"
		# All combos of two features
		for featuretwo in ${FEATURES}; do
			cargo build --features="$feature $featuretwo"
			cargo test --features="$feature $featuretwo"
		done
    done
fi

# Build the docs if told to (this only works with the nightly toolchain)
if [ "$DO_DOCS" = true ]; then
    RUSTDOCFLAGS="--cfg docsrs" cargo doc --features="$FEATURES"
fi
