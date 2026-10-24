STOW_DIR := $(dir $(CURDIR))
STOW_PKG := $(notdir $(CURDIR))

.PHONY: help all sync-packages install

help:
	@echo "Available targets:"
	@echo " make help          - Show available targets"
	@echo " make all           - Run sync-packages + install"
	@echo " make sync-packages - Save native/foreign package lists"
	@echo " make install       - Stow dotfiles into HOME"

all: sync-packages install

sync-packages:
	pacman -Qenq > native-pkgs.txt
	pacman -Qmeq > foreign-pkgs.txt

install:
	stow --adopt -R -t $(HOME) -d $(STOW_DIR) $(STOW_PKG)
