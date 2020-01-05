#!/bin/bash

echo ":: BUNDLE ::"
bundle install
echo

echo ":: RSPEC ::"
rspec spec/
echo

echo ":: PREPARE ::"
./prepare_test.sh
echo

# Skip running all the tests when we're in tracing mode
if [ "$TRACE" = "1" ];
then
  /bin/bash
else
  # Integration testing is desired
  echo ":: BATS ::"
  bats test/
  echo
fi