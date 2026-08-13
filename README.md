# Arch Linux Dotfiles

Personal Arch Linux configuration.

![demo](images/demo.gif)

## Specifications

<div align="center">
  <table>
    <tr>
      <td align="left" valign="top" width="50%">
        <ul align="left">
          <li><strong>Laptop</strong>: Framework 12 (Sage)</li>
          <li><strong>CPU</strong>: Intel Core Ultra Series 2</li>
          <li><strong>GPU</strong>: Intel Arc (integrated)</li>
          <li><strong>Storage</strong>: 1 TB NVMe SSD</li>
          <li><strong>RAM</strong>: 32 GB</li>
          <li><strong>Display</strong>: 12.2" 1920×1200</li>
          <li><strong>OS</strong>: Arch Linux (rolling)</li>
          <li><strong>Shell</strong>: Zsh</li>
          <li><strong>Window manager</strong>: Sway (Wayland)</li>
        </ul>
      </td>
      <td width="50%">
        <img src="images/framework.jpg" alt="Framework 12" width="100%">
      </td>
    </tr>
  </table>
</div>

## Color palette

The color scheme are inspired by the **Framework 12 Sage** laptop.

<div align="center">
  <table>
    <thead align="left">
      <tr align="left">
        <th align="left">Color</th>
        <th align="left">Hex</th>
        <th align="left">Used for</th>
      </tr>
    </thead>
    <tbody align="left">
      <tr align="left">
        <td align="left">Black</td>
        <td align="left"><code>#000000</code></td>
        <td align="left">Backgrounds (Sway windows, Waybar, Kitty)</td>
      </tr>
      <tr align="left">
        <td align="left">Off-white</td>
        <td align="left"><code>#e0e0e0</code></td>
        <td align="left">Primary text</td>
      </tr>
      <tr align="left">
        <td align="left">Sage green</td>
        <td align="left"><code>#b8d9ae</code></td>
        <td align="left">Accent, wallpaper, urgent/active states, cursor</td>
      </tr>
      <tr align="left">
        <td align="left">Olive green</td>
        <td align="left"><code>#4a5d46</code></td>
        <td align="left">Focused borders, indicators</td>
      </tr>
      <tr align="left">
        <td align="left">Muted gray-green</td>
        <td align="left"><code>#6e6e70</code></td>
        <td align="left">Inactive/unfocused elements</td>
      </tr>
    </tbody>
  </table>
</div>

## Tools

| Tool          | Files                                                | Purpose                                                                |
| ------------- | ---------------------------------------------------- | ---------------------------------------------------------------------- |
| bash          | `.bash_logout`, `.bash_profile`, `.bashrc`           | Minimal interactive Bash shell setup.                                  |
| clipse        | `.config/clipse/`                                    | Clipboard manager with history.                                        |
| galendae      | `.config/galendae/`                                  | Calendar popup launched from Waybar.                                   |
| git           | `.config/git/`                                       | Global hooks, aliases, and Git configuration overrides.                |
| gtrash        | `.config/gtrash/`                                    | Trash wrapper; `rm` aliases put files in trash.                        |
| kitty         | `.config/kitty/`                                     | Terminal emulator with custom colors and font.                         |
| neovim        | `.config/nvim/`                                      | Editor with Lazy.nvim plugin manager.                                  |
| notse         | `.config/notse/`                                     | Terminal-based note-taking app.                                        |
| npm           | `.npmrc`                                             | npm global install prefix.                                             |
| opencode      | `.config/opencode/`                                  | OpenCode AI agent config and MCP servers.                              |
| powerlevel10k | `.p10k.zsh`                                          | Zsh prompt theme.                                                      |
| r             | `.Renviron`, `.Rprofile`                             | R environment and renv setup.                                          |
| rclone        | `.config/rclone/`                                    | Google Drive sync script and filters.                                  |
| sway          | `.config/sway/`, `.zprofile`                         | Wayland tiling window manager; `.zprofile` auto-starts Sway on `tty1`. |
| swaync        | `.config/swaync/`                                    | Notification center and control center.                                |
| swayosd       | `.config/swayosd/`                                   | On-screen display for volume and brightness.                           |
| systemd       | `.config/systemd/user/`                              | User services and timers.                                              |
| timeshift     | `.config/timeshift/`                                 | System snapshot scheduling.                                            |
| waybar        | `.config/waybar/`                                    | Top bar with workspaces, clock, and custom menu.                       |
| wofi          | `.config/wofi/`                                      | Application launcher and screenshot/cast menus.                        |
| XDG user dirs | `.config/user-dirs.dirs`, `.config/user-dirs.locale` | Default directory names.                                               |
| yazi          | `.config/yazi/`                                      | Terminal file manager.                                                 |
| zathura       | `.config/zathura/`                                   | Minimal PDF reader.                                                    |
| zellij        | `.config/zellij/`                                    | Terminal multiplexer with custom layouts.                              |
| zsh           | `.zshrc`, `.zprofile`                                | Main shell with Zinit, aliases, and Wayland env vars.                  |
