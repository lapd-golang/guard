# TODO issue#environment
# - gomock
# - protoc
# - statik replace
# TODO add . "github.com/kamilsk/guard/pkg/transport/grpc/protobuf" to the import


.PHONY: json
json:
	find . -name "*_easyjson.go" | grep -v /vendor/ | xargs rm || true
	go generate -run="easyjson" ./...

.PHONY: mocks
mocks:
	find . -name "mock_*_test.go" | grep -v /vendor/ | xargs rm || true
	go generate -run="mockgen" ./...

.PHONY: protobuf
protobuf:
	@(protoc -Ienv/api \
	         -Ivendor/github.com/grpc-ecosystem/grpc-gateway \
	         -Ivendor/github.com/grpc-ecosystem/grpc-gateway/third_party/googleapis \
	         --go_out=plugins=grpc,logtostderr=true:pkg/transport/grpc/protobuf \
	         --grpc-gateway_out=logtostderr=true,import_path=gateway:pkg/transport/grpc/gateway \
	         --swagger_out=logtostderr=true,allow_merge=true,merge_file_name=guard:env/api \
	         common.proto license.proto maintenance.proto)
	@(mv env/api/guard.swagger.json env/api/swagger.json)

.PHONY: static
static:
	statik -c '' -f -dest pkg/storage -p migrations -src pkg/storage/migrations

.PHONY: generate
generate: json mocks protobuf static


.PHONY: test
test:
	go test -race -v ./...

.PHONY: test-integration
test-integration:
	go test -tags integration -v ./env/test/...
