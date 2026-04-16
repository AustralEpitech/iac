from flask import Blueprint, jsonify
from .status_codes import StatusCode

bp = Blueprint('health', __name__)


@bp.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'}), StatusCode.OK
