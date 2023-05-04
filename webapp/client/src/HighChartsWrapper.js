import React, { useState, useEffect, useRef } from 'react'
import Highcharts from 'highcharts'
import HighchartsReact from 'highcharts-react-official'

const HighchartsWrapper = ({ detail }) => {
    const chartRef = useRef(null)
    const [chartWidth, setChartWidth] = useState(null)

    useEffect(() => {
        if (chartRef.current) {
            setChartWidth(chartRef.current.offsetWidth)
            window.addEventListener('resize', handleResize)
            return () => {
                window.removeEventListener('resize', handleResize)
            }
        }
    }, [chartRef])

    const handleResize = () => {
        setChartWidth(chartRef.current.offsetWidth)
        chartRef.current.chart.updateSize()
    }

    const options = {
        chart: {
            type: detail.chartType
        },
        title: {
            text: detail.title
        },
        series: [
            {
                data: detail.data
            }
        ]
    }

    return (
        <div style={{ flex: 1 }} ref={chartRef}>
            <HighchartsReact highcharts={Highcharts} options={options} width={chartWidth} />
        </div>
    )
}

export default HighchartsWrapper
