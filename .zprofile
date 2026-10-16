# Force a software cursor. With Intel i915, wlroots' hardware cursor can render
# invisible after kernel/mesa updates (seen after 2026-10-10: linux 7.2.9,
# mesa 26.2.4, adwaita-cursors 51.0). There is no runtime switch, so this must
# be set before sway starts.
export WLR_NO_HARDWARE_CURSORS=1
export XCURSOR_THEME=Adwaita
export XCURSOR_SIZE=24

# Start Sway on tty1 login
[ "$(tty)" = "/dev/tty1" ] && exec sway
