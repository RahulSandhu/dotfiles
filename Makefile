.PHONY: install sync-packages all

STOW_DIR := $(dir $(CURDIR))
STOW_PKG := $(notdir $(CURDIR))

all: sync-packages install

install:
	stow --adopt -R -t $(HOME) -d $(STOW_DIR) $(STOW_PKG)

sync-packages:
	pacman -Qenq > docs/native-pkgs.txt
	pacman -Qmeq > docs/foreign-pkgs.txt
