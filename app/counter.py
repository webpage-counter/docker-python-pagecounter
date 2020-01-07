from flask import Flask, render_template
import redis
import os
import json
import urllib
import urllib.request
import requests
from fmodule import hello, db_incr
from connectionpart import connection

app = Flask(__name__)

DB_IP, DB_PORT, DB_PASS = connection()

@app.route('/')
def runapp():
    
    return hello(DB_IP, DB_PORT, DB_PASS)

@app.route('/health')
def health():
    
    return render_template('health.html')

if __name__ == "__main__":
    app.run(host="0.0.0.0", debug=True)