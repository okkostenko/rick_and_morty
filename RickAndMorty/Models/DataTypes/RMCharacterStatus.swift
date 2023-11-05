//
//  RMCharacterStatus.swift
//  RickAndMorty
//
//  Created by Olexandr Kostenko on 05.11.2023.
//

import Foundation
import UIKit

enum RMCharacterStatus: String, Codable {
    case alive = "Alive"
    case dead = "Dead"
    case `unknown` = "unknown"
    
    var text: String {
        switch self {
        case .alive: return rawValue
        case .dead: return rawValue
        case .unknown: return "Unknown"
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .alive: return UIColor(.green)
        case .dead: return UIColor(.red)
        case .unknown: return UIColor(.orange)
        }
    }
}
