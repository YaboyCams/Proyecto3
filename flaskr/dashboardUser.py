from flask import Blueprint, render_template
from flaskr.db import get_db_connection

# Create a blueprint for the dashboard
dashboardUser_bp = Blueprint('dashboardUser', __name__, template_folder='templates')

@dashboardUser_bp.route('/dashboardUser')
def dashboardUser():
    """Display a dashboard with user data in a table."""
    conn = get_db_connection()
    cursor = conn.cursor()

    # Query to fetch user data
    cursor.execute("SELECT Username FROM Usuario")
    users = cursor.fetchall()  # Retrieve all rows

    # Pass data to the template
    return render_template('dashboardUser.html', users=users)