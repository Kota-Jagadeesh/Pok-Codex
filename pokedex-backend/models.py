from flask_sqlalchemy import SQLAlchemy

# initialsie the SQLAlchemy
db = SQLAlchemy()

# user model for the users table
class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)  # Stores the password as plain text
    captured_pokemon = db.relationship('CapturedPokemon', backref='user', lazy=True)

# captured pokemon model to store captured Pokmon for each user
class CapturedPokemon(db.Model):
    __tablename__ = 'captured_pokemon'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    pokemon_id = db.Column(db.Integer, nullable=False)
    __table_args__ = (db.UniqueConstraint('user_id', 'pokemon_id', name='uix_user_pokemon'),)