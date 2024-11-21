import pyodbc
from flask import g, current_app
from dotenv import load_dotenv
import os

load_dotenv()

def get_db_connection():
    """Establish and return a database connection."""
    if 'db' not in g:
        conn = pyodbc.connect(
            f'DRIVER={{ODBC Driver 17 for SQL Server}};'
            f'SERVER={current_app.config["SQL_SERVER_HOST"]};'
            f'DATABASE={current_app.config["SQL_SERVER_DB"]};'
            f'UID={current_app.config["SQL_SERVER_USER"]};'
            f'PWD={current_app.config["SQL_SERVER_PASSWORD"]}'
        )
        g.db = conn
    return g.db

def close_db_connection(e=None):
    """Close the database connection."""
    db = g.pop('db', None)

    if db is not None:
        db.close()

def validate_user(username, password):
    """Validate user credentials against the database."""
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Usuario RIGHT JOIN TipoU ON Usuario.IdTipoU = TipoU.id WHERE Usuario.Username = ? AND Usuario.Password = ?", (username, password))
    user = cursor.fetchone()
    return user

def get_user_cards(username):
    conn = get_db_connection()
    cursor = conn.cursor()
    # Execute the stored procedure with the username parameter
    cursor.execute("EXEC GetUserCards @Username = ?", (username,))  # Comma added to create a tuple
    userInfo = cursor.fetchall()
    return userInfo

def get_user_cardsAdmin():
    conn = get_db_connection()
    cursor = conn.cursor()
    # Execute the stored procedure with the username parameter
    cursor.execute("EXEC GetUserCardsAdmin")  # Comma added to create a tuple
    userInfo = cursor.fetchall()
    return userInfo





def init_app(app):
    """Set up the database for the Flask app."""
    # Load database credentials from environment variables
    app.config['SQL_SERVER_HOST'] = os.getenv('SQL_SERVER_HOST')
    app.config['SQL_SERVER_DB'] = os.getenv('SQL_SERVER_DB')
    app.config['SQL_SERVER_USER'] = os.getenv('SQL_SERVER_USER')
    app.config['SQL_SERVER_PASSWORD'] = os.getenv('SQL_SERVER_PASSWORD')

    # Ensure database connection is closed properly
    app.teardown_appcontext(close_db_connection)