import React from 'react'
import { useState } from 'react'
import Home from './Home'
import Depression from './Depression'
import Religion from './Religion'
import War from './War'
import { Layout, Menu } from 'antd'
import './css/App.css'
const { Header, Content } = Layout

const App = () => {
    const [selectedMenuItem, setSelectedMenuItem] = useState('Religion')
    const componentsSwtich = key => {
        switch (key) {
            case 'Religion':
                return <Religion></Religion>
            case 'Depression':
                return <Depression></Depression>
            case 'War':
                return <Home></Home>
            default:
                break
        }
    }

    const itemArray = [
        { key: 'Religion', label: 'Religion' },
        { key: 'Depression', label: 'Depression' },
        { key: 'War', label: 'War' }
    ]
    return (
        <Layout className="layout">
            <Header>
                <Menu
                    theme="dark"
                    mode="horizontal"
                    defaultSelectedKeys={['Religion']}
                    selectedKeys={selectedMenuItem}
                    onClick={e => setSelectedMenuItem(e.key)}
                    items={itemArray}
                />
            </Header>
            <Content
                style={{
                    padding: '20px 20px',
                    backgroundColor: '#344d69'
                }}
            >
                {componentsSwtich(selectedMenuItem)}
            </Content>
        </Layout>
    )
}
export default App
