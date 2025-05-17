from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from models import db, User, CapturedPokemon, TradedPokemon

app = Flask(__name__)
CORS(app)

app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///pokedex.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

# initialie the database
db.init_app(app)

#creates database tables
with app.app_context():
    db.create_all()

#registers endpoint: POST /register
@app.route('/register', methods=['POST'])
def register():
    print("Received POST /register request:", request.get_json())
    data = request.get_json()
    username = data.get('username')
    email = data.get('email')
    password = data.get('password')

    if not username or not email or not password:
        return jsonify({'error': 'Username, email, and password are required'}), 422

    if User.query.filter_by(username=username).first():
        return jsonify({'error': 'Username already exists'}), 400
    if User.query.filter_by(email=email).first():
        return jsonify({'error': 'Email already exists'}), 400

    new_user = User(username=username, email=email, password=password)
    db.session.add(new_user)
    db.session.commit()

    return jsonify({'message': 'User registered successfully'}), 201

#endpoint for login: POST /login
@app.route('/login', methods=['POST'])
def login():
    print("Received POST /login request:", request.get_json())
    data = request.get_json()
    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'error': 'Email and password are required'}), 422

    user = User.query.filter_by(email=email).first()

    if user and user.password == password:
        return jsonify({'message': 'Login successful', 'user_id': user.id}), 200
    else:
        return jsonify({'error': 'Invalid email or password'}), 401

#endpoint to capture a Pokémon: POST /capture
@app.route('/capture', methods=['POST'])
def capture_pokemon():
    print("Received POST /capture request:", request.get_json())
    data = request.get_json()
    user_id = data.get('user_id')
    pokemon_id = data.get('pokemon_id')

    if not user_id or not pokemon_id:
        return jsonify({'error': 'User ID and Pokémon ID are required'}), 422

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    existing_capture = CapturedPokemon.query.filter_by(user_id=user_id, pokemon_id=pokemon_id).first()
    if existing_capture:
        return jsonify({'message': 'Pokémon already captured'}), 200

    new_capture = CapturedPokemon(user_id=user_id, pokemon_id=pokemon_id)
    db.session.add(new_capture)
    db.session.commit()

    return jsonify({'message': 'Pokémon captured successfully'}), 201

#endpoints to get captured Pokémon: GET /captured/<user_id>
@app.route('/captured/<int:user_id>', methods=['GET'])
def get_captured_pokemon(user_id):
    print(f"Received GET /captured/{user_id} request")
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    captured = CapturedPokemon.query.filter_by(user_id=user_id).all()
    captured_ids = [capture.pokemon_id for capture in captured]

    return jsonify({'captured_pokemon': captured_ids}), 200

#endpoint to get all users: GET /users
@app.route('/users', methods=['GET'])
def get_users():
    print("Received GET /users request")
    users = User.query.all()
    users_list = [{'id': user.id, 'username': user.username} for user in users]
    return jsonify({'users': users_list}), 200

#updated endpoint to trade a Pokémon: POST /trade
@app.route('/trade', methods=['POST'])
def trade_pokemon():
    print("Received POST /trade request:", request.get_json())
    data = request.get_json()
    sender_user_id = data.get('sender_user_id')
    receiver_user_id = data.get('receiver_user_id')
    pokemon_id = data.get('pokemon_id')

    # validates input
    if not sender_user_id or not receiver_user_id or not pokemon_id:
        print(f"Validation failed: Missing required fields - sender_user_id={sender_user_id}, receiver_user_id={receiver_user_id}, pokemon_id={pokemon_id}")
        return jsonify({'error': 'Sender user ID, receiver user ID, and Pokémon ID are required'}), 422

    # checks if sender and receiver are the same
    if sender_user_id == receiver_user_id:
        print(f"Validation failed: Sender and receiver are the same - user_id={sender_user_id}")
        return jsonify({'error': 'Cannot trade with yourself'}), 400

    # verifie sender and receiver exist
    sender = User.query.get(sender_user_id)
    receiver = User.query.get(receiver_user_id)
    if not sender:
        print(f"Sender not found: sender_user_id={sender_user_id}")
        return jsonify({'error': 'Sender not found'}), 404
    if not receiver:
        print(f"Receiver not found: receiver_user_id={receiver_user_id}")
        return jsonify({'error': 'Receiver not found'}), 404

    # check if the sender has the pokemon in their captured list
    captured = CapturedPokemon.query.filter_by(user_id=sender_user_id, pokemon_id=pokemon_id).first()
    if not captured:
        # check if the pokemon was previously traded by the sender
        previous_trade = TradedPokemon.query.filter_by(sender_user_id=sender_user_id, pokemon_id=pokemon_id).first()
        if previous_trade:
            print(f"Trade failed: Pokémon {pokemon_id} already traded by sender {sender_user_id} to receiver {previous_trade.receiver_user_id}")
            return jsonify({'error': f'You already traded this Pokémon (ID: {pokemon_id})'}), 400
        print(f"Trade failed: Pokémon {pokemon_id} not found in sender {sender_user_id}'s captured list")
        return jsonify({'error': f'Pokémon (ID: {pokemon_id}) not found in your captured list. Have you captured it?'}), 400

    # remove the pokemon from the sender's captured list
    print(f"Removing Pokémon {pokemon_id} from sender {sender_user_id}'s captured list")
    db.session.delete(captured)

    # log the trade in tradepokemon 
    print(f"Logging trade: Pokémon {pokemon_id} from sender {sender_user_id} to receiver {receiver_user_id}")
    new_trade = TradedPokemon(
        pokemon_id=pokemon_id,
        sender_user_id=sender_user_id,
        receiver_user_id=receiver_user_id
    )
    db.session.add(new_trade)

    # commits the transaction
    try:
        db.session.commit()
        print(f"Trade successful: Pokémon {pokemon_id} traded from sender {sender_user_id} to receiver {receiver_user_id}")
        return jsonify({'message': 'Pokémon traded successfully'}), 201
    except Exception as e:
        db.session.rollback()
        print(f"Trade failed during commit: {str(e)}")
        return jsonify({'error': 'An error occurred while processing the trade'}), 500

# endpoints to get traded Pokmon: GET /traded/<user_id>
@app.route('/traded/<int:user_id>', methods=['GET'])
def get_traded_pokemon(user_id):
    print(f"Received GET /traded/{user_id} request")
    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # get pokemon that were traded to this user (i.e., user is the receiver)
    traded = TradedPokemon.query.filter_by(receiver_user_id=user_id).all()
    traded_ids = [trade.pokemon_id for trade in traded]

    return jsonify({'traded_pokemon': traded_ids}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)