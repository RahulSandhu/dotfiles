#!/usr/bin/python

import i3ipc


def rename_workspaces(i3):
    """
    Rename workspaces to ensure they are numbered sequentially.
    """
    workspaces = i3.get_workspaces()
    for index, workspace in enumerate(
        sorted(workspaces, key=lambda ws: ws.num), start=1
    ):
        if workspace.num != index:
            i3.command(f'rename workspace "{workspace.name}" to "{index}"')


def on_workspace_event(i3, event):
    """
    Rename workspaces on focus, init, or empty events.
    """
    if event.change in ["focus", "init", "empty"]:
        rename_workspaces(i3)


def main():
    """
    Establish connection to i3 and rename workspaces events.
    """
    i3 = i3ipc.Connection()

    # Initial renaming of workspaces
    rename_workspaces(i3)

    # Subscribe to workspace events
    i3.on("workspace::focus", on_workspace_event)
    i3.on("workspace::init", on_workspace_event)
    i3.on("workspace::empty", on_workspace_event)

    # Main event loop
    i3.main()


if __name__ == "__main__":
    main()
