import json
import sqlite3

from mcp.server.models import InitializationOptions
import mcp.types as types
from mcp.server import NotificationOptions, Server
import mcp.server.stdio


server = Server("sqlite_mcp")


def _connect(db_path: str) -> sqlite3.Connection:
    conn = sqlite3.connect(db_path)
    conn.row_factory = sqlite3.Row
    return conn


@server.list_tools()
async def handle_list_tools() -> list[types.Tool]:
    """
    Tools for SQLite database querying
    """
    return [
        types.Tool(
            name="query",
            description="Run a SELECT query against a local SQLite database file and return the rows as JSON.",
            inputSchema={
                "type": "object",
                "properties": {
                    "db_path": {
                        "type": "string",
                        "description": "Absolute path to the SQLite database file",
                    },
                    "sql": {
                        "type": "string",
                        "description": "SELECT SQL query to execute",
                    },
                },
                "required": ["db_path", "sql"],
            },
        ),
        types.Tool(
            name="execute",
            description="Run an INSERT, UPDATE, or DELETE query against a local SQLite database file and return the number of affected rows.",
            inputSchema={
                "type": "object",
                "properties": {
                    "db_path": {
                        "type": "string",
                        "description": "Absolute path to the SQLite database file",
                    },
                    "sql": {
                        "type": "string",
                        "description": "INSERT, UPDATE, or DELETE SQL query to execute",
                    },
                },
                "required": ["db_path", "sql"],
            },
        ),
        types.Tool(
            name="list_tables",
            description="List all tables in a local SQLite database file.",
            inputSchema={
                "type": "object",
                "properties": {
                    "db_path": {
                        "type": "string",
                        "description": "Absolute path to the SQLite database file",
                    },
                },
                "required": ["db_path"],
            },
        ),
        types.Tool(
            name="describe_table",
            description="Show the schema of a table in a local SQLite database file.",
            inputSchema={
                "type": "object",
                "properties": {
                    "db_path": {
                        "type": "string",
                        "description": "Absolute path to the SQLite database file",
                    },
                    "table_name": {
                        "type": "string",
                        "description": "Name of the table to describe",
                    },
                },
                "required": ["db_path", "table_name"],
            },
        ),
    ]


@server.call_tool()
async def handle_call_tool(
    name: str, arguments: dict | None
) -> list[types.TextContent]:
    """
    SQLite database tools
    """
    if not arguments:
        raise ValueError("Missing arguments")

    db_path = arguments.get("db_path")
    if not db_path:
        raise ValueError("Missing db_path")

    if name == "query":
        sql = arguments.get("sql")
        if not sql:
            raise ValueError("Missing sql")
        if not sql.strip().upper().startswith("SELECT"):
            raise ValueError("query is for SELECT only; use execute for INSERT/UPDATE/DELETE")
        conn = _connect(db_path)
        try:
            cur = conn.execute(sql)
            rows = [dict(row) for row in cur.fetchall()]
            return [
                types.TextContent(
                    type="text",
                    text=json.dumps(rows, indent=2, default=str),
                )
            ]
        finally:
            conn.close()

    elif name == "execute":
        sql = arguments.get("sql")
        if not sql:
            raise ValueError("Missing sql")
        if sql.strip().upper().startswith("SELECT"):
            raise ValueError("execute is for INSERT/UPDATE/DELETE only; use query for SELECT")
        conn = _connect(db_path)
        try:
            cur = conn.execute(sql)
            conn.commit()
            return [
                types.TextContent(
                    type="text",
                    text=str(cur.rowcount),
                )
            ]
        finally:
            conn.close()

    elif name == "list_tables":
        conn = _connect(db_path)
        try:
            rows = conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name"
            ).fetchall()
            names = [row[0] for row in rows]
            return [
                types.TextContent(
                    type="text",
                    text="\n".join(names) if names else "No tables",
                )
            ]
        finally:
            conn.close()

    elif name == "describe_table":
        table_name = arguments.get("table_name")
        if not table_name:
            raise ValueError("Missing table_name")
        if '"' in table_name:
            raise ValueError("Invalid table_name")
        conn = _connect(db_path)
        try:
            rows = conn.execute(
                f'PRAGMA table_info("{table_name}")'
            ).fetchall()
            if not rows:
                return [
                    types.TextContent(
                        type="text",
                        text=f"Table '{table_name}' not found",
                    )
                ]
            cols = [
                {
                    "cid": row[0],
                    "name": row[1],
                    "type": row[2],
                    "notnull": row[3],
                    "default": row[4],
                    "pk": row[5],
                }
                for row in rows
            ]
            return [
                types.TextContent(
                    type="text",
                    text=json.dumps(cols, indent=2),
                )
            ]
        finally:
            conn.close()

    else:
        raise ValueError(f"Unknown tool: {name}")


async def main():
    # Run the server using stdin/stdout streams
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            InitializationOptions(
                server_name="sqlite_mcp",
                server_version="0.1.0",
                capabilities=server.get_capabilities(
                    notification_options=NotificationOptions(),
                    experimental_capabilities={},
                ),
            ),
        )