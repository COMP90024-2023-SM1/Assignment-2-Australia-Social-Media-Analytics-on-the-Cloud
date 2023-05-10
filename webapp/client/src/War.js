import Map from './Map'
import './css/Scenario.css'
import { useState, useEffect } from 'react'
import axios from 'axios'
import HighChartsWrapper from './HighChartsWrapper'
import config from './config.json'
const War = () => {
    const [chart1, setChart1] = useState(null)
    const [chart2, setChart2] = useState(null)
    const getAystraliaRandomData = async () => {
        console.log(config.server_url + '/api/AustraliaRandom')
        const value = await axios.get(config.server_url + '/api/AustraliaRandom')
        setChart1({
            data: value.data.data,
            title: 'Australia Random',
            chartType: 'pie',
            seriesName: 'Australian Random'
        })
    }
    const getTwitterByMonth = async () => {
        const value = await axios.get(config.server_url + '/api/twitter/by-month')
        console.log(value.data.data)
        setChart2({
            data: value.data.data,
            title: 'Australia Twitter by month',
            chartType: 'line',
            seriesName: '2022 Twitter Data'
        })
    }

    useEffect(() => {
        getAystraliaRandomData()
        getTwitterByMonth()
    }, [])

    return (
        <div className="container">
            <div className="topic">
                <p>This Scenario is about the analysis and comparison of religions in different states and cities in Australia.</p>
            </div>
            <div className="body">
                <div className="left">
                    <div className="small_top">{chart1 && <HighChartsWrapper detail={chart1} />}</div>

                    <div className="small_bottom">{chart2 && <HighChartsWrapper detail={chart2} />}</div>
                </div>
                <div className="big">
                    <Map></Map>
                </div>
                <div className="right">
                    <div className="small_top"></div>
                    <div className="small_bottom"></div>
                </div>
            </div>
        </div>
    )
}

export default War
