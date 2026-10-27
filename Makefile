STOW_DIR := $(dir $(CURDIR))
STOW_PKG := $(notdir $(CURDIR))
PKG_DIR  := docs/resources

.PHONY: help all sync-packages install

help:
	@echo "Available targets:"
	@echo " make help          - Show available targets"
	@echo " make all           - Run sync-packages + install"
	@echo " make sync-packages - Save native/foreign package lists to $(PKG_DIR)/"
	@echo " make install       - Stow dotfiles into HOME"

all: sync-packages install

sync-packages:
	@mkdir -p $(PKG_DIR)
	pacman -Qenq > $(PKG_DIR)/native-pkgs.txt
	pacman -Qmeq > $(PKG_DIR)/foreign-pkgs.txt

install:
	stow --adopt -R -t $(HOME) -d $(STOW_DIR) $(STOW_PKG)
