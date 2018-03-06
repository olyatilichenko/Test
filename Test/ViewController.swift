//
//  ViewController.swift
//  Test
//
//  Created by Olya Tilichenko on 04.03.2018.
//  Copyright © 2018 Olya Tilichenko. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    
    let fetchRequest:NSFetchRequest<Request>=Request.fetchRequest()
    var requests = [NSManagedObject]()
    var lat:Double?
    var lon:Double?
    var time:String?
    var city:String?
    let userCalendar = Calendar.current
    
    private let apiKey = "468f46eec52c5aa16c325dea1193b9b6"
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/weather"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
        locationLabel.text = "\(location.coordinate.latitude) \(location.coordinate.longitude)"
            geocoder.reverseGeocodeLocation(location){
                (placemarks, error) in
                self.processResponse(withPlacemarks: placemarks, error: error)
                self.lat = location.coordinate.latitude
                self.lon = location.coordinate.longitude
                self.getWeather(self.lat!, self.lon!)
            }
           
        }
        
    }

    func processResponse(withPlacemarks placemarks: [CLPlacemark]?, error: Error?) {
        
        if let error = error {
            print("Unable to Reverse Geocode Location (\(error))")
            locationLabel.text = "Unable to Find Address for Location"
            
        } else {
            if let placemarks = placemarks, let placemark = placemarks.first {
                addressLabel.text = placemark.compactAddress
                city = placemark.locality
            } else {
                addressLabel.text = "No Matching Addresses Found"
            }
        }
    }

    func getWeather(_ lat: Double, _ lon: Double) {
  
        let session = URLSession.shared
        let weatherURL = URL(string: "\(openWeatherMapBaseURL)?lat=\(lat)&lon=\(lon)&APPID=\(apiKey)")!
        let dataTask = session.dataTask(with: weatherURL) {
                (data: Data?, response: URLResponse?, error: Error?) in
                if let error = error {
                    print("Error:\n\(error)")
                }
                if let data = data {
                    self.time = DateFormatter.localizedString(from: NSDate() as Date, dateStyle: .medium, timeStyle: .short)
                    let dataString = String(data: data, encoding: String.Encoding.utf8)
                    print("All the weather data:\n\(dataString!)")
                    if let jsonObj = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary {
                if let mainDictionary = jsonObj!.value(forKey: "main") as? NSDictionary {
                    if let temperature = mainDictionary.value(forKey: "temp") {
                        self.saveData(self.city!, "\(temperature)°F")
                        DispatchQueue.main.async {
                            self.temperatureLabel.text = "\(temperature)°F"
                        }
                    }
                } else {
                    print("Error: unable to find temperature in dictionary")
                }
            } else {
                print("Error: unable to convert json data")
            }
        } else {
            print("Error: did not receive data")
            }
        }
            dataTask.resume()
    }

    func saveData(_ city: String, _ temp: String) {

        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let entity =  NSEntityDescription.entity(forEntityName: "Request", in: managedContext)
        
        let request = NSManagedObject(entity: entity!,
                                      insertInto:managedContext)
        
        request.setValue(city, forKey: "city")
        request.setValue(lat, forKey: "latitude")
        request.setValue(lon, forKey: "longitude")
        request.setValue(time, forKey: "time")
        request.setValue(temp, forKey: "temperature")
        
        requests.append(request)
        print("datasaved")
        print(request)
    }
}

extension CLPlacemark {
    
    var compactAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}

