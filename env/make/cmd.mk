ifndef PACKAGE
$(error Please define PACKAGE variable)
endif

_commit     = -X $(PACKAGE)/cmd.commit=$(shell git rev-parse --short HEAD)
_date       = -X $(PACKAGE)/cmd.date=$(shell date -u +%FT%X%Z)
_version    = -X $(PACKAGE)/cmd.version=dev
LDFLAGS     = -ldflags '-s -w $(_commit) $(_date) $(_version)'

CTL_FLAGS   = -tags ctl $(LDFLAGS)
SRV_FLAGS   = $(LDFLAGS)
BUILD_FILES = .


.PHONY: __cmd__
__cmd__:
	go run $(BUILD_FLAGS) $(BUILD_FILES) $(ARGS)

.PHONY: __build__
__build__:
	go build -o $(BIN) -i $(BUILD_FLAGS) $(BUILD_FILES)
	chmod +x $(BIN)
	mv $(BIN) $(GOPATH)/bin/$(BIN)


.PHONY: control-cmd-help
control-cmd-help: BUILD_FLAGS = $(CTL_FLAGS)
control-cmd-help: ARGS = help
control-cmd-help: __cmd__

.PHONY: control-cmd-version
control-cmd-version: BUILD_FLAGS = $(CTL_FLAGS)
control-cmd-version: ARGS = version
control-cmd-version: __cmd__

.PHONY: control-install
control-install: BIN = guardctl
control-install: BUILD_FLAGS = $(CTL_FLAGS)
control-install: __build__


.PHONY: service-cmd-help
service-cmd-help: BUILD_FLAGS = $(SRV_FLAGS)
service-cmd-help: ARGS = help
service-cmd-help: __cmd__

.PHONY: service-cmd-migrate
service-cmd-migrate: BUILD_FLAGS = $(SRV_FLAGS)
service-cmd-migrate: ARGS = migrate
service-cmd-migrate: __cmd__

.PHONY: service-cmd-run
service-cmd-run: BUILD_FLAGS = $(SRV_FLAGS)
service-cmd-run: ARGS = run -H 127.0.0.1:8080 --with-profiling --with-monitoring --with-grpc-gateway
service-cmd-run: __cmd__

.PHONY: service-cmd-version
service-cmd-version: BUILD_FLAGS = $(SRV_FLAGS)
service-cmd-version: ARGS = version
service-cmd-version: __cmd__

.PHONY: service-install
service-install: BIN = guard
service-install: BUILD_FLAGS = $(SRV_FLAGS)
service-install: __build__
