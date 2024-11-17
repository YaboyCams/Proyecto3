from flask import Blueprint, render_template
from flaskr.db import get_db_connection

# Create a blueprint for the dashboard
infoTCM_bp = Blueprint('infoTCM', __name__, template_folder='templates')

@infoTCM_bp.route('/infoTCM')
def infoTCM():
    """Display a dashboard with user data in a table."""
    conn = get_db_connection()
    cursor = conn.cursor()

    # Query to fetch user data
    cursor.execute("SELECT * FROM Usuario RIGHT JOIN TipoU ON Usuario.IdTipoU = TipoU.id" )
    users = cursor.fetchall()  # Retrieve all rows

    # Pass data to the template
    return render_template('infoTCM.html', users=users)