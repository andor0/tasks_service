.PHONY: run tests

run:
	docker compose up -d

tests:
	docker run --rm -ti -v$$(pwd):/app erlang:28.0.2.0-slim sh -c 'cd /app && rebar3 eunit'

