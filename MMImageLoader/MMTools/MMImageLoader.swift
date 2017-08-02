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
    func requestImage(_ URL:String, completion: @escaping (_ Status:Bool, _ Image:UIImage) -> ()){
        MMNetworking.sharedManager.makeRequest(URL) { (Status, Data) in
            if Status{
                if let image = UIImage(data: Data){
                    DispatchQueue.main.async { () -> Void in
                        completion(true, image)
                    }
                }else{
                    DispatchQueue.main.async { () -> Void in
                        print("MMImageLoaderErrorDescription: No image available for URL (\(URL))")
                        completion(false, UIImage())
                    }
                }
            }else{
                DispatchQueue.main.async { () -> Void in
                    completion(false, UIImage())
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
    func cancelImageDownload(_ URL:Foundation.URL){
        MMNetworking.sharedManager.cancelConnection(URL)
    }
    
    
    
}
