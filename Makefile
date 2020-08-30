PROTO_PATH := hello-world
PROTO_GO_DIST := hello-world/rpc
PROTOC_GEN_TS_PATH := ./node_modules/.bin/protoc-gen-ts
PROTO_TS_DIST := client/rpc


.PHONY: build

gen-proto:
	rm -rf $(PROTO_GO_DIST)
	mkdir -p $(PROTO_GO_DIST)
	protoc -I$(PROTO_PATH) \
		   --go_out=plugins=grpc:$(PROTO_GO_DIST) \
		   $(PROTO_PATH)/*.proto

gen-client-proto:
	rm -rf $(PROTO_TS_DIST)
	mkdir -p $(PROTO_TS_DIST)
	protoc -I$(PROTO_PATH) \
           --plugin="protoc-gen-ts=$(PROTOC_GEN_TS_PATH)" \
           --js_out=import_style=commonjs,binary:$(PROTO_TS_DIST) \
           --ts_out=service=grpc-web:$(PROTO_TS_DIST) \
           $(PROTO_PATH)/*.proto
	find $(PROTO_TS_DIST) -type f -name "*_pb.js" | xargs gsed -i -e "1i /* eslint-disable */"
	find $(PROTO_TS_DIST) -type f -name "*_pb_service.js" | xargs gsed -i -e "1i /* eslint-disable */"

build:
	sam build

deploy: build
	sam deploy

debug:
	./node_modules/.bin/ts-node client/debug.ts