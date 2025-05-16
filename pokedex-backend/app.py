from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from models import db, User

app = Flask(__name__)
CORS(app)  

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pokedex.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# initialize database
db.init_app(app)

# create database tables
with app.app_context():
    db.create_all()

# register endpoint: POST /register
@app.route('/register', methods=['POST'])
def register():
    print("Received POST /register request:", request.get_json())  
    # gets the request data (username, email, password)
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    # validates the input
    if not username or not email or not password:
        return jsonify({'error': 'Username, email, and password are required'}), 422

    # checks if the username or email already exists
    if User.query.filter_by(username=username).first():
        return jsonify({'error': 'Username already exists'}), 400
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already exists'}), 400

    # creates new user with plain text password
    new_user = User(username=username, email=email, password=password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User registered successfully'}), 201

# endpoint of login: POST /login
@app.route('/login', methods=['POST'])
def login():
    print("Received POST /login request:", request.get_json())  
    # gets the request data (email, password)
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    # validates the input
    if not email or not password:
        return jsonify({'error': 'Email and password are required'}), 422

    # finds the  user by email
    user = User.query.filter_by(email=email).first()

    # checks if user exists and password matches
    if user and user.password == password:
        return jsonify({'message': 'Login successful'}), 200
    else:
        return jsonify({'error': 'Invalid email or password'}), 401

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)