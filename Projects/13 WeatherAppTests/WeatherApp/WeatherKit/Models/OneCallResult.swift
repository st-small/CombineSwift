//
//  OneCallResult.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import Foundation

public struct OneCallResult: Codable {
    public let current: WeatherMetrics<SingleTemperature>
    public let hourly: [WeatherMetrics<SingleTemperature>]
    public let daily: [WeatherMetrics<DailyTemperatures>]
}
