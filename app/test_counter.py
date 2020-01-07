#!/usr/bin/env python3

from flask import Flask, render_template
import redis
from counter import app
from fmodule import db_incr
from connectionpart import connection
import os
import unittest


class BasicTests(unittest.TestCase):
 
    ############################
    #### setup and teardown ####
    ############################
 
    # executed prior to each test
    def setUp(self):
        app.config['TESTING'] = True
        app.config['WTF_CSRF_ENABLED'] = False
        app.config['DEBUG'] = False
        self.app = app.test_client()
 
    # executed after each test
    def tearDown(self):
        pass
 
 
###############
#### tests ####
###############
    def test_conn(self):
        DB_IP, DB_PORT, DB_PASS = connection()
        self.assertTrue(DB_IP)
        self.assertTrue(DB_PORT)
        self.assertTrue(DB_PASS)


    def test_db(self):
        DB_IP, DB_PORT, DB_PASS = connection()
        response1 = db_incr(DB_IP, DB_PORT, DB_PASS)
        response2 = db_incr(DB_IP, DB_PORT, DB_PASS)
        self.assertGreater(response2, response1)
        self.assertIsNotNone(response1)
        self.assertIsNotNone(response2)

    def test_main_page(self):
        response = self.app.get('/', follow_redirects=True)
        self.assertEqual(response.status_code, 200)
 
 
if __name__ == "__main__":
    unittest.main()