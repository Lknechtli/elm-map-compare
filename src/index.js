import './main.css';
import MapboxGL from 'mapbox-gl';
import MapCompare from 'mapbox-gl-compare';
require('../node_modules/mapbox-gl/dist/mapbox-gl.css');
require('../node_modules/mapbox-gl-compare/dist/mapbox-gl-compare.css');
import { Main } from './Main.elm';
import registerServiceWorker from './registerServiceWorker';

const app = Main.fullscreen();

registerServiceWorker();

MapboxGL.accessToken = 'undefined';
var beforeMap;
var afterMap;
var map;

const basemapSources = {
    dark: {
        type: 'raster',
        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png']
    },
    light: {
        type: 'raster',
        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png']
    }
};
const basemapLayers = [{
    id: 'basemap',
    type: 'raster',
    source: 'light',
    tileSize: 256
}];

var leftLayerSource;
var leftLayer;
var rightLayerSource;
var rightLayer;

//ports
app.ports.mapEvent.subscribe((event) => {
    switch (event.name) {
    case 'mapInit':
        beforeMap = new MapboxGL.Map({
            container: 'before',
            style: {
                version: 8,
                sources: Object.assign({}, basemapSources),
                layers: basemapLayers.slice()
            },
            center: [0, 0],
            zoom: 0
        });
        afterMap = new MapboxGL.Map({
            container: 'after',
            style: {
                version: 8,
                sources: Object.assign({}, basemapSources),
                layers: basemapLayers.slice()
            },
            center: [0, 0],
            zoom: 0
        });

        map = new MapCompare(beforeMap, afterMap, {});
        break;
    case 'UpdateLeftUrl':
        console.log('Left url updated to', event.data);
        if (beforeMap.getSource('compare')) {
            beforeMap.removeLayer('compare');
            beforeMap.removeSource('compare');
        }
        beforeMap.addSource('compare', {
            type: 'raster',
            tiles: [event.data]
        });
        beforeMap.addLayer({
            id: 'compare',
            type: 'raster',
            source: 'compare',
            tileSize: 256
        });
        break;
    case 'UpdateRightUrl':
        console.log('Right url updated to', event.data);
        if (afterMap.getSource('compare')) {
            afterMap.removeLayer('compare');
            afterMap.removeSource('compare');
        }
        afterMap.addSource('compare', {
            type: 'raster',
            tiles: [event.data]
        });
        afterMap.addLayer({
            id: 'compare',
            type: 'raster',
            source: 'compare',
            tileSize: 256
        });
        break;
    default:
        console.log('Unhandled event from elm:', event);
    }
});
