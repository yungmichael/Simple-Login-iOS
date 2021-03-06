//
//  SLApiService+SharedFunctions.swift
//  Simple Login
//
//  Created by Thanh-Nhon Nguyen on 25/04/2020.
//  Copyright © 2020 SimpleLogin. All rights reserved.
//

import Foundation
import Alamofire

final class SLApiService {
    private(set) static var BASE_URL: String = "https://app.simplelogin.io"
    
    static func refreshBaseUrl() {
        BASE_URL = UserDefaults.getApiUrl()
    }
}

// Functions in this file are shared with the Share Extension
extension SLApiService {
    static func fetchUserOptions(apiKey: ApiKey, hostname: String? = nil, completion: @escaping (Result<UserOptions, SLError>) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey.value]
        
        let urlString: String
        if let hostname = hostname {
            urlString = "\(BASE_URL)/api/v3/alias/options?hostname=\(hostname)"
        } else {
            urlString = "\(BASE_URL)/api/v3/alias/options"
        }
        
        AF.request(urlString, method: .get, parameters: nil, encoding: URLEncoding.default, headers: headers, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 200:
                    do {
                        let userOptions = try UserOptions(data: data)
                        completion(.success(userOptions))
                    } catch let error as SLError {
                        completion(.failure(error))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }
                    
                case 401: completion(.failure(.invalidApiKey))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }
                
            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }
    
    static func createAlias(apiKey: ApiKey, prefix: String, suffix: String, note: String?, completion: @escaping (Result<Alias, SLError>) -> Void) {
        let headers: HTTPHeaders = ["Authentication": apiKey.value]
        var parameters = ["alias_prefix" : prefix, "alias_suffix" : suffix]
        
        if let note = note {
            parameters["note"] = note
        }
        
        AF.request("\(BASE_URL)/api/alias/custom/new", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers, interceptor: nil).responseData { response in
            
            switch response.result {
            case .success(let data):
                guard let statusCode = response.response?.statusCode else {
                    completion(.failure(.unknownResponseStatusCode))
                    return
                }
                
                switch statusCode {
                case 201:
                    do {
                        let alias = try Alias(data: data)
                        completion(.success(alias))
                    } catch let slError as SLError {
                        completion(.failure(slError))
                    } catch {
                        completion(.failure(.unknownError(error: error)))
                    }
                    
                case 401: completion(.failure(.invalidApiKey))
                case 409: completion(.failure(.duplicatedAlias))
                case 500: completion(.failure(.internalServerError))
                case 502: completion(.failure(.badGateway))
                default: completion(.failure(.unknownErrorWithStatusCode(statusCode: statusCode)))
                }
                
            case .failure(let error):
                completion(.failure(.alamofireError(error: error)))
            }
        }
    }
}
