import './MainComponent.css'
import { useCallback, useState, useEffect } from 'react'
import axios from 'axios'
const MainComponent = () => {
    // const [values, setValues] = useState([])
    // const [value, setValue] = useState('')

    // const saveNumber = useCallback(
    //     async event => {
    //         event.preventDefault()

    //         await axios.post('/api/values', {
    //             value
    //         })

    //         setValue('')
    //         getAllNumbers()
    //     },
    //     [value, getAllNumbers]
    // )

    return (
        <div>
            <span className="title">Values</span>
        </div>
    )
}

export default MainComponent
