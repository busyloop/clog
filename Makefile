ci: test

test: lint
	@crystal spec

lint: bin/ameba
	@bin/ameba

# Run this once to initialize your development environment
install:
	shards

bin/ameba:
	make install

