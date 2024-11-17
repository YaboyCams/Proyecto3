from flask import Blueprint, render_template
from flaskr.db import get_db_connection

# Create a blueprint for the dashboard
infoTCA_bp = Blueprint('infoTCA', __name__, template_folder='templates')

@infoTCA_bp.route('/infoTCA')
def infoTCM():
    """Display a dashboard with user data in a table."""
    conn = get_db_connection()
    cursor = conn.cursor()

    # Query to fetch user data
    cursor.execute("SELECT * FROM Usuario RIGHT JOIN TipoU ON Usuario.IdTipoU = TipoU.id" )
    users = cursor.fetchall()  # Retrieve all rows

    # Pass data to the template
    return render_template('infoTCA.html', users=users)