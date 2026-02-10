#!/usr/bin/env python3
"""Lightweight debug log collector. Python 3 stdlib only."""

import argparse
import json
import os
from datetime import datetime, timezone
from http.server import HTTPServer, BaseHTTPRequestHandler
from pathlib import Path


class DebugHandler(BaseHTTPRequestHandler):
    log_dir: Path
    current_round: int

    def do_GET(self):
        if self.path == "/health":
            self._respond(200, {
                "status": "ok",
                "round": self.current_round,
                "log_dir": str(self.log_dir),
            })
            return

        if self.path.startswith("/logs/"):
            try:
                r = int(self.path.split("/")[-1])
            except ValueError:
                self._respond(400, {"error": "invalid round number"})
                return
            log_file = self.log_dir / f"round-{r}.log"
            if not log_file.exists():
                self._respond(404, {"error": f"no logs for round {r}"})
                return
            self._respond(200, {"round": r, "entries": log_file.read_text()})
            return

        self._respond(404, {"error": "not found"})

    def do_POST(self):
        if self.path != "/log":
            self._respond(404, {"error": "not found"})
            return

        length = int(self.headers.get("Content-Length", 0))
        body = json.loads(self.rfile.read(length)) if length else {}

        r = body.get("round", self.current_round)
        log_file = self.log_dir / f"round-{r}.log"

        entry = {
            "ts": datetime.now(timezone.utc).isoformat(),
            "round": r,
            "hypothesis": body.get("hypothesis"),
            "message": body.get("message"),
            "file": body.get("file"),
            "line": body.get("line"),
            "data": body.get("data"),
        }
        with open(log_file, "a") as f:
            f.write(json.dumps(entry) + "\n")

        self._respond(200, {"status": "logged"})

    def do_OPTIONS(self):
        self.send_response(204)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def _respond(self, code, data):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(json.dumps(data).encode())

    def log_message(self, format, *args):
        pass  # suppress request logging


def main():
    parser = argparse.ArgumentParser(description="Debug log collector")
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--round", type=int, default=1)
    args = parser.parse_args()

    log_dir = Path(f"/tmp/debug-logs-{os.getpid()}")
    log_dir.mkdir(parents=True, exist_ok=True)

    DebugHandler.log_dir = log_dir
    DebugHandler.current_round = args.round

    for port in range(args.port, args.port + 6):
        try:
            server = HTTPServer(("127.0.0.1", port), DebugHandler)
            break
        except OSError:
            if port == args.port + 5:
                print(f"Error: ports {args.port}-{port} all in use", flush=True)
                raise SystemExit(1)
            continue

    print(f"Debug server listening on http://127.0.0.1:{port}", flush=True)
    print(f"Log directory: {log_dir}", flush=True)
    print(f"Current round: {args.round}", flush=True)

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nDebug server stopped.", flush=True)
        server.server_close()


if __name__ == "__main__":
    main()
