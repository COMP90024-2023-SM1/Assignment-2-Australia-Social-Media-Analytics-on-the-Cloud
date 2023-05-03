const keys = require('./keys')

const nano = require('nano')('http://admin:admin@172.26.131.15:5984')
// Express Application setup
const express = require('express')
const bodyParser = require('body-parser')
const cors = require('cors')

const app = express()
app.use(cors())
app.use(bodyParser.json())

// const NodeCouchDB = require('node-couchdb')
// const couch = new NodeCouchDB({
//     host: '172.26.131.15',
//     protocol: 'http',
//     port: 5984,
//     auth: {
//         user: 'admin',
//         password: 'admin'
//     }
// })
// console.log(couch)
const dbName = 'mydatabase'
const db = nano.use(dbName)

// couch.createDatabase(dbName).then(
//     () => {
//         console.log('create success')
//     },
//     err => {
//         console.log(err)
//     }
// )
// couch.listDatabases().then(
//     dbs => console.log(dbs),
//     err => {
//         console.log(err)
//     }
// )
// couch.dropDatabase(dbName).then(
//     () => {
//         console.log('drop success')
//     },
//     err => {
//         console.log(err)
//     }
// )
//Express route definitions
app.get('/getDetails', (req, res) => {
    res.send({ value: 'Hi' })
})

// get the values
// app.get("/values/all", async (req, res) => {
//   const values = await pgClient.query("SELECT * FROM values");

//   res.send(values);
// });

// // now the post -> insert value
// app.post("/values", async (req, res) => {
//   if (!req.body.value) res.send({ working: false });

//   pgClient.query("INSERT INTO values(number) VALUES($1)", [req.body.value]);

//   res.send({ working: true });
// });

app.listen(5000, err => {
    console.log('Listening')
})
