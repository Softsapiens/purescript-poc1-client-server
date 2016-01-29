# Client component

The client application for the Programming Languages Database project.

To build the client:
```
cd client
pulp dep install
mkdir js
pulp browserify --to js/Main.js
```

This client runs via the server, so you only have to start de server component and access http://localhost:9000
