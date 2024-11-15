import os
import pyodbc
from dotenv import load_dotenv
from flask import Flask, render_template, request, redirect, url_for, flash

# Load environment variables from the .env file
load_dotenv()

app = Flask(__name__)
app.secret_key = 'proyecto3'  # Secret key for session management

# Get database credentials from environment variables
SQL_SERVER_HOST = os.getenv('SQL_SERVER_HOST')
SQL_SERVER_USER = os.getenv('SQL_SERVER_USER')
SQL_SERVER_PASSWORD = os.getenv('SQL_SERVER_PASSWORD')
SQL_SERVER_DB = os.getenv('SQL_SERVER_DB')

def get_db_connection():
    conn = pyodbc.connect(
        f'DRIVER={{ODBC Driver 17 for SQL Server}};'
        f'SERVER={SQL_SERVER_HOST};'
        f'DATABASE={SQL_SERVER_DB};'
        f'UID={SQL_SERVER_USER};'
        f'PWD={SQL_SERVER_PASSWORD}'
    )
    return conn

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        username = request.form['username']
        password = request.form['password']
        
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Login WHERE username = ? AND password = ?", (username, password))
        user = cursor.fetchone()  

        
        if user:  # If a user is found
            flash('Login successful!', 'success')  # Show success message
            return redirect(url_for('dashboard'))  # Redirect to a dashboard or home page
        else:
            flash('Invalid username or password', 'danger')  # Show error message
            return redirect(url_for('login'))  # Stay on the login page if authentication fails

    return render_template('login.html')  # Render login page for GET request

@app.route('/dashboard')
def dashboard():
    return "Welcome to your dashboard!"  # Replace with your dashboard template or page

if __name__ == '__main__':
    app.run(debug=True)