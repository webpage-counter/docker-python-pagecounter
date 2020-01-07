from flask import Flask, render_template
import redis

def db_incr(IP, PORT, PASS):
    conn = redis.StrictRedis(host=IP, port=PORT, password=PASS)
    conn.incr('hits')
    count = int(conn.get('hits'))
    return count

def hello(IP, PORT, PASS):
    count = db_incr(IP, PORT, PASS)
    return render_template('index.html', count = count)