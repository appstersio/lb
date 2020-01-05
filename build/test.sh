#!/bin/bash
echo

echo ":: BUNDLE ::"
bundle install
echo

echo ":: RSPEC ::"
rspec spec/
echo

# Skip running all the tests when we're in tracing mode
if [ "$TRACE" = "1" ];
then
  /bin/bash
else
  # Integration testing is desired
  echo ":: BATS ::"
  bats --tap test/
  echo
fi