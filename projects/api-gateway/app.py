import os
import requests
from flask import Flask, request, Response

app = Flask(__name__)

# Get target URLs from environment variables with defaults
AI_ANALYSIS_SERVER = os.environ.get('AI_ANALYSIS_URL', 'http://ai-analysis-server:8086')
MAIN_API_SERVER = os.environ.get('MAIN_API_URL', 'http://main-api-server:8080')
FILE_SERVER = os.environ.get('FILE_SERVER_URL', 'http://file-server:12020')

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
        # Remove 'ai/' prefix and route to AI analysis server
        path_without_prefix = path.replace('ai/', '', 1)
        # For actuator endpoints, do not add api/v1 prefix
        if path_without_prefix.startswith('actuator/'):
            target_url = f"{AI_ANALYSIS_SERVER}/{path_without_prefix}"
        else:
            # For regular API endpoints, add api/v1 prefix
            target_url = f"{AI_ANALYSIS_SERVER}/api/v1/{path_without_prefix}"
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
    port = int(os.environ.get('SERVER_PORT', 9000))
    app.run(host='0.0.0.0', port=port)
