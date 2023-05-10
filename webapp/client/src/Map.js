import React, { useEffect, useRef, useState } from 'react'
import mapboxgl from '!mapbox-gl' // eslint-disable-line import/no-webpack-loader-syntax
import './Map.css'
mapboxgl.accessToken = 'pk.eyJ1Ijoieml5dXEiLCJhIjoiY2xoNXBhaWdtMWx5aTNqbzF6Ymhyem90aCJ9.8g88_rjfEdoh67nfi8VWiA'

const Map = () => {
    const mapContainer = useRef(null)
    const map = useRef(null)
    const [lng, setLng] = useState(134.218182)
    const [lat, setLat] = useState(-25.953635)
    const [zoom, setZoom] = useState(3)
    useEffect(() => {
        if (map.current) return // initialize map only once
        map.current = new mapboxgl.Map({
            container: mapContainer.current,
            style: 'mapbox://styles/mapbox/streets-v12',
            center: [lng, lat],
            zoom: zoom,
            attributionControl: false
        })
    })

    useEffect(() => {
        if (!map.current) return // wait for map to initialize
        map.current.on('move', () => {
            setLng(map.current.getCenter().lng.toFixed(4))
            setLat(map.current.getCenter().lat.toFixed(4))
            setZoom(map.current.getZoom().toFixed(2))
        })
    })
    return <div className="map-container" ref={mapContainer}></div>
}

export default Map
