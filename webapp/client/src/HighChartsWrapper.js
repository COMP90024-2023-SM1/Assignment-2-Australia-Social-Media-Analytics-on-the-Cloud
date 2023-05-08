import React, { useState, useEffect, useRef } from 'react'
import Highcharts, { chart } from 'highcharts'
import HighchartsReact from 'highcharts-react-official'

const HighchartsWrapper = ({ detail }) => {
    const chartRef = useRef(null)
    const [chartWidth, setChartWidth] = useState(null)
    const chartComponentRef = useRef(null)
    useEffect(() => {
        if (chartRef.current) {
            setChartWidth(chartRef.current.offsetWidth)
            window.addEventListener('resize', handleResize)
            return () => {
                window.removeEventListener('resize', handleResize)
            }
        }
    }, [chartRef])

    useEffect(() => {
        chartComponentRef.current.chart.update({ chart: { width: chartWidth } })
    }, [chartWidth])

    const handleResize = () => {
        setChartWidth(chartRef.current.offsetWidth)
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
                name: detail.seriesName,
                data: detail.data
            }
        ]
    }

    return (
        <div style={{ flex: 1 }} ref={chartRef}>
            <HighchartsReact highcharts={Highcharts} options={options} width={chartWidth} ref={chartComponentRef} />
        </div>
    )
}

export default HighchartsWrapper
