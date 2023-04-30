import './MainComponent.css'

const MainComponent = () => {
    const [values, setValues] = useState([])
    const [value, setValue] = useState('')

    const saveNumber = useCallback(
        async event => {
            event.preventDefault()

            await axios.post('/api/values', {
                value
            })

            setValue('')
            getAllNumbers()
        },
        [value, getAllNumbers]
    )

    return (
        <div>
            <button onClick={getAllNumbers}>Get all numbers</button>
            <br />
            <span className="title">Values</span>
            <div className="values">
                {values.map(value => (
                    <div className="value">{value}</div>
                ))}
            </div>
            <form className="form" onSubmit={saveNumber}>
                <label>Enter your value: </label>
                <input
                    value={value}
                    onChange={event => {
                        setValue(event.target.value)
                    }}
                />
                <button>Submit</button>
            </form>
        </div>
    )
}

export default MainComponent
