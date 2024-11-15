from flask import Blueprint, render_template
from flaskr.db import get_db_connection

# Create a blueprint for the dashboard
dashboardAdmin_bp = Blueprint('dashboardAdmin', __name__, template_folder='templates')

@dashboardAdmin_bp.route('/dashboardAdmin')
def dashboardAdmin():
    """Display a dashboard with user data in a table."""
    conn = get_db_connection()
    cursor = conn.cursor()

    # Query to fetch user data
    cursor.execute("SELECT  * FROM Usuario")
    users = cursor.fetchall()  # Retrieve all rows

    # Pass data to the template
    return render_template('dashboardAdmin.html', users=users)