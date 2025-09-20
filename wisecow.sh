#!/bin/bash
# wisecow.sh - Web server that serves fortune quotes with cowsay

SRVPORT=${SRVPORT:-4499}

# Create a simple HTML page
cat << 'EOF' > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>WiseCow - Fortune with Style</title>
    <style>
        body {
            font-family: 'Courier New', monospace;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
            color: white;
            min-height: 100vh;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
            text-align: center;
            background: rgba(0,0,0,0.2);
            padding: 30px;
            border-radius: 15px;
            backdrop-filter: blur(10px);
        }
        h1 { color: #ffd700; margin-bottom: 30px; }
        #fortune {
            background: rgba(0,0,0,0.5);
            padding: 20px;
            border-radius: 10px;
            margin: 20px 0;
            white-space: pre-wrap;
            min-height: 200px;
            border: 2px solid #ffd700;
        }
        button {
            background: #ffd700;
            border: none;
            padding: 12px 25px;
            border-radius: 25px;
            cursor: pointer;
            font-size: 16px;
            font-weight: bold;
            color: #333;
            transition: transform 0.2s;
        }
        button:hover {
            transform: scale(1.05);
        }
        .loading {
            color: #ffd700;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🐄 WiseCow - Fortune with Style 🐄</h1>
        <div id="fortune" class="loading">Loading your fortune...</div>
        <button onclick="getFortune()">🎲 Get New Fortune</button>
        <p><small>Powered by fortune-mod and cowsay</small></p>
    </div>
    
    <script>
        function getFortune() {
            document.getElementById('fortune').innerHTML = '<div class="loading">Getting new fortune...</div>';
            fetch('/fortune')
                .then(response => response.text())
                .then(data => {
                    document.getElementById('fortune').innerText = data;
                })
                .catch(error => {
                    document.getElementById('fortune').innerText = 'Error: ' + error.message;
                });
        }
        
        // Load fortune on page load
        window.onload = getFortune;
        
        // Auto-refresh every 30 seconds
        setInterval(getFortune, 30000);
    </script>
</body>
</html>
EOF

# Start Python web server
python3 << 'PYEOF' &
import http.server
import socketserver
import subprocess
import urllib.parse as urlparse
import os
import json
import time

class WiseCowHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/' or self.path == '/index.html':
            self.path = '/index.html'
        elif self.path == '/fortune':
            self.send_response(200)
            self.send_header('Content-type', 'text/plain; charset=utf-8')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            try:
                # Get a fortune
                fortune_output = subprocess.check_output(
                    ['fortune', '-s'], 
                    text=True, 
                    stderr=subprocess.DEVNULL
                ).strip()
                
                # Pipe through cowsay
                cowsay_output = subprocess.check_output(
                    ['cowsay', '-W', '60'], 
                    input=fortune_output, 
                    text=True,
                    stderr=subprocess.DEVNULL
                )
                
                self.wfile.write(cowsay_output.encode('utf-8'))
            except subprocess.CalledProcessError as e:
                error_msg = f"Error running fortune/cowsay: {str(e)}"
                self.wfile.write(error_msg.encode('utf-8'))
            except Exception as e:
                error_msg = f"Unexpected error: {str(e)}"
                self.wfile.write(error_msg.encode('utf-8'))
            return
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            health_data = {
                "status": "healthy",
                "timestamp": int(time.time()),
                "version": "1.0.0"
            }
            self.wfile.write(json.dumps(health_data).encode('utf-8'))
            return
            
        elif self.path == '/metrics':
            # Basic Prometheus-style metrics
            self.send_response(200)
            self.send_header('Content-type', 'text/plain')
            self.end_headers()
            metrics = f"""# HELP wisecow_requests_total Total number of requests
# TYPE wisecow_requests_total counter
wisecow_requests_total {{method="GET",endpoint="/fortune"}} 1

# HELP wisecow_up Whether the service is up
# TYPE wisecow_up gauge
wisecow_up 1
"""
            self.wfile.write(metrics.encode('utf-8'))
            return
        
        # Serve static files
        super().do_GET()

    def log_message(self, format, *args):
        # Enhanced logging
        print(f"[{self.log_date_time_string()}] {format % args}")

# Configure server
PORT = int(os.environ.get('SRVPORT', 4499))
Handler = WiseCowHandler

print(f"🐄 Starting WiseCow server on port {PORT}")
print(f"📁 Serving from directory: {os.getcwd()}")

try:
    with socketserver.TCPServer(("", PORT), Handler) as httpd:
        print(f"✅ WiseCow server ready at http://localhost:{PORT}")
        httpd.serve_forever()
except KeyboardInterrupt:
    print("\n🛑 Server stopped by user")
except Exception as e:
    print(f"❌ Server error: {e}")
    exit(1)
PYEOF

# Wait for the Python server process
wait
