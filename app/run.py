#!/usr/bin/env python
"""
Simple entry point for running the Flask app in Docker.
This avoids the relative import issues with __main__.py
"""
import os
import sys

# Add current directory to path so we can import the app package
sys.path.insert(0, os.path.dirname(__file__))

# Import the create_app function
from __init__ import create_app

if __name__ == '__main__':
    app = create_app()
    host = os.environ.get('HOST', '0.0.0.0')
    port = int(os.environ.get('PORT', 8080))

    # Run without SSL (handled by Ingress)
    app.run(host=host, port=port, debug=False)
