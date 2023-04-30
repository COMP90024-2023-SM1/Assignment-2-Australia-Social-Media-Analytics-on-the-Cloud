import requestFun from './fetchUtil' //引入
import qs from 'qs'
import config from '../config.json'
const { stringify } = qs
const { post, get } = requestFun
//get方式
export async function fetchData1(params) {
    return get(`/api/bbb?${stringify(params)}`)
}

//post方式
export async function fetchData2(params) {
    return post(`/api/aaa`, params)
}

export async function fetchGetDetails(params) {
    return get(`/api/getDetails/`)
}
