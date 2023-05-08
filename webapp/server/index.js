const keys = require('./keys')

const nano = require('nano')('http://admin:admin@172.26.128.113:5984')
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
const dbName = 'twitter_data'
const twitter = nano.use(dbName)

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

// If run in local, place keys.prod to "/api"
app.get(keys.prod + '/AustraliaRandom', (req, res) => {
    const result = [
        ['au-nt', Math.floor(Math.random() * 100)],
        ['au-wa', Math.floor(Math.random() * 100)],
        ['au-sa', Math.floor(Math.random() * 100)],
        ['au-ql', Math.floor(Math.random() * 100)],
        ['au-nsw', Math.floor(Math.random() * 100)],
        ['au-vi', Math.floor(Math.random() * 100)],
        ['au-ta', Math.floor(Math.random() * 100)]
    ]
    res.send({ data: result })
})

app.get(keys.prod + '/twitter/by-month', async (req, res) => {
    const body = await twitter.view('newDesignDoc', 'count-by-month', { reduce: true, group: true })
    const seriesData = body.rows.map(row => {
        return {
            name: row.key,
            x: row.key[1],
            y: row.value
        }
    })
    res.send({ data: seriesData })
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
