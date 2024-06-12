SHELL 	   		 := $(shell which bash)

NO_COLOR       := \033[0m
OK_COLOR       := \033[32;01m
ERR_COLOR      := \033[31;01m
WARN_COLOR     := \033[36;01m
ATTN_COLOR     := \033[33;01m

GOOS           := $(shell go env GOOS)
GOARCH         := $(shell go env GOARCH)

SVU_VERSION 	 := 1.12.0
RELEASE_TAG    := $$(cat VERSION)

BIN_DIR        := ./bin
EXT_DIR        := ./.ext
EXT_BIN_DIR    := ${EXT_DIR}/bin
EXT_TMP_DIR    := ${EXT_DIR}/tmp

.PHONY: deps
deps: info install-svu
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"

.PHONY: build
build:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ./build
	@gem build --output ./build/"aserto-directory-${RELEASE_TAG}.gem"

.PHONY: bump-version
bump-version:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@${EXT_BIN_DIR}/svu patch --prefix="" > ./VERSION

.PHONY: push
push:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gem push ./build/"aserto-directory-${RELEASE_TAG}.gem"

.PHONY: release
release: build push
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"

.PHONY: info
info:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@echo "GOOS:        ${GOOS}"
	@echo "GOARCH:      ${GOARCH}"
	@echo "BIN_DIR:     ${BIN_DIR}"
	@echo "EXT_DIR:     ${EXT_DIR}"
	@echo "EXT_BIN_DIR: ${EXT_BIN_DIR}"
	@echo "EXT_TMP_DIR: ${EXT_TMP_DIR}"
	@echo "RELEASE_TAG: ${RELEASE_TAG}"

.PHONY: install-svu
install-svu: install-svu-${GOOS}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@chmod +x ${EXT_BIN_DIR}/svu
	@${EXT_BIN_DIR}/svu --version

.PHONY: install-svu-darwin
install-svu-darwin: ${EXT_TMP_DIR} ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh release download --repo https://github.com/caarlos0/svu --pattern "svu_*_darwin_all.tar.gz" --output "${EXT_TMP_DIR}/svu.tar.gz" --clobber
	@tar -xvf ${EXT_TMP_DIR}/svu.tar.gz --directory ${EXT_BIN_DIR} svu &> /dev/null

.PHONY: install-svu-linux
install-svu-linux: ${EXT_TMP_DIR} ${EXT_BIN_DIR}
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@gh release download --repo https://github.com/caarlos0/svu --pattern "svu_*_linux_${GOARCH}.tar.gz" --output "${EXT_TMP_DIR}/svu.tar.gz" --clobber
	@tar -xvf ${EXT_TMP_DIR}/svu.tar.gz --directory ${EXT_BIN_DIR} svu &> /dev/null

.PHONY: clean
clean:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@rm -rf ./.ext
	@rm -rf ./bin

${BIN_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${BIN_DIR}

${EXT_BIN_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${EXT_BIN_DIR}

${EXT_TMP_DIR}:
	@echo -e "$(ATTN_COLOR)==> $@ $(NO_COLOR)"
	@mkdir -p ${EXT_TMP_DIR}
