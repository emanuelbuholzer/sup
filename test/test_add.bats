setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'

  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  PATH="$(readlink -f "$DIR/../"):$PATH"

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