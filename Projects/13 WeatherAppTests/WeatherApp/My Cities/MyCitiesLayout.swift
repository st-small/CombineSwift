//
//  MyCitiesLayout.swift
//  WeatherApp
//
//  Created by Stanly Shiyanovskiy on 29.12.2020.
//

import UIKit

struct MyCitiesLayout {
    static func createLayout() -> UICollectionViewCompositionalLayout {
        let cityItem = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalWidth(0.5)))
        cityItem.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(130)), subitems: [cityItem])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
