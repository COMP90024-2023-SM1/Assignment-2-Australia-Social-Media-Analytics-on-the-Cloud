const express = require('express')
const app = express()
const cors = require('cors')
const cookieParser = require('cookie-parser')
app.use(express.json())
app.use(express.urlencoded({ extended: false }))
app.use(cookieParser())
app.use(cors)

app.get('/messages', (req, res) => {
    res.send('Hello')
})

app.get('/:universalURL', (req, res) => {
    res.send('404 URL NOT FOUND')
})
const port = 8080
app.listen(8080, () => {
    console.log('Listening on port ' + port + '...')
})

module.exports = app
