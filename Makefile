# README: http://makefiletutorial.com

# Adding PHONY to a target will prevent make from confusing the phony target with a file name.
# In this case, if `test` folder exists, `make test` will still be run.
.PHONY: test build teardown etcd up netcat
etcd:
	@docker-compose up -d etcd
	@sleep 5

build:
	@docker-compose build

# NOTE: Find out more about use of logical OR operators in bash:
# https://bash.cyberciti.biz/guide/Logical_OR
up:
	@docker-compose -f docker-compose.yml -f docker-compose.dev.yml up -d && sleep 5 && \
		echo "OK: Successfuly launched all the required components..."

release-up:
	@docker-compose up -d && sleep 5 && \
		echo "OK: Successfuly launched all the required components..."

netcat:
	@docker-compose exec -d lb nc -lk -p 9999 -e /bin/sh && \
		echo "OK: Successfuly started netcat listener on load balancer (lb)..."
	@docker-compose exec -d lb_no_health nc -lk -p 9999 -e /bin/sh && \
		echo "OK: Successfuly started netcat listener on load balancer (lb_no_health)..."

test:
	@docker-compose exec -T lbe bats /test && \
		echo "OK: Successfuly passed all the tests for this build of load balancer..."

teardown:
	@docker-compose down && \
		echo "OK: Successfuly shutdown and removed all the required components..."

publish:
	@docker login -u="$(kontena vault read --value DOCKER_USERNAME)" -p="$(kontena vault read --value DOCKER_PASSWORD)" && \
		docker-compose push lb && \
		echo "OK: Successfuly published 'lb' image..."