"""
HTTP Status Codes class
"""
from enum import IntEnum


class StatusCode(IntEnum):
    """HTTP Status Codes used by the API"""
    OK = 200  # Successful GET/PUT/DELETE
    CREATED = 201  # Successful POST
    BAD_REQUEST = 400  # Invalid request body
    UNAUTHORIZED = 401  # Missing or invalid authentication
    NOT_FOUND = 404  # Resource not found
    CONFLICT = 409  # Timestamp/concurrency/duplicate conflict
    TOO_MANY_REQUESTS = 429  # Cluster temporarily overloaded
    INTERNAL_SERVER_ERROR = 500  # Unexpected server failures

