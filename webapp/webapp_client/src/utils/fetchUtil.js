import { message } from 'antd'

const checkStatus = res => {
    console.log(res)
    if (200 >= res.status < 300) {
        return res
    }
    message.error(`Network error,${res.status}`)
    const error = new Error(res.message)
    error.response = error
    throw error
}

/**
 * 捕获失败
 * @param error
 */
const handleError = error => {
    if (error instanceof TypeError) {
        message.error(`Network queries fail!${error}`)
    }
    return {
        //防止页面崩溃，因为每个接口都有判断res.code以及data
        code: -1,
        data: false
    }
}

class http {
    /**
     *静态的fetch请求通用方法
     * @param url
     * @param options
     * @returns {Promise<unknown>}
     */
    static async staticFetch(url = '', options = {}) {
        const defaultOptions = {
            /*允许携带cookies*/
            credentials: 'include',
            /*允许跨域**/
            mode: 'cors',
            headers: {}
        }
        if (options.method === 'POST' || 'PUT') {
            defaultOptions.headers['Content-Type'] = 'application/json; charset=utf-8'
        }
        const newOptions = { ...defaultOptions, ...options }
        console.log('newOptions', newOptions)
        return fetch(url, newOptions)
            .then(checkStatus)
            .then(res => res.json())
            .catch(handleError)
    }

    /**
     *post请求方式
     * @param url
     * @returns {Promise<unknown>}
     */
    post(url, params = {}, option = {}) {
        const options = Object.assign({ method: 'POST' }, option)
        //一般我们常用场景用的是json，所以需要在headers加Content-Type类型
        options.body = JSON.stringify(params)

        //可以是上传键值对形式，也可以是文件，使用append创造键值对数据
        if (options.type === 'FormData' && options.body !== 'undefined') {
            let params = new FormData()
            for (let key of Object.keys(options.body)) {
                params.append(key, options.body[key])
            }
            options.body = params
        }
        return http.staticFetch(url, options) //类的静态方法只能通过类本身调用
    }

    /**
     * put方法
     * @param url
     * @returns {Promise<unknown>}
     */
    put(url, params = {}, option = {}) {
        const options = Object.assign({ method: 'PUT' }, option)
        options.body = JSON.stringify(params)
        return http.staticFetch(url, options) //类的静态方法只能通过类本身调用
    }

    /**
     * get请求方式
     * @param url
     * @param option
     */
    get(url, option = {}) {
        const options = Object.assign({ method: 'GET' }, option)
        return http.staticFetch(url, options)
    }
}

const requestFun = new http() //new生成实例
export const { post, get, put } = requestFun
export default requestFun
