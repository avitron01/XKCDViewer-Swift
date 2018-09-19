//
//    APIManager.swift
//
//    Copyright (c) 2018 avitron01
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import Foundation

typealias APICompletion<T> = (Result<T>) -> Void

enum Result<T> {
    case success(T?)
    case error(APIError?)
}

class APIManager {
    static let shared = APIManager()
    private static let decoder = JSONDecoder()
    
    public static func fetchData<T: Codable>(for endpoint: APIURL, type: T.Type, completion: @escaping APICompletion<T>) {
        guard let urlRequest = URLRequest(path: endpoint.value, method: endpoint.method) else {
            completion(.error(.parseError))
            return
        }
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            guard error == nil else {
                DispatchQueue.main.sync {
                    completion(.error(.network(error)))
                }
                return
            }
            
            guard let jsonData = data else {
                DispatchQueue.main.sync {
                    completion(.error(.noDataFound))
                }
                return
            }
            
            do {
                let decodedObject = try decoder.decode(T.self, from: jsonData)
                DispatchQueue.main.sync {
                    completion(.success(decodedObject))
                }
            } catch let error {
                DispatchQueue.main.sync {
                    completion(.error(.decoding(error)))
                }
            }
        }.resume()
    }
}
