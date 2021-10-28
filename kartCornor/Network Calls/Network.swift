//
//  Network.swift
//  kartCornor
//
//  Created by Srinivas on 01/08/20.
//  Copyright © 2020 Srinivas. All rights reserved.
//

import UIKit
import Alamofire
class Network: NSObject {
    
    static let sharedInstance = Network()
    private override init() { }
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let homeVC = HomeViewController()
    
    func gettingServerResponse(urlString : String, completion: @escaping ((NSDictionary) -> Void)) {
        //let session = URLSession.shared
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(15)
        let session = URLSession(configuration: configuration)
        let url = URL(string: urlString)!
        print(url)
        if NetworkReachabilityManager()!.isReachable {
            let task = session.dataTask(with: url, completionHandler: { data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    ANLoader.hide()
                    return
                }
                
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    ANLoader.hide()
                    return
                }
                
                // Serialize the data into an object
                if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                    print("json data")
                    completion(json)
                } else if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSArray {
                    print("array data",json)
                    let dict : NSDictionary = NSDictionary()
                    completion(dict)
                    ANLoader.hide()
                } else {
                    print("invalid")
                }
                
            })
            task.resume()
        } else {
           print("No interner\t")
        }
    }
    func postServerDataandgetResponse(urlString : String, parameters:[String:Any], completion: @escaping ((NSDictionary) -> Void)) {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(45)
        let session = URLSession(configuration: configuration)
        print(urlString)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded()
        if NetworkReachabilityManager()!.isReachable {
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {                                              // check for fundamental networking error
                    print("server error", error ?? "Unknown error")
                    ANLoader.hide()
                    return
                }
                if (data.isEmpty){
                    print("dara error", data.count)
                    ANLoader.hide()
                    return
                }
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    ANLoader.hide()
                    return
                }
                if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                    print("json data")
                    completion(json)
                } else if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSArray {
                    print("array data",json)
                    let dict : NSDictionary = NSDictionary()
                    completion(dict)
                    ANLoader.hide()
                } else {
                    ANLoader.hide()
                    print("invalid")
                }
            }
            task.resume()
        } else {
            print("No internet")
        }
    }
    func postServerDataandgetResponse1(urlString : String, parameters:[String:Any], completion: @escaping ((NSDictionary) -> Void)) {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(45)
        let session = URLSession(configuration: configuration)
      //  print(request)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = parameters.percentEncoded()
        if NetworkReachabilityManager()!.isReachable {
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {                                              // check for fundamental networking error
                    print("server error", error ?? "Unknown error")
                    ANLoader.hide()
                    return
                }
                print(response)
                if (data.isEmpty){
                    ANLoader.hide()
                    return
                }
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    ANLoader.hide()
                    return
                }
                if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                    print("json data")
                    completion(json)
                } else if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSArray {
                    print("array data",json)
                    let dict : NSDictionary = NSDictionary()
                    completion(dict)
                    ANLoader.hide()
                } else {
                    ANLoader.hide()
                    print("invalid")
                }
            }
            task.resume()
        } else {
            print("No interner\t")
        }
    }
    func postServerDataandgetResponse2(urlString : String, parameters:NSDictionary, completion: @escaping ((NSDictionary) -> Void)) {
        
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(45)
        let session = URLSession(configuration: configuration)
      //  print(request)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
       // request.httpBody = parameters.percentEncoded()
        if NetworkReachabilityManager()!.isReachable {
            let task = session.dataTask(with: request) { data, response, error in
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      error == nil else {                                              // check for fundamental networking error
                    print("server error", error ?? "Unknown error")
                    ANLoader.hide()
                    return
                }
                print(response)
                if (data.isEmpty){
                    ANLoader.hide()
                    return
                }
                guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    ANLoader.hide()
                    return
                }
                if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSDictionary {
                    print("json data")
                    completion(json)
                } else if let json = try! JSONSerialization.jsonObject(with: data, options: [.allowFragments]) as? NSArray {
                    print("array data",json)
                    let dict : NSDictionary = NSDictionary()
                    completion(dict)
                    ANLoader.hide()
                } else {
                    ANLoader.hide()
                    print("invalid")
                }
            }
            task.resume()
        } else {
            print("No interner\t")
        }
    }
    
    func submitDatatoServer(urlString : String, parameters:NSDictionary, completion: @escaping ((NSDictionary) -> Void)) {
        //declare parameter as a dictionary which contains string as key and value combination. considering inputs are valid

       // let parameters = ["id": 13, "name": "jack"]

        //create the url with URL
     //   let url = URL(string: "www.thisismylink.com/postName.php")! //change the url

        //create the session object
        let session = URLSession.shared

        //now create the URLRequest object using the url object
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST" //set http method as POST

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
        } catch let error {
            print(error.localizedDescription)
        }

        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  error == nil else {                                              // check for fundamental networking error
                print("server error", error ?? "Unknown error")
                ANLoader.hide()
                return
            }
            print(response)
            if (data.isEmpty){
                ANLoader.hide()
                return
            }
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
              //  print("response = \(response)")
                ANLoader.hide()
                return
            }
            
            guard error == nil else {
                return
            }
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    completion(json as NSDictionary)
                    ANLoader.hide()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
    }
}
extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
