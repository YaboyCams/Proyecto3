from flask import Flask
from flaskr.db import init_app

from flaskr.login import login_bp
from flaskr.dashboardAdmin import dashboardAdmin_bp
from flaskr.dashboardUser import dashboardUser_bp
from flaskr.infoTCM import infoTCM_bp
from flaskr.infoTCA import infoTCA_bp
from flaskr.infoEstadoCuenta import infoEstadoCuenta_bp


def create_app():
    app = Flask(__name__)
    app.secret_key = 'proyecto3'

    # Initialize database
    init_app(app)
    
    # Se deben de registrar los blueprints para cada archivo de rutas
   
    app.register_blueprint(login_bp)
    app.register_blueprint(dashboardAdmin_bp)
    app.register_blueprint(dashboardUser_bp)
    app.register_blueprint(infoTCM_bp)
    app.register_blueprint(infoTCA_bp)
    app.register_blueprint(infoEstadoCuenta_bp)

    return app