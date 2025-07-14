import os
import requests
from flask import Flask, request, Response

app = Flask(__name__)

# Get target URLs from environment variables with defaults
AI_ANALYSIS_SERVER = os.environ.get('AI_ANALYSIS_SERVER', 'http://localhost:8084')
MAIN_API_SERVER = os.environ.get('MAIN_API_SERVER', 'http://localhost:8080')

@app.route('/health')
def health_check():
    """Health check endpoint."""
    return "OK", 200

@app.route('/<path:path>', methods=['GET', 'POST', 'PUT', 'DELETE', 'PATCH'])
def proxy(path):
    """Proxy requests to the appropriate backend service."""
    target_url = ''

    # Route to AI server
    if path.startswith('ai/'):
        target_url = f"{AI_ANALYSIS_SERVER}/api/v1/{path}"
    # Route to main API server for all other requests
    else:
        target_url = f"{MAIN_API_SERVER}/{path}"

    # Forward the request
    try:
        resp = requests.request(
            method=request.method,
            url=target_url,
            headers={key: value for (key, value) in request.headers if key != 'Host'},
            data=request.get_data(),
            cookies=request.cookies,
            allow_redirects=False,
            params=request.args
        )

        # Exclude certain headers from the response
        excluded_headers = ['content-encoding', 'content-length', 'transfer-encoding', 'connection']
        headers = [(name, value) for (name, value) in resp.raw.headers.items()
                   if name.lower() not in excluded_headers]

        # Create a response to send back to the client
        response = Response(resp.content, resp.status_code, headers)
        return response

    except requests.exceptions.RequestException as e:
        # Handle connection errors or other request issues
        app.logger.error(f"Error proxying request to {target_url}: {e}")
        return Response(f'Proxy Error: {e}', status=502)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8085)
