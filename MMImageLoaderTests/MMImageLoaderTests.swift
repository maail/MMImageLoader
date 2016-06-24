//
//  MMImageLoaderTests.swift
//  MMImageLoaderTests
//
//  Created by Mohamed Maail on 5/26/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import XCTest
@testable import MMImageLoader

class MMImageLoaderTests: XCTestCase {
    
    var jsonURL  = API.Client.rawValue + API.List.rawValue
    var imageURL = API.Resize(Width: 1700, Height: 1200, ImageID: 5)
    
    override func setUp() {
        super.setUp()
    }
    
    /*!
     *
     * Test whether Image can be downloaded
     *
     * @param     nil
     * @return    nil
     */
    func testImageDownloads(){
        let imageLoader    = MMImageLoader()
        imageLoader.requestImage(self.imageURL) { (Status, Image) in
            if Status{
                XCTAssert(true)
            }else{
                XCTAssert(false)
            }
        }
    }
    
    /*!
     *
     * Test whether caching works
     *
     * @param     nil
     * @return    nil
     */
    func testCache(){
        let networking = MMNetworking.sharedManager
        networking.makeRequest(jsonURL) { (Status, Data) in //make first request
            if Status{
                //check whether requested data saved in memory
                let nsURL      = NSURL(string: self.jsonURL)
                let URLRequest = NSURLRequest(URL: nsURL!, cachePolicy: networking.RequestCachePolicy, timeoutInterval: networking.URLRequestTimeOutInterval)
                networking.checkCache(URLRequest, completion: { (Status, Data) in
                    if Status{
                        XCTAssert(true)
                    }else{
                        XCTAssert(false)
                    }
                })
            }else{
                XCTAssert(false)
            }
        }
    }
    
    
    /*!
     *
     * Test whether downloads other than images work. In this case JSON
     *
     * @param      nil
     * @return     nil
     */
    func testOtherDownloads(){
        let networking = MMNetworking()
        networking.makeRequest(jsonURL) { (Status, Data) in
            if Status{
                XCTAssert(true)
            }else{
                XCTAssert(false)
            }
        }
    }
    
    
    
    override func tearDown() {
        super.tearDown()
    }

    

    func testPerformance() {
        self.measureBlock {
//            self.testOtherDownloads()
            self.testImageDownloads()
        }
    }
    
}
