DT := $(shell date +%Y%U)
REV := $(shell git rev-parse --short HEAD)
APP := $(shell basename $(CURDIR))
ARTIFACT := bin/$(APP)$(EXT)

TAGS ?= dev
GOFLAGS ?= -race -v
GOLDFLAGS ?= -X main.buildRevision=$(DT).$(REV)

.PHONY: all amd64 arm64 win build linux release tidy updep

build:
	go build $(GOFLAGS) -ldflags "$(GOLDFLAGS)" -tags="$(TAGS)" -o $(ARTIFACT) cmd/*.go

release:
	GOFLAGS="-trimpath" GOLDFLAGS="$(GOLDFLAGS) -s -w" TAGS="release" $(MAKE) build

linux:
	GOOS=linux $(MAKE) release

amd64:
	EXT=.x86-64 GOARCH=amd64 $(MAKE) linux

arm64:
	EXT=.aarch64 GOARCH=arm64 $(MAKE) linux

win:
	EXT=.exe GOOS=windows $(MAKE) release

tidy: go.mod
	go mod tidy

updep: go.mod
	rm -f go.sum
	head -1 go.mod > /tmp/go.mod
	mv /tmp/go.mod go.mod
	go mod tidy

all: amd64 arm64 win