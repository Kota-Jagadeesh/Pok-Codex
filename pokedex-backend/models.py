from flask_sqlalchemy import SQLAlchemy

# initializing the sqlalchemy
db = SQLAlchemy()

# user model for the users table
class User(db.Model): #defines the logical structure of the databse
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True, autoincrement=True)
    username = db.Column(db.String(50), unique=True, nullable=False)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(100), nullable=False)  #stores the password as plain text

    