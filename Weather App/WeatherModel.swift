//
//  WeatherModel.swift
//  Weather App
//
//  Created by Raunak Sinha on 20/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import Foundation

class WeatherModel: NSObject, Codable {
    
    var name: String = ""
    var temp: Double = 0.0
    var windSpeed: Double = 0.0
    var humidity: Int = 0
    
    enum CodingKeys: String, CodingKey {
        
        case name
        case main
        case wind
        case temp
        case humidity
        case speed
        
    }
    
    func encode(to encoder: Encoder) throws {
        
        
    }
    
    override init() {
        
        
        
    }
    
    convenience required init(from decoder: Decoder) throws {
        
        self.init()
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let main = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .main)
        
        let wind = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .wind)
        
        name = try container.decode(String.self, forKey: .name)
        
        temp = try main.decode(Double.self, forKey: .temp)
        
        humidity = try main.decode(Int.self, forKey: .humidity)
        
        windSpeed = try wind.decode(Double.self, forKey: .speed)
        
    }
    
    
    
}
