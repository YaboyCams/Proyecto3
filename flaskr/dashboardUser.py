from flask import Blueprint, render_template,request
from flaskr.db import get_db_connection, get_user_cards

# Create a blueprint for the dashboard
dashboardUser_bp = Blueprint('dashboardUser', __name__, template_folder='templates')

@dashboardUser_bp.route('/dashboardUser')
def dashboardUser():
    
     
    idUser = request.args.get('id')  # Retrieve the 'id' parameter
    userType = request.args.get('type') 
    userInfo = get_user_cards(idUser)
    

    # Pass data to the template
    return render_template('dashboardUser.html', userInfo=userInfo,userType=userType)