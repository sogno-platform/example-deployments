# PyMFM Demo

## 0. Preliminaries

Follow the instructions here to get started:
https://sogno-platform.github.io/docs/getting-started/

### 1. Create secrets 
Create secrets for the api and results database. change "admin" to anthing you like. Do not use credentials that are in production elsewhere.
None of the values have to match eachother. Note username and password from pymfm-api-auth.
```bash
kubectl create secret generic pymfm-api-auth --from-literal=USERNAME=admin --from-literal=PASSWORD=admin
kubectl create secret generic pymfm-redis-auth --from-literal=USERNAME=admin --from-literal=PASSWORD=admin
```