.PHONY: build up down down_all start_repl start_sysbench

build:
	docker-compose build

up:
	docker-compose up -d --build --wait
	sleep 10
	make start_repl

up2:
	docker-compose up -d --build --wait
	sleep 10
	make start_repl_gtid

down:
	docker-compose down

down_all:
	docker-compose down -v --rmi all --remove-orphans

start_repl:
	zsh -c ./start_repl.sh

start_repl_gtid:
	zsh -c ./start_repl_gtid.sh
start_sysbench:
	zsh -c ./start_sysbench.sh