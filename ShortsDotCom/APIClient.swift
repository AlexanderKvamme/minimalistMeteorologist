//
//  APIClient.swift
//  ShortsDotCom
//
//  Created by Alexander Kvamme on 03/09/16.
//  Copyright © 2016 Alexander Kvamme. All rights reserved.
//
//Generisk APIClient


import Foundation

public let AMKNetworkingErrorDomain = "com.Alexander.Misterbizniz.NetworkingError"
public let MissingHTTPResponseError: Int = 10
public let JSONParsingError: Int = 11

typealias JSON = [String : AnyObject]
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, NSError?) -> Void
typealias JSONTask = URLSessionDataTask

protocol Endpoint{
    var baseURL: URL { get }//get er alltid fast
    var path: String { get }
    var request: URLRequest { get }
}

enum APIResult<T>{
    case success(T)
    case failure(Error)
}

protocol JSONDecodable {
    //failable initializer returnerer nil dersom klassen/structen ikke kan initialiseres med json dictionary
    init?(JSON: [String : AnyObject])
}

protocol APIClient {

    var configuration: URLSessionConfiguration{ get }
    var session: URLSession { get }

    init(configuration: URLSessionConfiguration, APIKey: String)
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask
    func fetch<T : JSONDecodable>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void)

}

//DEFAULT IMPLEMENTATION: Implementation som gjør at programmereren kan ha en fungerende implementering av APIClient fra start

extension APIClient{
    
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask{
        
        let task = session.dataTask(with: request, completionHandler: { data, response, error in
            
            guard let HTTPResponse = response as? HTTPURLResponse else {
                
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment:"")
                ]
                
                //En NSError krever 3 ting. Et Domain, en feilmeldingskode, og userInfo
                let error = NSError(domain: AMKNetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }
            
            if data == nil {
                
                if let error = error { completion(nil, HTTPResponse, error as NSError?) }
            
            } else {
                //data er mottatt, og vi har fått en HTTPResponse. Switcher på de mest populære svarene
                switch HTTPResponse.statusCode{
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                        
                        //TEST END
                        
                        completion(json, HTTPResponse, nil)
                    } catch let error as NSError{
                        print("error caught")
                        completion(nil, HTTPResponse, error)
                        }
                    
                    default: print("Received HTTPResponse with statuscode: \(HTTPResponse.statusCode) - not handled ")
                    }
            }
        })
         return task
    }
    
    func fetch<T: JSONDecodable>(request: URLRequest, parse: @escaping (JSON) -> T?, completion: @escaping (APIResult<T>) -> Void){
        
        let task = JSONTaskWithRequest(request: request){ json, response, error in
        
            DispatchQueue.main.async(execute: { () -> Void in

            guard let json = json else {
                
                if let error = error {
                    print("error in JSONTaskWithRequest")
                    
                    completion(APIResult.failure(error))
                }
                return
            }
            
            if let value = parse(json) {
                
                completion(APIResult.success(value))
            } else {
                
                print("\nError with parse(json)")
                
                let error = NSError(domain: AMKNetworkingErrorDomain, code: JSONParsingError, userInfo: nil)
                completion(APIResult.failure(error))
            
            }
        })
        
        }
        task.resume()
    }
}
