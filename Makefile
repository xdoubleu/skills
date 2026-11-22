.PHONY: check lint test docs

check: lint test docs

lint:
	./scripts/check.sh lint

test:
	./scripts/check.sh test

docs:
	./scripts/check.sh docs
