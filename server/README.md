# Server component

Provides a mock database via a REST API.
Endpoints implemented on node Express.js via purescript library (see dependencies).

### Build and Play

```
cd server
npm install
pulp dep install
pulp run
```

Open your browser to `http://localhost:9000`.


### API Tests

curl http://localhost:9000/api

curl http://localhost:9000/api/lang

Get lang info
curl http://localhost:9000/api/lang/haskell

Increase rating +1
curl -d {} http://localhost:9000/api/lang/haskell/like
