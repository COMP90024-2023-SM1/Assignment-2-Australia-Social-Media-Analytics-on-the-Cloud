import React from 'react'
import { BrowserRouter as Router, Route, Link } from 'react-router-dom'
import { useCallback, useState, useEffect } from 'react'
import axios from 'axios'
import Home from './Home'
import Scenario1 from './Scenario1'
import OtherPage from './OtherPage'
import { Layout, Menu, theme } from 'antd'
import './css/App.css'
const { Header, Content, Footer } = Layout

const App = () => {
    const [selectedMenuItem, setSelectedMenuItem] = useState('Home')
    const componentsSwtich = key => {
        switch (key) {
            case 'Home':
                return <Home></Home>
            case 'Scenario1':
                return <Scenario1></Scenario1>
            case 'Scenario2':
                return <OtherPage></OtherPage>
            case 'Scenario3':
                return <h3>item3</h3>
            default:
                break
        }
    }
    const {
        token: { colorBgContainer }
    } = theme.useToken()
    const itemArray = [
        { key: 'Home', label: 'Home' },
        ...new Array(3).fill(null).map((_, index) => {
            const key = index + 1
            return {
                key: `Scenario${key}`,
                label: `Scenario ${key}`
            }
        })
    ]
    return (
        <Layout className="layout">
            <Header>
                <Menu
                    theme="dark"
                    mode="horizontal"
                    defaultSelectedKeys={['Home']}
                    selectedKeys={selectedMenuItem}
                    onClick={e => setSelectedMenuItem(e.key)}
                    items={itemArray}
                />
            </Header>
            <Content
                style={{
                    padding: '20px 20px'
                }}
            >
                {componentsSwtich(selectedMenuItem)}
            </Content>
        </Layout>
    )
}
export default App
