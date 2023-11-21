SHELL=/bin/bash -o pipefail

BIN_DIR?=$(shell pwd)/tmp/bin

JB_BIN=$(BIN_DIR)/jb
GOJSONTOYAML_BIN=$(BIN_DIR)/gojsontoyaml
JSONNET_BIN=$(BIN_DIR)/jsonnet
TOOLING=$(JB_BIN) $(GOJSONTOYAML_BIN) $(JSONNET_BIN)

.PHONY: all
all: deps generate

.PHONY: generate
generate:
	./hack/generate.sh

$(BIN_DIR):
	mkdir -p $(BIN_DIR)

.PHONY: deps
deps: $(BIN_DIR)
	export GOBIN=${BIN_DIR}
	go install github.com/google/go-jsonnet/cmd/jsonnet@v0.20.0
	go install github.com/google/go-jsonnet/cmd/jsonnetfmt@v0.20.0
	go install github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@v0.5.1
	go install github.com/brancz/gojsontoyaml@latest
	go install github.com/monitoring-mixins/mixtool/cmd/mixtool@latest
	go install github.com/grafana/dashboard-linter@latest
