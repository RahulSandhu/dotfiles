#!/usr/bin/python

import i3ipc


def rename_workspaces(i3):
    workspaces = i3.get_workspaces()
    for index, workspace in enumerate(
        sorted(workspaces, key=lambda ws: ws.num), start=1
    ):
        if workspace.num != index:
            i3.command(f'rename workspace "{workspace.name}" to "{index}"')


def on_workspace_event(i3, event):
    if event.change in ["focus", "init", "empty"]:
        rename_workspaces(i3)


def main():
    i3 = i3ipc.Connection()

    rename_workspaces(i3)

    i3.on("workspace::focus", on_workspace_event)
    i3.on("workspace::init", on_workspace_event)
    i3.on("workspace::empty", on_workspace_event)

    i3.main()


if __name__ == "__main__":
    main()
