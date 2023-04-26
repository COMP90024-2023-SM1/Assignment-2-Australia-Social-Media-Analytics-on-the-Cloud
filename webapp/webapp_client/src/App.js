import React, { useState } from 'react'
import './index.css'
import { MenuFoldOutlined, MenuUnfoldOutlined, UploadOutlined, UserOutlined, VideoCameraOutlined } from '@ant-design/icons'
import { Layout, Menu, Button, theme } from 'antd'

import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import Home from './pages/Home'
import Topic1 from './pages/Topic1'

const { Header, Sider, Content } = Layout
const App = () => {
    const [collapsed, setCollapsed] = useState(false)
    const {
        token: { colorBgContainer }
    } = theme.useToken()

    return (
        <Router>
            <Layout>
                <Sider trigger={null} collapsible collapsed={collapsed}>
                    <div className="logo" />
                    <Menu theme="dark" mode="inline" defaultSelectedKeys={['1']}>
                        <Menu.Item>
                            <span>Home</span>
                            <Link to="/"></Link>
                        </Menu.Item>
                        <Menu.Item>
                            {/* <Icon type='pie-chart'></Icon> */}
                            <span>Topic 1</span>
                            <Link to="/topic1"></Link>
                        </Menu.Item>
                    </Menu>
                </Sider>
                <Layout>
                    <Header style={{ padding: 0, background: colorBgContainer }}>
                        <Button
                            type="text"
                            icon={collapsed ? <MenuUnfoldOutlined /> : <MenuFoldOutlined />}
                            onClick={() => setCollapsed(!collapsed)}
                            style={{
                                fontSize: '16px',
                                width: 64,
                                height: 64
                            }}
                        />
                    </Header>
                    <Content
                        style={{
                            margin: '24px 16px',
                            padding: 24,
                            height: '100vh',
                            background: colorBgContainer
                        }}
                    >
                        <Routes>
                            <Route exact path="/" Component={Home}></Route>
                            <Route exact path="/topic1" Component={Topic1}></Route>
                        </Routes>
                    </Content>
                </Layout>
            </Layout>
        </Router>
    )
}

export default App

// const ComponentDemo = App

// createRoot(mountNode).render(<ComponentDemo />)
// function App() {
//     return (
//         <Router>
//             <div>
//                 <Navigation />
//                 <Routes>
//                     <Route path="/" Component={Home} />
//                 </Routes>
//             </div>
//         </Router>
//     )
// }

//     const [results, setResults] = useState('')
//     const handleClick = async () => {
//         let result = await fetchGetDetails()
//         setResults(result.data)
//     }
//     return (
//         <div className="App">
//             <header className="App-header">{results.details}</header>
//             <button onClick={handleClick}></button>
//         </div>
//     )
// }
