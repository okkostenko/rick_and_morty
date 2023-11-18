//
//  RMRequest.swift
//  RickAndMorty
//
//  Created by Olexandr Kostenko on 05.11.2023.
//

import Foundation

final class RMRequest {
    
    private struct Constants {
        static let baseUrl: String = "https://rickandmortyapi.com/api"
    }
    
    let endpoint: RMEnpoint
    let pathComponents: [String]
    let queryParameters: [URLQueryItem]
    
    private var urlString: String {
        var string = Constants.baseUrl
        string += "/"
        string += endpoint.rawValue
        
        if !pathComponents.isEmpty {
            pathComponents.forEach({
                string += "/\($0)"
            })
        }
        
        if !queryParameters.isEmpty {
            string += "?"
            let argumentString = queryParameters.compactMap({
                guard let value = $0.value else {return nil}
                return "\($0.name)=\(value)"
            }).joined(separator: "&")
            
            string += argumentString
        }
        
        return string
    }
    
    public var url: URL? {
        return URL(string: urlString)
    }
    
    public let httpMethod = "GET"
    
    public init(endpoint: RMEnpoint, pathComponents: [String] = [], queryParameters: [URLQueryItem] = []) {
        self.endpoint = endpoint
        self.pathComponents = pathComponents
        self.queryParameters = queryParameters
    }
    
    convenience init?(url: URL) {
        let string = url.absoluteString
        if !string.contains(Constants.baseUrl) {
            return nil
        }
        
        let trimmed = string.replacingOccurrences(of: Constants.baseUrl+"/", with: "")
        if trimmed.contains("/") {
            let components = trimmed.components(separatedBy: "/")
            if !components.isEmpty {
                let enpointString = components[0]
                
                var pathComponents: [String] = []
                if components.count > 1 {
                    pathComponents = components
                    pathComponents.removeFirst()
                }
                if let rmEnpoint = RMEnpoint(rawValue: enpointString) {
                    self.init(endpoint: rmEnpoint, pathComponents: pathComponents)
                    return
                }
            }
        }
        
        if trimmed.contains("?") {
            let components = trimmed.components(separatedBy: "?")
            
            if !components.isEmpty, components.count >= 2 {
                let enpointString = components[0]
                let queryItemsString = components[1]
                let queryItems: [URLQueryItem] = queryItemsString.components(separatedBy: "&").compactMap({
                    guard $0.contains("=") else {
                        return nil
                    }
                    let parts = $0.components(separatedBy: "=")
                    
                    return URLQueryItem(
                        name: parts[0],
                        value: parts[1]
                    )
                })
                
                if let rmEnpoint = RMEnpoint(rawValue: enpointString) {
                    self.init(endpoint: rmEnpoint, queryParameters: queryItems)
                    return
                }
            }
        }
        
        return nil
    }
}

extension RMRequest {
    static let listCharactersRequests = RMRequest(endpoint: .character)
}
