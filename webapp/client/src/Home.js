import React from 'react'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'
import 'highcharts/modules/map'

const options = {
    chart: {
        type: 'pie'
    },
    title: {
        text: 'Australia'
    },
    series: [
        {
            name: 'Random data',
            data: [
                ['au-nt', Math.floor(Math.random() * 100)],
                ['au-wa', Math.floor(Math.random() * 100)],
                ['au-sa', Math.floor(Math.random() * 100)],
                ['au-ql', Math.floor(Math.random() * 100)],
                ['au-nsw', Math.floor(Math.random() * 100)],
                ['au-vi', Math.floor(Math.random() * 100)],
                ['au-ta', Math.floor(Math.random() * 100)]
            ]
        }
    ]
}

const AustraliaMap = () => {
    return (
        <div>
            <HighchartsReact highcharts={Highcharts} options={options} />
        </div>
    )
}

export default AustraliaMap
