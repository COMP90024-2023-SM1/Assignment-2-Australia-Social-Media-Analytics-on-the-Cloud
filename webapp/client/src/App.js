import { Fragment } from 'react'
import './App.css'
import { BrowserRouter as Router, Route, Link } from 'react-router-dom'
import { useCallback, useState, useEffect } from 'react'
import axios from 'axios'
function App() {
    const [values, setValues] = useState([])
    const getAllNumbers = useCallback(async () => {
        // we will use nginx to redirect it to the proper URL
        const data = await axios.get('/api/getDetails')
        console.log(data)
        setValues(data.data)
    }, [])
    useEffect(() => {
        getAllNumbers()
    }, [])

    return (
        <Router>
            <Fragment>
                <header className="header">
                    <div>This is a {values.value} application</div>
                </header>
                <div className="main"></div>
            </Fragment>
        </Router>
    )
}

export default App
