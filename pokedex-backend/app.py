from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from models import db, User, CapturedPokemon

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pokedex.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# initiaises the database
db.init_app(app)

# creates database tables
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

# endpoint for login: POST /login
@app.route('/login', methods=['POST'])
def login():
    print("Received POST /login request:", request.get_json())
    # gets the request data (email, password)
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    # vallidates the input
    if not email or not password:
        return jsonify({'error': 'Email and password are required'}), 422

    # finds the user by email
    user = User.query.filter_by(email=email).first()

    # checks if user exists and password matches
    if user and user.password == password:
        return jsonify({'message': 'Login successful', 'user_id': user.id}), 200
    else:
        return jsonify({'error': 'Invalid email or password'}), 401

# endpoit to capture a Pokémon: POST /capture
@app.route('/capture', methods=['POST'])
def capture_pokemon():
    print("Received POST /capture request:", request.get_json())
    data = request.get_json()
    user_id = data.get('user_id')
    pokemon_id = data.get('pokemon_id')

    # validates the input
    if not user_id or not pokemon_id:
        return jsonify({'error': 'User ID and Pokémon ID are required'}), 422

    # checks if the user exists
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    #checks if the Pokémon is already captured
    existing_capture = CapturedPokemon.query.filter_by(user_id=user_id, pokemon_id=pokemon_id).first()
    if existing_capture:
        return jsonify({'message': 'Pokémon already captured'}), 200

    #captures the Pokémon
    new_capture = CapturedPokemon(user_id=user_id, pokemon_id=pokemon_id)
    db.session.add(new_capture)
    db.session.commit()

    return jsonify({'message': 'Pokémon captured successfully'}), 201

#endpoint to get captured Pokémon: GET /captured/<user_id>
@app.route('/captured/<int:user_id>', methods=['GET'])
def get_captured_pokemon(user_id):
    print(f"Received GET /captured/{user_id} request")
    # check if the user exists
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    #gets the list of captured Pokémon
    captured = CapturedPokemon.query.filter_by(user_id=user_id).all()
    captured_ids = [capture.pokemon_id for capture in captured]

    return jsonify({'captured_pokemon': captured_ids}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)