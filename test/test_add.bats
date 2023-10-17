setup() {
  bats_require_minimum_version 1.5.0
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$(readlink -f "$DIR/../"):$PATH"

  rm -rf /home/testuser/testbed
  mkdir -p /home/testuser/testbed
  cd /home/testuser/testbed
  git init || true > /dev/null 2>&1
  git config user.name testuser
  git config user.email testuser@testemail.test
  echo "test project" > README
  git add README
  git commit -m "create test project" > /dev/null
}

@test "add: dry-run test nop" {
  run sup -n add test test
  assert_output --partial 'running dry'
  assert_output --partial 'git -C /home/testuser/testbed submodule add test --name test -- /home/testuser/testbed/test'
  assert_output --partial 'git commit -m sup: add submodule'
}

@test "add: existing submodule with similar path is ok" {
  run sup add https://github.com/emanuelbuholzer/sup.git third_party/sup/not_sup
  run sup add https://github.com/emanuelbuholzer/sup.git not_sup/third_party/sup
  run sup add https://github.com/emanuelbuholzer/sup.git not_sup/sup
  run sup add https://github.com/emanuelbuholzer/sup.git not_sup/third_party
  run sup add https://github.com/emanuelbuholzer/sup.git sup/not_sup
  run sup add https://github.com/emanuelbuholzer/sup.git third_party/not_sup

  run sup add https://github.com/emanuelbuholzer/sup.git third_party/sup
}

@test "add: existing submodule with same remote is ok" {
  run sup add https://github.com/emanuelbuholzer/sup.git third_party/sup
  run sup add https://github.com/emanuelbuholzer/sup.git third_party/sup
}

@test "add: existing submodule with different remote is error" {
  run sup add https://github.com/emanuelbuholzer/omcp.git third_party/sup
  run sup add https://github.com/emanuelbuholzer/sup.git third_party/sup
  assert_output --partial 'already exists, associated to a different repository'
}

@test "add: require clean worktree" {
  touch dirty
  run ! sup add test test
  assert_output --partial 'you need a clean worktree to add submodules'
}
