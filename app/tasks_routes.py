from flask import Blueprint, request, jsonify
from .status_codes import StatusCode
from .common import require_auth, parse_request_timestamp, app_config, logger
from .models import db, Task
from datetime import timezone
from sqlalchemy.exc import SQLAlchemyError

bp = Blueprint('tasks', __name__)


def validate_task_data(data, require_all=False):
    required_fields = ['title', 'content', 'due_date'] if require_all else []
    errors = []

    for field in required_fields:
        if field not in data or not data[field]:
            errors.append(f"Missing required field: {field}")

    if 'due_date' in data and data['due_date']:
        try:
            from datetime import datetime
            datetime.strptime(data['due_date'], '%Y-%m-%d')
        except ValueError:
            errors.append("Invalid due_date format. Expected YYYY-MM-DD")

    # request_timestamp format
    if 'request_timestamp' in data and data['request_timestamp']:
        try:
            parse_request_timestamp(data['request_timestamp'])
        except Exception:
            errors.append(
                "Invalid request_timestamp format. Expected ISO 8601")
    if 'done' in data and data['done'] is not None:
        if not isinstance(data['done'], bool):
            errors.append("Field 'done' must be a boolean")

    return errors


@bp.route('/tasks', methods=['POST'])
@require_auth
def create_task():
    correlation_id = request.headers.get('Correlation-Id')
    logger.info(f"[{correlation_id}] POST /tasks incoming")
    try:
        # Validate in coming task
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid request body'}), StatusCode.BAD_REQUEST

        errors = validate_task_data(data, require_all=True)
        if errors:
            return jsonify({'error': 'Validation failed', 'details': errors}), StatusCode.BAD_REQUEST

        if 'request_timestamp' not in data:
            return jsonify({'error': 'Missing required field: request_timestamp'}), StatusCode.BAD_REQUEST

        #################
        # Create task (Add to db)
        req_dt = parse_request_timestamp(data['request_timestamp'])

        task = Task(
            title=data['title'],
            content=data['content'],
            due_date=data['due_date'],
            done=data.get('done', False),
            created_at=req_dt,
            updated_at=req_dt,
            correlation_id=correlation_id
        )
        db.session.add(task)
        db.session.commit()
        logger.info(f"[{correlation_id}] Created task {task.id}")
        return jsonify(task.to_dict()), StatusCode.CREATED
    except SQLAlchemyError as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Database error: {str(e)}")
        return jsonify({'error': 'Database error'}), StatusCode.INTERNAL_SERVER_ERROR
    except Exception as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), StatusCode.INTERNAL_SERVER_ERROR


@bp.route('/tasks', methods=['GET'])
@require_auth
def list_tasks():
    correlation_id = request.headers.get('Correlation-Id')
    try:
        logger.info(f"[{correlation_id}] GET /tasks incoming")
        tasks = Task.query.order_by(Task.created_at).all()
        return jsonify([task.to_dict() for task in tasks]), StatusCode.OK
    except SQLAlchemyError as e:
        logger.error(f"[{correlation_id}] Database error: {str(e)}")
        return jsonify({'error': 'Database error'}), StatusCode.INTERNAL_SERVER_ERROR
    except Exception as e:
        logger.error(f"[{correlation_id}] Error listing tasks: {str(e)}")
        return jsonify({'error': 'Internal server error'}), StatusCode.INTERNAL_SERVER_ERROR


@bp.route('/tasks/<task_id>', methods=['GET'])
@require_auth
def get_task(task_id):
    correlation_id = request.headers.get('Correlation-Id')
    try:
        logger.info(f"[{correlation_id}] GET /tasks/{task_id} incoming")
        task = Task.query.filter_by(id=task_id).first()
        if not task:
            return jsonify({'error': 'Task not found'}), StatusCode.NOT_FOUND
        return jsonify(task.to_dict()), StatusCode.OK
    except SQLAlchemyError as e:
        logger.error(f"[{correlation_id}] Database error: {str(e)}")
        return jsonify({'error': 'Database error'}), StatusCode.INTERNAL_SERVER_ERROR
    except Exception as e:
        logger.error(
            f"[{correlation_id}] Error getting task {task_id}: {str(e)}")
        return jsonify({'error': 'Internal server error'}), StatusCode.INTERNAL_SERVER_ERROR


@bp.route('/tasks/<task_id>', methods=['PUT'])
@require_auth
def update_task(task_id):
    correlation_id = request.headers.get('Correlation-Id')
    logger.info(f"[{correlation_id}] PUT /tasks/{task_id} incoming")
    try:
        data = request.get_json()
        if not data:
            return jsonify({'error': 'Invalid request body'}), StatusCode.BAD_REQUEST

        errors = validate_task_data(data)
        if errors:
            return jsonify({'error': 'Validation failed', 'details': errors}), StatusCode.BAD_REQUEST

        if 'request_timestamp' not in data:
            return jsonify({'error': 'Missing required field: request_timestamp'}), StatusCode.BAD_REQUEST

        req_dt = parse_request_timestamp(data['request_timestamp'])

        task = Task.query.filter_by(id=task_id).first()
        if not task:
            return jsonify({'error': 'Task not found'}), StatusCode.NOT_FOUND
        if task.updated_at.tzinfo is None:
            task_updated_at = task.updated_at.replace(tzinfo=timezone.utc)
        else:
            task_updated_at = task.updated_at

        if req_dt < task_updated_at:
            return jsonify({'error': 'Conflict: request timestamp is older than last update'}), StatusCode.CONFLICT

        # Update fields
        if 'title' in data:
            task.title = data['title']
        if 'content' in data:
            task.content = data['content']
        if 'due_date' in data:
            task.due_date = data['due_date']
        if 'done' in data:
            task.done = data['done']
        task.updated_at = req_dt

        db.session.commit()
        logger.info(f"[{correlation_id}] Updated task {task_id}")
        return jsonify(task.to_dict()), StatusCode.OK

    except SQLAlchemyError as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Database error: {str(e)}")
        return jsonify({'error': 'Database error'}), StatusCode.INTERNAL_SERVER_ERROR
    except Exception as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), StatusCode.INTERNAL_SERVER_ERROR


@bp.route('/tasks/<task_id>', methods=['DELETE'])
@require_auth
def delete_task(task_id):
    correlation_id = request.headers.get('Correlation-Id')
    logger.info(f"[{correlation_id}] DELETE /tasks/{task_id} incoming")
    try:
        data = request.get_json() or {}
        if 'request_timestamp' not in data:
            return jsonify({'error': 'Missing required field: request_timestamp'}), StatusCode.BAD_REQUEST

        req_dt = parse_request_timestamp(data['request_timestamp'])

        task = Task.query.filter_by(id=task_id).first()
        if not task:
            return jsonify({'error': 'Task not found'}), StatusCode.NOT_FOUND

        if task.updated_at.tzinfo is None:
            task_updated_at = task.updated_at.replace(tzinfo=timezone.utc)
        else:
            task_updated_at = task.updated_at

        if req_dt < task_updated_at:
            return jsonify({'error': 'Conflict: request timestamp is older than last update'}), StatusCode.CONFLICT

        db.session.delete(task)
        db.session.commit()
        logger.info(f"[{correlation_id}] Deleted task {task_id}")
        return jsonify(task.to_dict()), StatusCode.OK

    except SQLAlchemyError as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Database error: {str(e)}")
        return jsonify({'error': 'Database error'}), StatusCode.INTERNAL_SERVER_ERROR
    except Exception as e:
        db.session.rollback()
        logger.error(f"[{correlation_id}] Error: {str(e)}")
        return jsonify({'error': 'Internal server error'}), StatusCode.INTERNAL_SERVER_ERROR
