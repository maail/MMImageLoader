//
//  MMNetworking.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/26/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation


class MMNetworking: NSObject, URLSessionTaskDelegate{
    
    static let sharedManager      = MMNetworking()
    
    var Session                   = URLSession()
    let URLCache                  = Foundation.URLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 0, diskPath: nil)//Allocate 50MB of Memory
    
    let URLRequestTimeOutInterval = 30.0
    let CacheStoragePolicy        = Foundation.URLCache.StoragePolicy.allowedInMemoryOnly //can change here to allow disk cache
    let RequestCachePolicy        = NSURLRequest.CachePolicy.returnCacheDataElseLoad
    
    let requestLimit              = 10 //set number of connections at a given time
    
    override init() {
        super.init()
        let URLConfig                           = URLSessionConfiguration.default
        URLConfig.requestCachePolicy            = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        URLConfig.urlCache                      = URLCache
        URLConfig.httpMaximumConnectionsPerHost = requestLimit //set number of connections at a given time. currently set to 10
        self.Session                            = URLSession(configuration: URLConfig, delegate: self, delegateQueue: nil)
    }
    
    
    /*!
     *
     * Make a NSURLRequest
     *
     * @param      NSURL
     * @return     Status, Data
     */
    func makeRequest(_ URL: String, completion: @escaping (_ Status:Bool, _ Data:Data) -> ()){
        let nsURL      = Foundation.URL(string: URL)
        let URLRequest = Foundation.URLRequest(url: nsURL!, cachePolicy: self.RequestCachePolicy, timeoutInterval: URLRequestTimeOutInterval)
        checkCache(URLRequest) { (Status, Data) in
            if Status{
                print("MMNetworkingInfo: Data loaded from cache for (\(URL))" )
                completion(Status, Data)
            }else{
                let task = self.Session.dataTask(with: nsURL!, completionHandler: {(data, response, error) in
                    if let errorUnwrapped = error{
                        print("MMNetworkingErrorDescription:" + errorUnwrapped.localizedDescription)
                        completion(false, Foundation.Data())
                    }else{
                        if let dataUnwrapped = data{
                            //cache here
                            self.URLCache.storeCachedResponse(CachedURLResponse(response:response!, data:dataUnwrapped, userInfo:nil, storagePolicy:self.CacheStoragePolicy), for: URLRequest)
                            DispatchQueue.main.async { () -> Void in
                               completion(true, dataUnwrapped)
                            }
                        }else{
                            completion(true, Foundation.Data())
                        }
                    }
                }) 
                task.resume()
            }
        }
    }
    
    
    /*!
     *
     * Check whether cache exists for NSURLRequest
     *
     * @param      NSURLRequest
     * @return     Status, Data
     */
    func checkCache(_ URLRequest: Foundation.URLRequest, completion: (_ Status:Bool, _ Data:Data) -> ()){
        if let response = URLCache.cachedResponse(for: URLRequest) {
            if response.data.count > 0 {
                completion(true, response.data)
            }else{
                completion(false, Data())
            }
        }else{
            completion(false, Data())
        }
    }
    
    
    /*!
     *
     * Cancel a connection
     *
     * @param      NSURL
     * @return     void
     */
    func cancelConnection(_ URL:Foundation.URL) {
        self.Session.dataTask(with: URL).cancel()
    }
}
