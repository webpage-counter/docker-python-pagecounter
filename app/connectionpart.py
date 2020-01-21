import os
import json
import urllib
import urllib.request
import requests
import base64
from urllib.error import URLError, HTTPError
from urllib.request import Request, urlopen

def connection():

    url = "http://10.123.1.11:8500/v1/catalog/service/webapp-proxy-sidecar-proxy"
    req = Request(url)
    try:
        response = urlopen(req)
    except HTTPError as e:
        DB_IP="127.0.0.1"
        DB_PORT=6379
        DB_PASS="testpass"
    except URLError as e:
        DB_IP="127.0.0.1"
        DB_PORT=6379
        DB_PASS="testpass"
    else:
        print('Everything is fine')
        response = urllib.request.urlopen(url).read()
        output = json.loads(response.decode('utf-8'))
        DB_IP = output[0]["ServiceProxy"]["LocalServiceAddress"]
        DB_PORT=output[0]["ServiceProxy"]["Upstreams"][0]["LocalBindPort"]

        vault_url = "http://10.123.1.11:8500/v1/catalog/service/vault"
        vault_response = urllib.request.urlopen(vault_url).read()
        vault_output = json.loads(vault_response.decode('utf-8'))
        VAULT_IP = vault_output[0]["Address"]
        VAULT_PORT = vault_output[0]["ServicePort"]
        token_url = "http://10.123.1.11:8500/v1/kv/vault/token"
        vault_res = urllib.request.urlopen(token_url).read()
        encr_token = json.loads(vault_res.decode('utf-8'))
        ETOKEN = encr_token[0]["Value"]
        VAULT_TOKEN = base64.b64decode(ETOKEN).decode('utf-8')

        headers = {
            'X-Vault-Token': VAULT_TOKEN,
        }

        
        role_id_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/role/redis/role-id"
        ROLE_ID_RES = requests.get(role_id_url, headers=headers)
        ROLE_ID = ROLE_ID_RES.json()["data"]["role_id"]

        sec_id_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/role/redis/secret-id"
        SEC_ID_RES = requests.post(sec_id_url, headers=headers)
        SEC_ID = SEC_ID_RES.json()["data"]["secret_id"]

        login_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/auth/approle/login"
        data = '{"role_id":"' + ROLE_ID + '","secret_id":"' + SEC_ID + '"}'
        login = requests.post(login_url, data=data)
        VAULT_TOKEN = login.json()["auth"]["client_token"]
        headers = {
            'X-Vault-Token': VAULT_TOKEN,
        }
        pass_url = "http://" + str(VAULT_IP) + ":" + str(VAULT_PORT) + "/v1/kv/redis"

        redisdbpass = requests.get(pass_url, headers=headers)

        DB_PASS = redisdbpass.json()["data"]["pass"]
        

    return DB_IP, DB_PORT, DB_PASS