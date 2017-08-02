//
//  MiscFunctions.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/29/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import Foundation
import UIKit


/*!
 *
 * Unwrap JSON String
 *
 * @param      dictionary object <String,AnyObject>, index to be unwrapped
 * @return     unwrapped string
 */
public func unwrapJSONString(_ array:Dictionary<String,AnyObject>, _ index:String)->String{
    var value:String = ""
    if let _value = array[index] as? String{
        value = _value
    }
    return value
}

/*!
 *
 * Unwrap JSON Bool
 *
 * @param      dictionary object <String,AnyObject>, index to be unwrapped
 * @return     unwrapped string
 */
public func unwrapJSONBool(_ array:Dictionary<String,AnyObject>, _ index:String)->Bool{
    var value:Bool = false
    if let _value = array[index] as? Bool {
        value = _value
    }
    return value
}

/*!
 *
 * Unwrap JSON Int
 *
 * @param      dictionary object <String,AnyObject>, index to be unwrapped
 * @return     unwrapped int
 */
public func unwrapJSONInt(_ array:Dictionary<String,AnyObject>, _ index:String)->Int{
    var value:Int = 0
    if let _value = array[index] as? Int{
        value = _value
    }
    return value
}

public func showStatusBarActivity(){
     UIApplication.shared.isNetworkActivityIndicatorVisible = true
}

public func hideStatusBarActivity(){
     UIApplication.shared.isNetworkActivityIndicatorVisible = false
}
