# README: http://makefiletutorial.com

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown
build:
	@docker-compose -f docker-compose.test.yml build

test:
	@docker-compose -f docker-compose.test.yml up -d
	@bats test/

teardown:
	@docker-compose -f docker-compose.test.yml down