.PHONY: run tests

run:
	docker compose up -d

tests:
	docker run --rm -ti -v$$(pwd):/app:ro erlang:28.0.2.0-slim sh -c 'cp -a /app /app-copy && cd /app-copy && rebar3 eunit'

