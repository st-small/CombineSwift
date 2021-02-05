//
//  World.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import Foundation

struct World {
    var appState: AppState
    var citiesStore: CitiesStore
    var weatherAPI: OpenWeatherMapAPIClient
    var weatherManager: WeatherManager
    var localSearch: LocalSearchCompleter
    var geocoder: Geocoder
}

var Current = World(
    appState: AppState(),
    citiesStore: CitiesStore.load(),
    weatherAPI: OpenWeatherMapAPIClient(),
    weatherManager: WeatherManager(),
    localSearch: MapKitLocalSearchCompleter(),
    geocoder: CoreLocationGeocoder()
)

