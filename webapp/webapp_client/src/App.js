import logo from './logo.svg'
import './App.css'
import { fetchGetDetails } from './utils/api'
import { useState } from 'react'
import React from 'react'

function App() {
    const [results, setResults] = useState('')
    const handleClick = async () => {
        let result = await fetchGetDetails()
        setResults(result.data)
    }
    return (
        <div className="App">
            <header className="App-header">{results.details}</header>
            <button onClick={handleClick}></button>
        </div>
    )
}
export default App
