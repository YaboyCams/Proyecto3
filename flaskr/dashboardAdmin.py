from flask import Blueprint, render_template,request
from flaskr.db import get_db_connection, get_user_cardsAdmin

# Create a blueprint for the dashboard
dashboardAdmin_bp = Blueprint('dashboardAdmin', __name__, template_folder='templates')

@dashboardAdmin_bp.route('/dashboardAdmin')
def dashboardAdmin():

    
    userType = request.args.get('type') 
    userInfo = get_user_cardsAdmin()
    
    
    return render_template('dashboardAdmin.html', userInfo=userInfo,userType=userType)


 
    
