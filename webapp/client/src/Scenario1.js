import Map from './Map'
import './css/Scenario1.css'
import { useCallback, useState, useEffect } from 'react'
import axios from 'axios'
import HighChartsWrapper from './HighChartsWrapper'

const Scenario1 = () => {
    const [chart1, setChart1] = useState(null)
    const getOption1Data = async () => {
        const value = await axios.get('http://localhost:5000/api/AustraliaRandom')
        setChart1({
            data: value.data.data,
            title: 'Australia Random',
            chartType: 'pie'
        })
    }

    useEffect(() => {
        getOption1Data()
    }, [])

    return (
        <div className="container">
            <div className="left">
                <div className="small_top">{chart1 && <HighChartsWrapper detail={chart1} />}</div>

                <div className="small_bottom">
                    <div className="small_top">{chart1 && <HighChartsWrapper detail={chart1} />}</div>
                </div>
            </div>
            <div className="big">
                <Map></Map>
            </div>
            <div className="right">
                <div className="small_top"></div>
                <div className="small_bottom"></div>
            </div>
        </div>
    )
}

export default Scenario1
