//
//  ViewController.swift
//  Weather App
//
//  Created by Raunak Sinha on 19/06/19.
//  Copyright © 2019 Raunak Sinha. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation

class ViewController: UIViewController {
    
    
    @IBOutlet weak var cityNameLabel: UILabel!
    
    
    @IBOutlet weak var tempraturLabel: UILabel!
    
    
    @IBOutlet weak var humidityLabel: UILabel!
    
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    
    var LocationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        LocationManager.delegate = self
        
        LocationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        LocationManager.requestLocation()
        
    }
    
    
    
    
    
    func getWeatherWithAlamofire (lat: String,lon: String) {
        
        guard let url = URL(string: APIClients.shared.getWeatherDataURL(Lat: lat, Lon: lon)) else {
            
            print("could not form the url")
            return
        }
        
        let headers: HTTPHeaders = [
        
            "Accept": "application/json"
        
        ]
        
        
        let parameters: Parameters = [:]
        
        AF.request(url, method: HTTPMethod.get, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON { [weak self] (response) in
            guard let strongSelf = self else {return}
            
            guard let data = response.data else {return}
            
            DispatchQueue.main.async {
                strongSelf.parseJSONWithCodable(data: data)
            }
            
            /*
            
            if let jsonData = response.value as? [String:Any] {
                
                DispatchQueue.main.async {

                    print(jsonData)
                 
                    strongSelf.parseJSONWithCodable(data: jsonData)
                }
            }*/
        }
        
      /*  AF.request(url).responseJSON { (response) in
            if let jsonData = response.value as? [String:Any] {
                
                print(jsonData)
                
            }
        }*/
    }
    
    
    func parseJSONWithCodable(data: Data) {
        
        do {
            
            let weatherObject = try JSONDecoder().decode(WeatherModel.self, from: data)
            
            humidityLabel.text = String(weatherObject.humidity)
            
            cityNameLabel.text = weatherObject.name
            
            tempraturLabel.text = String(Int(weatherObject.temp))
            
            windSpeedLabel.text = String(weatherObject.windSpeed)
            
            
            
        }catch let error as NSError {
            
            print(error.localizedDescription)
            
        }
        
        
    }
    
    func parseDataWithSwifty(data: [String:Any]) {
        
        let jsonData = JSON(data)
        
        if let humid = jsonData["main"]["humidity"].int {
            
            humidityLabel.text = "\(humid)"
        }
        if let temp = jsonData["main"]["temp"].double {
            tempraturLabel.text = "\(Int(temp))"
        }
        if let speed = jsonData["wind"]["speed"].double {
            windSpeedLabel.text = "\(speed)"
        }
        if let name = jsonData["name"].string {
            
            cityNameLabel.text = name
            
        }
        
    }
    
    func parseJSONManually(data: [String:Any]) {
        
        if let main = data["main"] as? [String:Any] {

            if let humid = main["humidity"] as? Int {
                
                humidityLabel.text = "\(humid)"
            }
            
            if let temp = main["temp"] as? Double {
                
                tempraturLabel.text = "\(Int(temp))"
            }
            
        }
        
        if let wind = data["wind"] as? [String:Any] {
            
            if let speed = wind["speed"] as? Double {
                
                windSpeedLabel.text = "\(speed)"
            }
        }
        
        if let name = data["name"] as? String {
            
            cityNameLabel.text = name
            
        }
        
    }
    
    func getWeatherWithURLSession (lat: String,lon: String) {
        
        
        let apiKey = APIClients.shared.apiKey
        
        if var urlComponents = URLComponents(string: APIClients.shared.baseURL) {
            urlComponents.query = "lat=\(lat)&lon=\(lon)&APPID=\(apiKey)"
            guard let url = urlComponents.url else {return}
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")
            let config = URLSessionConfiguration.default
            let session = URLSession(configuration: config)
            let task = session.dataTask(with: request) { (data, response, error) in
                
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                guard let data = data else {return}
                
                do {
                    
                    guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                        
                        print("there was an converting data into jsom")
                        
                        return
                    }
                    
                    print(weatherData)
                    
                }catch {
                    
                    print("error in converting into json")
                    
                }
            }
            
            task.resume()
        }
        
        
        
       /* guard let weatherURL = URL(string: APIClients.shared.getWeatherDataURL(Lat: lat, Lon: lon)) else {return}
        
        URLSession.shared.dataTask(with: weatherURL) { (data, response, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else {return}
            
            do {
                
                guard let weatherData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                    
                    print("there was an converting data into jsom")
                    
                    return
                }
                
                print(weatherData)
                
            }catch {
                
                print("error in converting into json")
                
            }
            
        }.resume()
     */
    }


}

extension ViewController: CLLocationManagerDelegate {
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let lat = String(location.coordinate.latitude)
            let lon = String(location.coordinate.longitude)
            
            print(lon)
            print(lat)
            
            getWeatherWithAlamofire(lat: lat, lon: lon)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
      
        
        switch status {
        
        case .notDetermined:
            
            LocationManager.requestWhenInUseAuthorization()
        case .authorizedAlways, .authorizedWhenInUse:
            
            LocationManager.requestLocation()
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Access Disabled", message: "Weather app needs your location to give you weather forecasts. Open your settings to change authorization", preferredStyle: .alert)
            
            let cancelAction = UIAlertAction(title: "cancel", style: .cancel) { (action) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            let openAction = UIAlertAction(title: "Open", style: .default) { (action) in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
            
            alert.addAction(openAction)
            
            present(alert,animated: true,completion: nil)
            
            break
        @unknown default:
            fatalError()
        }
    }
}

