LUA        ?= lua
CODEC      ?= $(abspath $(CURDIR)/../../lupi-codec)
OUT        ?= $(CURDIR)/.build
STAGE      := $(OUT)/src
CURRENT    := $(CODEC)/current
LUPI       ?= $(abspath $(OUT)/jogo.lupi)

.PHONY: all codec install lupi clean help stage

all: install

help:
	@echo "make          — codec e copia palette/manifest para a raiz"
	@echo "make codec    — processa o cassete (CODEC=$(CODEC))"
	@echo "make lupi     — gera $(LUPI)"
	@echo "make clean    — remove .build"
	@echo "CODEC=$(CODEC)"

stage:
	@test -f "$(CURDIR)/game.lua" || { echo "game.lua nao encontrado"; exit 1; }
	@rm -rf "$(STAGE)"
	@mkdir -p "$(STAGE)"
	cp -f "$(CURDIR)/game.lua" "$(STAGE)/"
	@test ! -f "$(CURDIR)/palette.lua" || cp -f "$(CURDIR)/palette.lua" "$(STAGE)/"
	@test ! -f "$(CURDIR)/lupi_manifest.txt" || cp -f "$(CURDIR)/lupi_manifest.txt" "$(STAGE)/"
	@test ! -f "$(CURDIR)/lupi.yaml" || cp -f "$(CURDIR)/lupi.yaml" "$(STAGE)/"

codec: stage
	@command -v $(LUA) >/dev/null || { echo "lua nao encontrado"; exit 1; }
	@test -f "$(CODEC)/run.lua" || { echo "lupi-codec nao encontrado em $(CODEC)"; echo "Passe CODEC=/caminho/para/lupi-codec"; exit 1; }
	cd "$(CODEC)" && $(LUA) run.lua "$(STAGE)" "$(CODEC)"
	@test -f "$(CURRENT)/palette.lua" || { echo "release vazio em $(CURRENT)"; exit 1; }
	cp -f "$(CURDIR)/palette.lua" "$(CURRENT)/palette.lua"

lupi: codec
	@command -v zip >/dev/null || { echo "zip nao encontrado"; exit 1; }
	@test -d "$(CURRENT)" || { echo "release vazio em $(CURRENT)"; exit 1; }
	rm -f "$(LUPI)"
	cd "$(CURRENT)" && zip -r "$(LUPI)" .
	@echo "Gerado: $(LUPI)"

install: codec
	@test -f "$(CURRENT)/palette.lua" || { echo "release vazio em $(CURRENT)"; exit 1; }
	cp -f "$(CURRENT)/palette.lua" "$(CURDIR)/palette.lua"
	cp -f "$(CURRENT)/lupi_manifest.txt" "$(CURDIR)/lupi_manifest.txt"
	@echo "Instalado: palette.lua e lupi_manifest.txt"

clean:
	rm -rf "$(OUT)"
