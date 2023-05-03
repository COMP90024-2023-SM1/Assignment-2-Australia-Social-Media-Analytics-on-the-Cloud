import React from 'react'
import { BrowserRouter as Router, Route, Link } from 'react-router-dom'
import { useCallback, useState, useEffect } from 'react'
import axios from 'axios'
import Map from './Map'
import Scenario1 from './Scenario1'
import OtherPage from './OtherPage'
import { Breadcrumb, Layout, Menu, theme } from 'antd'
import './App.css'
const { Header, Content, Footer } = Layout

const App = () => {
    const [selectedMenuItem, setSelectedMenuItem] = useState('scenario1')
    const componentsSwtich = key => {
        console.log(key)
        switch (key) {
            case 'scenario1':
                return <Scenario1></Scenario1>
            case 'scenario2':
                return <OtherPage></OtherPage>
            case 'scenario3':
                return <h3>item3</h3>
            default:
                break
        }
    }
    const {
        token: { colorBgContainer }
    } = theme.useToken()

    return (
        <Layout className="layout">
            <Header>
                <Menu
                    theme="dark"
                    mode="horizontal"
                    defaultSelectedKeys={['scenario1']}
                    selectedKeys={selectedMenuItem}
                    onClick={e => setSelectedMenuItem(e.key)}
                    items={new Array(3).fill(null).map((_, index) => {
                        const key = index + 1
                        return {
                            key: `scenario${key}`,
                            label: `scenario ${key}`
                        }
                    })}
                />
            </Header>
            <Content
                style={{
                    padding: '20px 50px'
                }}
            >
                {componentsSwtich(selectedMenuItem)}
            </Content>
        </Layout>
    )
}
export default App
