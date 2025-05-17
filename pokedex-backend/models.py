from flask_sqlalchemy import SQLAlchemy

#initialise the SQLAlchemy
db = SQLAlchemy()

#user model for the users table
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)  #stores the password as plain text
    captured_pokemon = db.relationship('CapturedPokemon', backref='user', lazy=True)
    trades_sent = db.relationship('TradedPokemon', backref='sender', foreign_keys='TradedPokemon.sender_user_id', lazy=True)
    trades_received = db.relationship('TradedPokemon', backref='receiver', foreign_keys='TradedPokemon.receiver_user_id', lazy=True)

#captured pokemon model to store captured pokemon for each user
class CapturedPokemon(db.Model):
    __tablename__ = 'captured_pokemon'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    pokemon_id = db.Column(db.Integer, nullable=False)
    __table_args__ = (db.UniqueConstraint('user_id', 'pokemon_id', name='uix_user_pokemon'),)

#traded pokemon model to store trades between users
class TradedPokemon(db.Model):
    __tablename__ = 'traded_pokemon'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    pokemon_id = db.Column(db.Integer, nullable=False)
    sender_user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    receiver_user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    __table_args__ = (db.UniqueConstraint('pokemon_id', 'sender_user_id', 'receiver_user_id', name='uix_trade'),)