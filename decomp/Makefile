# RGBDS recipes run inside the flake dev shell. `nix develop` sets
# IN_NIX_SHELL, so a nested `make` does not start another shell.
ifeq ($(IN_NIX_SHELL),)
NIX_RUN := nix develop --command
else
NIX_RUN :=
endif

# Magi Nation (USA) is the only project in this tree.
PROJECT ?= magination

ifeq ($(PROJECT),magination)
ROM := roms/magination.gbc
OUT := out/magination.gbc
MAP := out/magination.map
SYM := out/magination.sym
ASM := src/scaffold.asm
FIX := -f hg -p 255
SHA1 := rom.sha1
else
$(error only PROJECT=magination is built here)
endif

OBJ := $(patsubst %.gbc,%.o,$(OUT))
OBJ := $(patsubst %.gb,%.o,$(OBJ))
OBJ := $(patsubst %.gba,%.o,$(OBJ))

.PHONY: build compare notes clean info progress check test verify report setup \
	targets lift propagate worker stats

SRC := $(shell find $(dir $(ASM)) -type f \( -name '*.asm' -o -name '*.inc' -o -name '*.tmap' \))

# Graphics: gfx/NAME.png -> out/gfx/NAME.2bpp, gfx/NAME.1bpp.png ->
# out/gfx/NAME.1bpp (AGENTS.md S2). gfx/gfx.mk holds per-asset flags.
ifeq ($(PROJECT),magination)
GFX_PNG := $(wildcard gfx/*.png)
GFX := $(patsubst gfx/%.1bpp.png,out/gfx/%.1bpp,$(filter %.1bpp.png,$(GFX_PNG))) \
	$(patsubst gfx/%.png,out/gfx/%.2bpp,$(filter-out %.1bpp.png,$(GFX_PNG)))
-include gfx/gfx.mk
endif

out/gfx/%.1bpp: gfx/%.1bpp.png
	mkdir -p $(dir $@)
	$(NIX_RUN) rgbgfx -d 1 $(RGBGFX_FLAGS) -o $@ $<

out/gfx/%.2bpp: gfx/%.png
	mkdir -p $(dir $@)
	$(NIX_RUN) rgbgfx $(RGBGFX_FLAGS) -o $@ $<

build: $(OUT) $(MAP) $(SYM)

# One recipe writes the image, the map, and the symbol file. `&:` keeps Make
# from running it once per file.
$(OUT) $(MAP) $(SYM) &: $(SRC) $(ROM) $(GFX) $(wildcard gfx/rle/*)
	mkdir -p $(dir $(OUT))
	python3 scripts/rle/build.py
	$(NIX_RUN) python3 scripts/own/rle_gfx.py build
	$(NIX_RUN) rgbasm -I . -o $(OBJ) $(ASM)
	$(NIX_RUN) rgblink -m $(MAP) -n $(SYM) -o $(OUT) $(OBJ)
	$(NIX_RUN) rgbfix $(FIX) $(OUT)

# objdiff report version 2. The image has to match before a unit is matched.
report: compare
	python3 scripts/report.py

compare: build
	$(NIX_RUN) cmp $(OUT) $(ROM)
ifneq ($(SHA1),)
	$(NIX_RUN) sha1sum -c $(SHA1)
endif

# Local notes only. Overwrites disassembly/. Do not commit that directory.
notes:
	test -f "$(ROM)" || { echo "missing $(ROM); see roms/README.md" >&2; exit 1; }
	$(NIX_RUN) mgbdis "$(ROM)" --output-dir disassembly --overwrite

progress:
	python3 scripts/progress.py --project $(PROJECT) --banks

# Publication rules (L1, O1) and the rules a tool can check (check_rules.py).
check:
	python3 scripts/check_tree.py
	python3 scripts/check_rules.py --project $(PROJECT)

# Tool tests: the text byte count agrees with the linker map, lift.py re-emits
# every matched routine byte for byte, the report parser and worker helpers.
test: build
	python3 scripts/progress.py --project $(PROJECT) --check-map
	cd scripts && python3 test_report.py
	python3 scripts/test_tools.py
	python3 scripts/test_lift_replay.py --project $(PROJECT)

verify: check compare test progress

info:
	$(NIX_RUN) python3 scripts/rom_info.py roms/magination.gbc roms/keepers-quest.gbc

clean:
	rm -rf out

setup:
	git config core.hooksPath $$(git rev-parse --show-prefix).hooks

# The worker (AGENTS.md W1-W9). Mechanical lifts and symbol propagation need
# no model; naming rounds use WORKER_LLM_CMD. It commits locally, never pushes.
targets: build
	python3 scripts/worker.py --project $(PROJECT) targets --all

lift: build
	python3 scripts/worker.py --project $(PROJECT) lift --auto $(or $(N),10)

propagate: build
	python3 scripts/worker.py --project $(PROJECT) propagate

worker: build
	python3 scripts/worker.py --project $(PROJECT) run --batch $(or $(N),10) --names $(or $(NAMES),0)

stats:
	python3 scripts/worker.py --project $(PROJECT) stats
