//
//  WeatherConditionImage.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import UIKit

struct WeatherConditionImage {
    static func image(for condition: WeatherCondition) -> UIImage {
        switch condition.id.category {
        case .atmosphere: return UIImage(systemName: "wind")!
        case .clear: return UIImage(systemName: "sun.max.fill")!
        case .clouds: return UIImage(systemName: "cloud.fill")!
        case .drizzle: return UIImage(systemName: "cloud.drizzle.fill")!
        case .rain: return UIImage(systemName: "cloud.rain.fill")!
        case .snow: return UIImage(systemName: "cloud.snow.fill")!
        case .thunderstorm: return UIImage(systemName: "cloud.bolt.rain.fill")!
        case .unknown: return UIImage(systemName: "cloud")!
        }
    }
}
