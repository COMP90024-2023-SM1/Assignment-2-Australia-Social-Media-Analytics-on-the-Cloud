import React from 'react'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'
import mapDataAU from '@highcharts/map-collection/countries/au/au-all.geo.json'
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
            name: 'Random data',
            mapData: mapDataAU,
            data: [
                ['au-nt', Math.floor(Math.random() * 100)],
                ['au-wa', Math.floor(Math.random() * 100)],
                ['au-sa', Math.floor(Math.random() * 100)],
                ['au-qld', Math.floor(Math.random() * 100)],
                ['au-nsw', Math.floor(Math.random() * 100)],
                ['au-vic', Math.floor(Math.random() * 100)],
                ['au-tas', Math.floor(Math.random() * 100)]
            ],
            joinBy: 'hc-key',
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

const AustraliaMap = () => {
    return (
        <div>
            <HighchartsReact highcharts={Highcharts} constructorType={'mapChart'} options={options} />
        </div>
    )
}

export default AustraliaMap
