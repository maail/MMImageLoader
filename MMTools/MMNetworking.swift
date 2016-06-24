//
//  MMNetworking.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/26/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation


class MMNetworking: NSObject, NSURLSessionTaskDelegate{
    
    static let sharedManager      = MMNetworking()
    
    var Session                   = NSURLSession()
    let URLCache                  = NSURLCache(memoryCapacity: 50 * 1024 * 1024, diskCapacity: 0, diskPath: nil)//Allocate 50MB of Memory
    
    let URLRequestTimeOutInterval = 30.0
    let CacheStoragePolicy        = NSURLCacheStoragePolicy.AllowedInMemoryOnly //can change here to allow disk cache
    let RequestCachePolicy        = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
    
    let requestLimit              = 10 //set number of connections at a given time
    
    override init() {
        super.init()
        let URLConfig                           = NSURLSessionConfiguration.defaultSessionConfiguration()
        URLConfig.requestCachePolicy            = NSURLRequestCachePolicy.ReturnCacheDataElseLoad
        URLConfig.URLCache                      = URLCache
        URLConfig.HTTPMaximumConnectionsPerHost = requestLimit //set number of connections at a given time. currently set to 10
        self.Session                            = NSURLSession(configuration: URLConfig, delegate: self, delegateQueue: nil)
    }
    
    
    /*!
     *
     * Make a NSURLRequest
     *
     * @param      NSURL
     * @return     Status, Data
     */
    func makeRequest(URL: String, completion: (Status:Bool, Data:NSData) -> ()){
        let nsURL      = NSURL(string: URL)
        let URLRequest = NSURLRequest(URL: nsURL!, cachePolicy: self.RequestCachePolicy, timeoutInterval: URLRequestTimeOutInterval)
        checkCache(URLRequest) { (Status, Data) in
            if Status{
                print("MMNetworkingInfo: Data loaded from cache for (\(URL))" )
                completion(Status: Status, Data: Data)
            }else{
                let task = self.Session.dataTaskWithURL(nsURL!) {(data, response, error) in
                    if let errorUnwrapped = error{
                        print("MMNetworkingErrorDescription:" + errorUnwrapped.localizedDescription)
                        completion(Status: false, Data: NSData())
                    }else{
                        if let dataUnwrapped = data{
                            //cache here
                            self.URLCache.storeCachedResponse(NSCachedURLResponse(response:response!, data:dataUnwrapped, userInfo:nil, storagePolicy:self.CacheStoragePolicy), forRequest: URLRequest)
                            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                               completion(Status: true, Data: dataUnwrapped)
                            }
                        }else{
                            completion(Status: true, Data: NSData())
                        }
                    }
                }
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
    func checkCache(URLRequest: NSURLRequest, completion: (Status:Bool, Data:NSData) -> ()){
        if let response = URLCache.cachedResponseForRequest(URLRequest) {
            if response.data.length > 0 {
                completion(Status: true, Data: response.data)
            }else{
                completion(Status: false, Data: NSData())
            }
        }else{
            completion(Status: false, Data: NSData())
        }
    }
    
    
    /*!
     *
     * Cancel a connection
     *
     * @param      NSURL
     * @return     void
     */
    func cancelConnection(URL:NSURL) {
        self.Session.dataTaskWithURL(URL).cancel()
    }
}