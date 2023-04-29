import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import { fetchGetDetails } from '../utils/api'

function Topic1() {
    const [results, setResults] = useState('')

    useEffect(() => {
        async function fetchData() {
            let result = await fetchGetDetails()
            console.log(result)
            setResults(result.data)
        }
        fetchData()
    }, [])

    return (
        <div>
            <h2>{results.result}</h2>
            <div></div>
        </div>
    )
}

export default Topic1
