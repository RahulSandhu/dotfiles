STOW_DIR := $(dir $(CURDIR))
STOW_PKG := $(notdir $(CURDIR))
PKG_DIR  := docs/resources

.PHONY: help all sync-packages install

help:
	@echo "Available targets:"
	@echo " make help          - Show available targets"
	@echo " make all           - Run the full workflow"
	@echo " make sync-packages - Save package lists"
	@echo " make install       - Install dotfiles"

all:
	@$(MAKE) --no-print-directory sync-packages
	@$(MAKE) --no-print-directory install

sync-packages:
	@echo "Saving package lists..."
	@mkdir -p $(PKG_DIR)
	@pacman -Qenq > $(PKG_DIR)/native-pkgs.txt
	@pacman -Qmeq > $(PKG_DIR)/foreign-pkgs.txt

install:
	@echo "Installing dotfiles..."
	@stow --adopt -R -t $(HOME) -d $(STOW_DIR) $(STOW_PKG)
