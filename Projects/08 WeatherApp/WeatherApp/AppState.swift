//
//  AppState.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import Foundation
import Combine

class AppState {
    @Published var cityWeathers: [CityWeather] = []
    
    func load(citiesStore: CitiesStore, weatherManager: WeatherManager) {
        
        citiesStore.$cities
            .map { cities in
                cities.map { city in
                    CityWeather(city: city, weather: weatherManager.weatherPublisher(for: city))
                }
            }
            .assign(to: &$cityWeathers)
    }
}
