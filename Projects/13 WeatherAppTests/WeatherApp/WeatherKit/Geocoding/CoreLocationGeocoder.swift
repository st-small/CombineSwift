//
//  CoreLocationGeocoder.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import CoreLocation
import Foundation

public class CoreLocationGeocoder: Geocoder {
    
    private let geocoder = CLGeocoder()
    
    public init() {
        
    }
    
    public func geocodeAddress(address: String) -> AnyPublisher<[CLPlacemark], Error> {
        geocoder.cancelGeocode()
        return Future { [self] promise in
            self.geocoder.geocodeAddressString(address) { (placemarks, error) in
                if let placemarks = placemarks {
                    promise(.success(placemarks))
                } else {
                    promise(.failure(error!))
                }
                
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
    }
}
