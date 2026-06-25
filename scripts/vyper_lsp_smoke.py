#!/usr/bin/env python3
import json
import os
import select
import subprocess
import sys
import time
from pathlib import Path

root = Path(__file__).resolve().parents[1]
proc = subprocess.Popen(
    ["vyper-lsp", "--stdio"],
    stdin=subprocess.PIPE,
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    cwd=root,
)
assert proc.stdin is not None
assert proc.stdout is not None
assert proc.stderr is not None


def send(message: dict) -> None:
    payload = json.dumps(message, separators=(",", ":")).encode()
    proc.stdin.write(b"Content-Length: " + str(len(payload)).encode() + b"\r\n\r\n" + payload)
    proc.stdin.flush()


def read_message(timeout: float = 10.0) -> dict:
    deadline = time.time() + timeout
    header = b""
    while b"\r\n\r\n" not in header:
        remaining = deadline - time.time()
        if remaining <= 0:
            raise TimeoutError("timed out waiting for LSP response header")
        ready, _, _ = select.select([proc.stdout], [], [], remaining)
        if not ready:
            continue
        chunk = os.read(proc.stdout.fileno(), 1)
        if not chunk:
            raise EOFError("vyper-lsp exited before sending a response")
        header += chunk
    header_text, rest = header.split(b"\r\n\r\n", 1)
    length = None
    for line in header_text.decode().split("\r\n"):
        key, _, value = line.partition(":")
        if key.lower() == "content-length":
            length = int(value.strip())
    if length is None:
        raise ValueError(f"missing Content-Length header: {header_text!r}")
    body = rest
    while len(body) < length:
        remaining = deadline - time.time()
        if remaining <= 0:
            raise TimeoutError("timed out waiting for LSP response body")
        ready, _, _ = select.select([proc.stdout], [], [], remaining)
        if ready:
            body += os.read(proc.stdout.fileno(), length - len(body))
    return json.loads(body[:length].decode())

try:
    send({
        "jsonrpc": "2.0",
        "id": 1,
        "method": "initialize",
        "params": {
            "processId": None,
            "rootUri": root.as_uri(),
            "capabilities": {},
        },
    })
    response = read_message()
    if response.get("id") != 1 or "result" not in response:
        raise AssertionError(f"unexpected initialize response: {response!r}")
    capabilities = response["result"].get("capabilities", {})
    expected = ["completionProvider", "hoverProvider", "definitionProvider"]
    missing = [name for name in expected if name not in capabilities]
    if missing:
        raise AssertionError(f"initialize response missing capabilities: {missing}; got {capabilities}")
    send({"jsonrpc": "2.0", "method": "initialized", "params": {}})
    send({"jsonrpc": "2.0", "id": 2, "method": "shutdown", "params": None})
    shutdown = read_message()
    if shutdown.get("id") != 2:
        raise AssertionError(f"unexpected shutdown response: {shutdown!r}")
    send({"jsonrpc": "2.0", "method": "exit", "params": None})
finally:
    try:
        proc.stdin.close()
    except Exception:
        pass
    try:
        proc.wait(timeout=5)
    except subprocess.TimeoutExpired:
        proc.kill()
        proc.wait(timeout=5)

stderr = proc.stderr.read().decode(errors="replace")
print("vyper-lsp initialize/shutdown smoke ok")
if stderr.strip():
    print(stderr.strip(), file=sys.stderr)
