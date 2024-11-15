from flask import Blueprint, render_template, request, redirect, url_for, flash
from flaskr.db import validate_user  # Import validate_user from db.py

login_bp = Blueprint('login', __name__, template_folder='templates')

@login_bp.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        try:
            user = validate_user(username, password)  # Validate user credentials

            if user and user.type == "Admin":  # Check if user exists and is an Admin
                flash('Login successful!', 'success')  # Show success message
                return redirect(url_for('dashboardAdmin.dashboardAdmin'))  # Redirect to dashboard
            if user and user.type == "User":  # Check if user exists and is an Admin
                flash('Login successful!', 'success')  # Show success message
                return redirect(url_for('dashboardUser.dashboardUser'))  # Redirect to dashboard
            else:
                flash('Invalid username or password', 'danger')  # Show error message
                return redirect(url_for('login.login'))  # Stay on login page
        
        except Exception as e:
            # Log the error (You can replace this with logging functionality)
            print(f"Error: {e}")
            flash('An error occurred while processing your request. Please try again later.', 'danger')
            return redirect(url_for('login.login'))  # Stay on login page if an error occurs

    return render_template('login.html')  # Render login page for GET request