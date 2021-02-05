//
//  MapKitLocalSearchCompleter.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import Foundation
import MapKit

public class MapKitLocalSearchCompleter: NSObject, LocalSearchCompleter {
    
    private let completer = MKLocalSearchCompleter()
    private var resultsSubject = PassthroughSubject<[MKLocalSearchCompletion], Never>()
    
    public let results: AnyPublisher<[LocalSearchCompletion], Never>
    
    public override init() {
        results = resultsSubject.map { results in
            results.map { r in
                LocalSearchCompletion(title: r.title, subtitle: r.subtitle)
            }
        }
        .eraseToAnyPublisher()
        
        super.init()
        
        completer.delegate = self
    }
    
    public func search(with query: String) {
        completer.queryFragment = query
    }
}

extension MapKitLocalSearchCompleter: MKLocalSearchCompleterDelegate {
    
    public func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        resultsSubject.send(completer.results)
    }
    
    public func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("ERROR: \(error)")
    }
}
