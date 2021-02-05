//
//  CityWeather.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import Foundation
import Combine

struct CityWeather {
    let city: City
    let weather: AnyPublisher<OneCallResult?, Never>
}
