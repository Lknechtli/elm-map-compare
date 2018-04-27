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

//ports
app.ports.mapEvent.subscribe((event) => {
    switch (event.name) {
    case 'mapInit':
        beforeMap = new MapboxGL.Map({
            container: 'before',
            style: {
                version: 8,
                sources: {
                    dark: {
                        type: 'raster',
                        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png']
                    },
                    light: {
                        type: 'raster',
                        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png']
                    }
                },
                layers: [{
                    id: 'basemap',
                    type: 'raster',
                    source: 'light',
                    tileSize: 256
                }]
            },
            center: [0, 0],
            zoom: 0
        });
        afterMap = new MapboxGL.Map({
            container: 'after',
            style: {
                version: 8,
                sources: {
                    dark: {
                        type: 'raster',
                        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png']
                    },
                    light: {
                        type: 'raster',
                        tiles: ['https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png']
                    }
                },
                layers: [{
                    id: 'basemap',
                    type: 'raster',
                    source: 'light',
                    tileSize: 256
                }]
            },
            center: [0, 0],
            zoom: 0
        });

        map = new MapCompare(beforeMap, afterMap, {});
        break;
    case 'UpdateLeftUrl':
        console.log('Left url updated to', event.data);
        break;
    case 'UpdateRightUrl':
        console.log('Right url updated to', event.data);
        break;
    default:
        console.log('Unhandled event from elm:', event);
    }
});
