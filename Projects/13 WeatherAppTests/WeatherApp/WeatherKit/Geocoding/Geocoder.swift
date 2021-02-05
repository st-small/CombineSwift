//
//  Geocoder.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import CoreLocation
import Foundation

public protocol Geocoder {
    func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error>
}
