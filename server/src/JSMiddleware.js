// module JSMiddleware

exports.jsonBodyParser = require('body-parser').json()

exports.staticFiles = require('express').static('../client')
