#!/bin/sh
set -e

# goals:
# - fedora
# - rocky
# - debian
# - alpine
# - GNU coreutils
# - uutils
# - BusyBox
# - gixoxide

project_dir=$(git rev-parse --show-toplevel)
test_run=$(date +%s)

run_tests() {
  image="$1"
  tag="$2"
  podman run \
    --interactive \
    --tty \
    --rm \
    --workdir /home/testuser/sup \
    "$image" \
    /bin/sh -c "./test/bats/bin/bats ./test/test_add.bats"
}

test_debian() {
  tag="$1"

  c=$(buildah from docker.io/debian:"$tag")
  buildah run "$c" -- apt-get -y update
  buildah run "$c" -- apt-get -y install git

  buildah run "$c" -- useradd -m testuser
  buildah config --user testuser "$c"
  buildah copy --chown testuser:testuser "$c" "$project_dir" /home/testuser/sup

  buildah commit "$c" "sup/debian-$tag:$test_run"
  run_tests "sup/debian-$tag:$test_run"
}

test_debian bookworm
test_debian bullseye
test_debian buster
test_debian unstable

test_ubuntu() {
  tag="$1"

  c=$(buildah from docker.io/ubuntu:"$tag")
  buildah run "$c" -- apt-get -y update
  buildah run "$c" -- apt-get -y install git

  buildah run "$c" -- useradd -m testuser
  buildah config --user testuser "$c"
  buildah copy --chown testuser:testuser "$c" "$project_dir" /home/testuser/sup

  buildah commit "$c" "sup/ubuntu-$tag:$test_run"
  run_tests "sup/ubuntu-$tag:$test_run"
}

test_ubuntu 20.04
test_ubuntu 22.04
test_ubuntu 23.04
test_ubuntu 23.10
