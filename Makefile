# README: http://makefiletutorial.com

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown etcd up netcat
etcd:
	@docker-compose -f docker-compose.test.yml up -d etcd
	@sleep 5

build:
	@docker-compose -f docker-compose.test.yml build

# NOTE: Find out more about use of logical OR operators in bash:
# https://bash.cyberciti.biz/guide/Logical_OR
up:
	@docker-compose -f docker-compose.test.yml up -d && sleep 5 && \
		echo "OK: Successfuly launched all the required components..." || \
		echo "ERROR: Failed to launch all the required components..."

netcat:
	@docker-compose -f docker-compose.test.yml exec -d lb nc -lk -p 9999 -e /bin/sh && \
		echo "OK: Successfuly started netcat listener on load balancer (lb)..." || \
		echo "ERROR: Failed to start netcat listener on load balancer (lb)..."
	@docker-compose -f docker-compose.test.yml exec -d lb_no_health nc -lk -p 9999 -e /bin/sh && \
		echo "OK: Successfuly started netcat listener on load balancer (lb_no_health)..." || \
		echo "ERROR: Failed to start netcat listener on load balancer (lb_no_health)..."

test:
	@docker-compose -f docker-compose.test.yml exec lbe bats test/ && \
		echo "OK: Successfuly passed all the tests for this build of load balancer..." || \
		echo "ERROR: Failed to pass all the tests for this build of load balancer..."

teardown:
	@docker-compose -f docker-compose.test.yml down && \
		echo "OK: Successfuly shutdown and removed all the required components..." || \
		echo "OK: Failed to shutdown and remove all the required components..."