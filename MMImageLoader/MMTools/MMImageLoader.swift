//
//  MMImageLoader.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/26/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation
import UIKit

class MMImageLoader {
    
    /*!
     *
     * Request for an Image
     *
     * @param      NSURL
     * @return     Status, Data
     */
    func requestImage(URL:String, completion: (Status:Bool, Image:UIImage) -> ()){
        MMNetworking.sharedManager.makeRequest(URL) { (Status, Data) in
            if Status{
                if let image = UIImage(data: Data){
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        completion(Status: true, Image: image)
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        print("MMImageLoaderErrorDescription: No image available for URL (\(URL))")
                        completion(Status: false, Image: UIImage())
                    }
                }
            }else{
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    completion(Status: false, Image: UIImage())
                }
            }
        }
    }
    
    
    /*!
     *
     * Cancel Image Download
     *
     * @param      NSURL
     * @return     void
     */
    func cancelImageDownload(URL:NSURL){
        MMNetworking.sharedManager.cancelConnection(URL)
    }
    
    
    
}