# Initialize Firebase
import firebase_admin
import sys
import os
sys.path.append(os.path.abspath(os.path.dirname(__file__)))
from firebase_admin import credentials, firestore as admin_firestore
if not firebase_admin._apps:
    cred = credentials.Certificate("firebase_credentials.json")
    firebase_admin.initialize_app(cred)

db = admin_firestore.client()