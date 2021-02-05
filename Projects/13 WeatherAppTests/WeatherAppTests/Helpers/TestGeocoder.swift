//
//  TestGeocoder.swift
//  WeatherAppTests
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import CoreLocation
import Foundation
@testable import WeatherApp

class TestGeocoder: Geocoder {
    
    var subject = PassthroughSubject<[CLPlacemark], Error>()
    
    func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error> {
        subject.eraseToAnyPublisher()
    }
}
