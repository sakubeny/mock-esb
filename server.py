#!/usr/bin/env python3

import json
import hashlib
from http.server import BaseHTTPRequestHandler, HTTPServer

PORT = 8088

API_KEY = "e2nfgm2bfe62vx7xsr6us53d"
SECRET = "WfY3FnqnUk"


class MockESB(BaseHTTPRequestHandler):

    def do_POST(self):

        if self.path != "/esb/v1/fmc/pia-renewal":
            self.send_response(404)
            self.end_headers()
            return

        # ==========================
        # Read Header
        # ==========================
        x_key = self.headers.get("X-Key")
        x_timestamp = self.headers.get("X-Timestamp")
        x_signature = self.headers.get("X-Signature")

        # Validasi API Key
        if x_key != API_KEY:
            self.reply({
                "meta": {
                    "status_code": "40101",
                    "status_desc": "Invalid API Key"
                }
            })
            return

        # Hitung Signature
        expected = hashlib.md5(
            f"{API_KEY}{SECRET}{x_timestamp}".encode()
        ).hexdigest()

        if expected != x_signature:
            self.reply({
                "meta": {
                    "status_code": "40102",
                    "status_desc": "Invalid Signature"
                }
            })
            return

        # ==========================
        # Read Request Body
        # ==========================
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)

        req = json.loads(body)

        service_id = req.get("service_id", "")

        if service_id == "11223344":
            with open("response/esb-success.json") as f:
                resp = json.load(f)
        else:
            with open("response/esb-not-found.json") as f:
                resp = json.load(f)

        resp["data"]["service_id"] = service_id

        self.reply(resp)

    def reply(self, obj):
        data = json.dumps(obj).encode()

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()

        self.wfile.write(data)


HTTPServer(("0.0.0.0", PORT), MockESB).serve_forever()
