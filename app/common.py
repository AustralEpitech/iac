import os
import logging
from datetime import datetime, timezone
from flask import request, jsonify
from functools import wraps
import jwt
from .status_codes import StatusCode
from dotenv import load_dotenv

load_dotenv()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app_config = {
    'JWT_SECRET': os.getenv('JWT_SECRET'),
    'db_user': os.getenv("DB_USER"),
    'db_pass': os.getenv("DB_PASS"),
    'db_name': os.getenv("DB_NAME"),
    'db_conn_name': os.getenv("DB_CONNECTION_NAME"),
    'db_host': os.getenv("DB_HOST")
}


def parse_request_timestamp(ts_str):
    """Parse an ISO-8601 timestamp string and return a timezone-aware UTC datetime.

    Accepts timestamps with 'Z' or offsets. If the timestamp has no tzinfo,
    assume UTC. Raises ValueError if parsing fails.
    """
    dt = datetime.fromisoformat(ts_str.replace('Z', '+00:00'))
    if dt.tzinfo is None:
        dt = dt.replace(tzinfo=timezone.utc)
    return dt.astimezone(timezone.utc)


def require_auth(f):
    @wraps(f)
    def decorated_function(*args, **kwargs):
        correlation_id = request.headers.get('Correlation-Id')

        if not correlation_id:
            logger.warning("Missing Correlation-Id header")
            return jsonify({'error': 'Missing Correlation-Id header'}), StatusCode.UNAUTHORIZED

        auth_header = request.headers.get('Authorization')

        if not auth_header:
            logger.warning(f"[{correlation_id}] Missing Authorization header")
            return jsonify({'error': 'Missing Authorization header'}), StatusCode.UNAUTHORIZED
        try:
            token = auth_header.split(
                ' ')[1] if ' ' in auth_header else auth_header
            jwt.decode(token, app_config['JWT_SECRET'], algorithms=['HS512'])
        except jwt.ExpiredSignatureError:
            logger.warning(f"[{correlation_id}] Token expired")
            return jsonify({'error': 'Token expired'}), StatusCode.UNAUTHORIZED
        except jwt.InvalidTokenError:
            logger.warning(f"[{correlation_id}] Invalid token")
            return jsonify({'error': 'Invalid token'}), StatusCode.UNAUTHORIZED
        except Exception as e:
            logger.error(f"[{correlation_id}] Auth error: {str(e)}")
            return jsonify({'error': 'Authentication failed'}), StatusCode.UNAUTHORIZED

        return f(*args, **kwargs)
    return decorated_function
