import logo from './logo.svg'
import './App.css'
import { fetchGetDetails } from './utils/api'
import { useState } from 'react'
import React from 'react'

function App() {
    const [details, setDetails] = useState('')
    const handleClick = async () => {
        let result = await fetchGetDetails()
        setDetails(result)
    }
    return (
        <div className="App">
            <header className="App-header">{details}</header>
            <button onClick={handleClick}></button>
        </div>
    )
}
export default App
