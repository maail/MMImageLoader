//
//  API.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/29/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation


enum API: String{
    case Client = "https://unsplash.it/"
    case List   = "list/"               //Client + List
    
    static func Resize(Width:Int, Height:Int, ImageID: Int) -> String{
        if Height == 0{
            return Client.rawValue + String(Width) + "?image=" + String(ImageID)
        }else{
            return Client.rawValue + String(Width) + "/" + String(Height) + "?image=" + String(ImageID)
        }
        
    }
}
