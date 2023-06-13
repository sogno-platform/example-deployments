from json.tool import main
from re import X
import string
import requests
import ast
import json

def get_token():

    lurl = 'http://localhost:31250/auth/realms/master/protocol/openid-connect/token'

    params = {

        'client_id': 'admin-cli',
        'grant_type': 'password',
        'username' : 'user',
        'password': 'user'
    }
    x = requests.post(lurl, params, verify=False).content.decode('utf-8')
    return ast.literal_eval(x)['access_token']

def create_realm():
    url = "http://localhost:31250/auth/admin/realms"

    payload = json.dumps({
    "id": "grafana",
    "realm": "grafana",
    "enabled": True
    })
    headers = {
    'Content-Type': 'application/json',
    'Authorization':  'Bearer ' + str(get_token())
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print('Realm created')

def create_client():
    url = "http://localhost:31250/auth/admin/realms/grafana/clients"

    payload = json.dumps({
    "clientId": "grafana",
    "name": "grafana",
    "adminUrl": "http://localhost:31230",
    "alwaysDisplayInConsole": False,
    "secret": "Z6RT9ViirQTPgV9AQqoZwGm38XHyUROY",

    "access": {
        "view": True,
        "configure": True,
        "manage": True
    },
    "attributes": {},
    "authenticationFlowBindingOverrides": {},
    "authorizationServicesEnabled": True,
    "bearerOnly": False,
    "directAccessGrantsEnabled": True,
    "enabled": True,
    "protocol": "openid-connect",
    "description": "grafana",
    "rootUrl": "http://localhost:31230",
    "surrogateAuthRequired": False,
    "clientAuthenticatorType": "client-secret",
    "defaultRoles": [
        "manage-account",
        "view-profile"
    ],
    "redirectUris": [
        "http://localhost:31230/*",
        "http://localhost:31230/login/generic_oauth"
    ],
    "webOrigins": [],
    "notBefore": 0,
    "consentRequired": False,
    "standardFlowEnabled": True,
    "implicitFlowEnabled": False,
    "serviceAccountsEnabled": True,
    "publicClient": False,
    "frontchannelLogout": False,
    "fullScopeAllowed": False,
    "nodeReRegistrationTimeout": 0,
    "defaultClientScopes": [
        "web-origins",
        "role_list",
        "profile",
        "roles",
        "email"
    ],
    "optionalClientScopes": [
        "address",
        "phone",
        "offline_access",
        "microprofile-jwt"
    ]
    })
    headers = {
    'Content-Type': 'application/json',
    'Authorization':  'Bearer ' + str(get_token())
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print('client created')


def create_user():
    url = "http://localhost:31250/auth/admin/realms/grafana/users"

    payload = json.dumps({
    "createdTimestamp": 1588880747548,
    "username": "demo",
    "enabled": True,
    "totp": False,
    "emailVerified": True,
    "firstName": "user",
    "lastName": "grafana",
    "email": "user_grafana@grafana.com",
    "disableableCredentialTypes": [],
    "requiredActions": [],
    "notBefore": 0,
    "access": {
        "manageGroupMembership": True,
        "view": True,
        "mapRoles": True,
        "impersonate": True,
        "manage": True
    },
    "credentials": [{
        "type":"password",
        "value":"demo",
        "temporary":False,
    }],
    "realmRoles": [
        "mb-user"
    ]
    })
    headers = {
    'Content-Type': 'application/json',
    'Authorization':  'Bearer ' + str(get_token())
    }

    response = requests.request("POST", url, headers=headers, data=payload)

    print('user created')

def function():
    create_realm()
    create_client()
    create_user()

function()
