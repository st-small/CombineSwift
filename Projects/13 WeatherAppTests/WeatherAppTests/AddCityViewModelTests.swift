//
//  AddCityViewModelTests.swift
//  WeatherAppTests
//
//  Created by Stanly Shiyanovskiy on 05.01.2021.
//

import Combine
import CoreLocation
import Foundation
import MapKit
import XCTest
@testable import WeatherApp

class AddCityViewModelTests: CombineTestCase {
    
    var viewModel: AddCityViewModel!
    var localSearch: TestLocalSearch!
    var geocoder: TestGeocoder!
    
    override func setUp() {
        super.setUp()
        
        localSearch = TestLocalSearch()
        geocoder = TestGeocoder()
        TestEnvironments.push()
        Current.localSearch = localSearch
        Current.geocoder = geocoder
        
        viewModel = AddCityViewModel()
    }
    
    override func tearDown() {
        super.tearDown()
        
        TestEnvironments.pop()
    }
    
    func testSetSearchTerm() {
        viewModel.searchTerm = "Houston"
        viewModel.searchTerm = "Dallas"
        XCTAssertEqual(localSearch.queries, ["Houston", "Dallas"])
    }
    
    func testFiltersOutResultsThatDontLookLikeCities() {
        let houstonResult = LocalSearchCompletion(title: "Houston, TX", subtitle: "")
        let houstonRestaurantResult = LocalSearchCompletion(title: "Houston's Restaurant", subtitle: "")
        localSearch.subject.send([houstonResult, houstonRestaurantResult])
        XCTAssertEqual(viewModel.results, [houstonResult])
    }
    
    func testGeocodesResultIntoCity() {
        viewModel.results = [LocalSearchCompletion(title: "Houston, TX", subtitle: "")]
        let pub = viewModel.geolocate(selectedIndex: 0)
            .assertNoFailure()
        let expectedCity = City(name: "Houston", locality: "TX", latitude: 29, longitude: -95)
        let houstonPlacemark = TestPlacemark(coordinate: CLLocationCoordinate2D(latitude: 29, longitude: -95), name: "Houston", locality: "TX")
        
        assertPublisher(pub, produces: expectedCity) {
            geocoder.subject.send([houstonPlacemark])
            geocoder.subject.send(completion: .finished)
        }
    }
    
    func testGeocodingFails() {
        viewModel.results = [LocalSearchCompletion(title: "Houston, TX", subtitle: "")]
        let pub = viewModel.geolocate(selectedIndex: 0)
        
        struct SomeError: Error { }
        assertPublisher(pub, failsWithError: AddCityViewModel.Errors.geolocationFailed) {
            geocoder.subject.send(completion: .failure(SomeError()))
        }
    }
    
    func testGeocodingProducesNoResults() {
        viewModel.results = [LocalSearchCompletion(title: "Houston, TX", subtitle: "")]
        let pub = viewModel.geolocate(selectedIndex: 0)
            .assertNoFailure()
        
        assertPublisher(pub.count(), producesExactly: 0) {
            geocoder.subject.send([])
            geocoder.subject.send(completion: .finished)
        }
    }
    
    func testGeocodingManagesSpinnerState() {
        XCTAssertFalse(viewModel.showSpinner)
        viewModel.results = [LocalSearchCompletion(title: "Houston, TX", subtitle: "")]
        viewModel.geolocate(selectedIndex: 0)
            .assertNoFailure()
            .sink { _ in }
            .store(in: &cancellables)
        XCTAssertTrue(viewModel.showSpinner)
        geocoder.subject.send(completion: .finished)
        XCTAssertFalse(viewModel.showSpinner)
    }
}

class TestPlacemark: CLPlacemark {
    
    private let _name: String
    private let _locality: String
    
    init(coordinate: CLLocationCoordinate2D, name: String, locality: String) {
        let mkPlacemark = MKPlacemark(coordinate: coordinate)
        _name = name
        _locality = locality
        super.init(placemark: mkPlacemark as CLPlacemark)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var name: String? { _name }
    override var administrativeArea: String? { _locality }
}
