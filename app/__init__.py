import time
import logging
from flask import Flask
from sqlalchemy.exc import OperationalError
from .common import app_config
from .models import db

# Set up simple logging to see what's happening in the pod logs
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_app():
    app = Flask(__name__)

    app.config['JWT_SECRET'] = app_config.get('JWT_SECRET')
    
    # DB Connection String Logic
    if not app_config["db_host"]:
        # Path for Unix Socket (if DB_HOST is empty)
        app.config['SQLALCHEMY_DATABASE_URI'] = (
            f"postgresql://{app_config['db_user']}:{app_config['db_pass']}@/"
            f"{app_config['db_name']}?host=/cloudsql/{app_config['db_conn_name']}"
        )
    else:
        # Path for TCP (Sidecar Proxy)
        app.config['SQLALCHEMY_DATABASE_URI'] = (
            f"postgresql://{app_config['db_user']}:{app_config['db_pass']}@"
            f"{app_config['db_host']}:5432/{app_config['db_name']}"
        )
    
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    with app.app_context():
        max_retries = 10
        for i in range(max_retries):
            try:
                db.create_all()
                logger.info("✅ Database connection successful and tables created!")
                break
            except OperationalError as e:
                if i == max_retries - 1:
                    logger.error("❌ Could not connect to database after multiple retries.")
                    raise e
                logger.warning(f"⏳ Database not ready yet. Retrying in 2 seconds... ({i+1}/{max_retries})")
                time.sleep(2)

    from .health_routes import bp as health_bp
    from .tasks_routes import bp as tasks_bp

    app.register_blueprint(health_bp)
    app.register_blueprint(tasks_bp)

    return app