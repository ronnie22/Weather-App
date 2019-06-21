//
//  APIClient.swift
//  Weather App
//
//  Created by Raunak Sinha on 19/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import Foundation

class APIClients {
    
    static let shared: APIClients = APIClients()
    
    let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    let apiKey = ""
    
    func getWeatherDataURL(Lat: String,Lon:String) -> String {
        return "\(baseURL)?lat=\(Lat)&lon=\(Lon)&APPID=\(apiKey)"
    }
}
