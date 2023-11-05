//
//  Extensions.swift
//  RickAndMorty
//
//  Created by Olexandr Kostenko on 05.11.2023.
//

import UIKit

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach({
            addSubview($0)
        })
    }
}
