const express = require('express')
const app = express()
const cors = require('cors')
const cookieParser = require('cookie-parser')
const path = require('path')
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(express.static(path.resolve(__dirname, '../webapp_client/build')))
const NodeCouchDB = require('node-couchdb')

// const couch = new NodeCouchDB({
//     host: 'localhost',
//     protocol: 'http',
//     port: 5984,
//     auth: {
//         user: 'admin',
//         password: 'password'
//     }
// })
// console.log(couch)
let allowedOrigins = 'http://localhost:3000'

app.use(
    cors({
        credentials: true, // add Access-Control-Allow-Credentials to header
        origin: function (origin, callback) {
            // allow requests with no origin
            // (like mobile apps or curl requests)
            if (!origin) return callback(null, true)
            if (allowedOrigins.indexOf(origin) === -1) {
                let msg = 'The CORS policy for this site does not ' + 'allow access from the specified Origin.'
                return callback(new Error(msg), false)
            }
            return callback(null, true)
        }
    })
)
app.get('/getDetails/', (req, res) => {
    res.status(200).json({ data: { result: 'hello' } })
})

// app.get('*', (req, res) => {
//     res.sendFile(path.resolve(__dirname, '../webapp_client/build', 'index.html'))
// })

app.get('/:universalURL', (req, res) => {
    res.send('404 URL NOT FOUND')
})
const port = 8000
app.listen(port, () => {
    console.log('Listening on port ' + port + '...')
})

module.exports = app
