import Map from './Map'
import './Scenario1.css'
const scenario1 = () => {
    return (
        <div class="container">
            <div class="left">
                <div class="small_top"></div>
                <div class="small_bottom"></div>
            </div>
            <div class="big">
                <Map></Map>
            </div>
            <div className="right">
                <div class="small_top"></div>
                <div class="small_bottom"></div>
            </div>
        </div>
    )
}

export default scenario1
