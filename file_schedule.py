from flask import Flask, jsonify, request
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from datetime import datetime, timedelta
import os

app = Flask(__name__)
CORS(app)

basedir = os.path.abspath(os.path.dirname(__file__))
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///' + os.path.join(basedir, 'db.sqlite3')
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)

class Session(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    code = db.Column(db.String(10), nullable=False)
    type = db.Column(db.String(10), nullable=False)
    room = db.Column(db.String(50))
    name = db.Column(db.String(100), nullable=False)
    professor = db.Column(db.String(100))
    time_slot = db.Column(db.Integer, nullable=False)
    day = db.Column(db.String(10), nullable=False)
    is_online = db.Column(db.Boolean, default=False)
    week = db.Column(db.Integer, nullable=False)
    semester = db.Column(db.String(5), nullable=False)
    last_modified = db.Column(db.DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

@app.route('/updates', methods=['GET'])
def check_updates():
    if_modified_since = request.headers.get('If-Modified-Since')
    
    if if_modified_since:
        last_update = datetime.strptime(if_modified_since, '%a, %d %b %Y %H:%M:%S %Z')
        last_modified = Session.query.order_by(Session.last_modified.desc()).first().last_modified
        
        if last_modified <= last_update:
            return '', 304
    
    return '', 200

@app.route('/api/schedule/metadata', methods=['GET'])
def get_schedule_metadata():
    current_week = 12
    semester = "S3"
    start_date = datetime.now() - timedelta(days=datetime.now().weekday())
    end_date = start_date + timedelta(days=6)
    
    return jsonify({
        "metadata": {
            "semester": semester,
            "week": current_week,
            "date_range": {
                "start": start_date.strftime("%Y-%m-%d"),
                "end": end_date.strftime("%Y-%m-%d")
            }
        }
    })

@app.route('/api/schedule/sessions', methods=['GET'])
def get_schedule_sessions():
    current_week = 12
    sessions = Session.query.filter_by(week=current_week).all()
    
    return jsonify({
        "sessions": [{
            "code": s.code,
            "type": s.type,
            "room": s.room,
            "name": s.name,
            "professor": s.professor,
            "time_slot": s.time_slot,
            "day": s.day,
            "is_online": s.is_online
        } for s in sessions]
    })

def init_db():
    with app.app_context():
        db.drop_all()
        db.create_all()
        
        sample_sessions = [
            # Lundi
            Session(code="IRT", type="IRT", room="104", name="just be you so please be aware ", professor="MOhamedou", time_slot=1, day="Lundi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="104", name="Développement JEE", professor="Mohamedou", time_slot=2, day="Lundi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="104", name="Théorie des langages et compilation", professor="Hafedh", time_slot=3, day="Lundi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="104", name="Réseaux d'opérateurs", professor="El Aoun", time_slot=4, day="Lundi", week=12, semester="S3"),
            
            # Mardi            
            Session(code="", type="HE", room="", name="", professor="", time_slot=1, day="Mardi", week=12, semester="S3"),
            Session(code="", type="HE", room="", name="", professor="", time_slot=2, day="Mardi", week=12, semester="S3"),
            Session(code="", type="HE", room="", name="", professor="", time_slot=3, day="Mardi", week=12, semester="S3"),
            Session(code="IRT32", type="Devoir", room="104", name="Développement JEE", professor="Aboubécrine", time_slot=4, day="Mardi", week=12, semester="S3"),
            
            # Mercredi            
            Session(code="", type="HE", room="", name="", professor="", time_slot=1, day="Mercredi", week=12, semester="S3"),
            Session(code="", type="HE", room="", name="", professor="", time_slot=2, day="Mercredi", week=12, semester="S3"),
            Session(code="", type="HE", room="", name="", professor="", time_slot=3, day="Mercredi", week=12, semester="S3"),
            Session(code="", type="IRT", room="", name="Enseignement militaire", professor="", time_slot=4, day="Mercredi", week=12, semester="S3"),

            # Jeudi            
            Session(code="IRT32", type="IRT", room="104", name="Intelligence artificielle", professor="Hafedh", time_slot=1, day="Jeudi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="Lab Electro", name="Architecture des ordinateurs", professor="Sass", time_slot=2, day="Jeudi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="Lab Electro", name="Architecture des ordinateurs", professor="Sass", time_slot=3, day="Jeudi", week=12, semester="S3"),
            Session(code="IRT32", type="IRT", room="", name="IoT", professor="Elhacen", time_slot=4, day="Jeudi", week=12, semester="S3", is_online=True),

            # Vendredi            
            Session(code="", type="HE", room="", name="", professor="", time_slot=1, day="Vendredi", week=12, semester="S3"),
            Session(code="IRT32", type="Devoir", room="104", name="Théorie des langages et compilation", professor="Hafedh", time_slot=2, day="Vendredi", week=12, semester="S3"),
            Session(code="IRT32", type="Devoir", room="104", name="Architecture des ordinateurs", professor="Sass", time_slot=3, day="Vendredi", week=12, semester="S3")
        ]

        db.session.add_all(sample_sessions)
        db.session.commit()

    

if __name__ == '__main__':
    init_db()
    app.run(debug=True, port=5000)