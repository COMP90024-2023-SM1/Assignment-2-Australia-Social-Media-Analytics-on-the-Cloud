import React from 'react'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'
import mapDataAU from '@highcharts/map-collection/countries/au/au-all.geo.json'

// Load Highcharts modules
import HighchartsMap from 'highcharts/modules/map'

HighchartsMap(Highcharts)

const options = {
    chart: {
        type: 'map'
    },
    title: {
        text: 'Australia'
    },
    mapNavigation: {
        enabled: true,
        buttonOptions: {
            verticalAlign: 'bottom'
        }
    },
    series: [
        {
            name: 'States',
            mapData: mapDataAU,
            data: [
                ['Northern Territory', Math.floor(Math.random() * 100)],
                ['Western Australia', Math.floor(Math.random() * 100)],
                ['South Australia', Math.floor(Math.random() * 100)],
                ['Queensland', Math.floor(Math.random() * 100)],
                ['New South Wales', Math.floor(Math.random() * 100)],
                ['Victoria', Math.floor(Math.random() * 100)],
                ['Tasmania', Math.floor(Math.random() * 100)]
            ],
            joinBy: 'STATE_NAME',
            states: {
                hover: {
                    color: '#BADA55'
                }
            },
            dataLabels: {
                enabled: true,
                format: '{point.name}'
            }
        }
    ]
}

const Home = () => {
    return (
        <div>
            <HighchartsReact highcharts={Highcharts} constructorType={'mapChart'} options={options} />
        </div>
    )
}
export default Home
