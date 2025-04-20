NAME=alpine-dev:aarch64
CMD=/usr/bin/env python3 eKW_flet.py

all: build run

build:
	docker build -t $(NAME) .

run:
	docker run --rm -it --name $(NAME) $(NAME)

attach:
	docker exec -it $(NAME) bash
