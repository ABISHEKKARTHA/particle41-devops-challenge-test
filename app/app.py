from flask import Flask, request, jsonify
import datetime

app = Flask(__name__)

@app.route('/')
def get_time_and_ip():
    # Get client IP - check for proxy headers first
    client_ip = request.headers.get('X-Forwarded-For', request.remote_addr)
    
    return jsonify({
        "timestamp": datetime.datetime.now().isoformat(),
        "ip": client_ip
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)