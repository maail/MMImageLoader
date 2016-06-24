//
//  ImageCollectionViewController.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/26/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import UIKit

private let reuseIdentifier = "ImageCell"

class ImageCollectionViewController: UICollectionViewController, UIViewControllerPreviewingDelegate {
    
    var imageLoader                  = MMImageLoader()
    var networking                   = MMNetworking.sharedManager
    var imagedDownloaded:[Int]       = []
    var imageArray: [UnsplashModel]  = []
    var refreshControl               = UIRefreshControl()
    var activityIndicator            = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDefault()
        self.setStyle()
        self.loadData()
    }
    
    func setDefault(){
        
        //check for 3D Touch Availability
        if #available(iOS 9.0, *) {
            if( traitCollection.forceTouchCapability == .Available){
                registerForPreviewingWithDelegate(self, sourceView: view)
            }
        }
        
        //register custom UICollectionViewCell
        let xib : UINib           = UINib (nibName: "ImageCollectionViewCell", bundle: nil)
        self.collectionView!.registerNib(xib, forCellWithReuseIdentifier: reuseIdentifier)
        
        //pull to refresh setup
        self.collectionView?.alwaysBounceVertical = true
        self.refreshControl.attributedTitle       = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.tintColor             = UIColor.grayColor()
        self.refreshControl.addTarget(self, action: #selector(ImageCollectionViewController.refresh), forControlEvents: UIControlEvents.ValueChanged)
        collectionView!.addSubview(refreshControl)
        
        //add activity indicator on load
        activityIndicator.frame                        = CGRectMake(0, 0, 50, 50);
        activityIndicator.center                       = self.view.center
        activityIndicator.hidesWhenStopped             = true
        activityIndicator.activityIndicatorViewStyle   = UIActivityIndicatorViewStyle.WhiteLarge
        self.view.addSubview(activityIndicator)
    }
    
    func setStyle(){
        self.collectionView?.backgroundColor = UIColor(red: 0.797, green: 0.797, blue: 0.797, alpha: 1)
    }
    
    func refresh(sender:AnyObject?){
        self.loadData("Pull")
    }
    
    func loadData(Type:String = ""){
        //Load Images from Unsplash.It and put in in an Array
        
        showStatusBarActivity()
        if Type != "Pull"{
            self.activityIndicator.startAnimating()
        }
        
        self.imageArray.removeAll()
        let apiURL     = API.Client.rawValue + API.List.rawValue
        networking.makeRequest(apiURL) { (Status, Data) in
            
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()
            hideStatusBarActivity()
            
            if Status{
                do{
                    if let json = try NSJSONSerialization.JSONObjectWithData(Data, options: .AllowFragments) as? [[String: AnyObject]]{
                        for list in json{
                            let Format    = unwrapJSONString(list, "format")
                            let Width     = unwrapJSONInt(list, "width")
                            let Height    = unwrapJSONInt(list, "height")
                            let FileName  = unwrapJSONString(list, "filename")
                            let ID        = unwrapJSONInt(list, "id")
                            let Author    = unwrapJSONString(list, "author")
                            let AuthorURL = unwrapJSONString(list, "author_url")
                            let PostURL   = unwrapJSONString(list, "post_url")
                            self.imageArray.append(UnsplashModel(Format: Format, Width: Width, Height: Height, FileName: FileName, ID: ID, Author: Author, AuthorURL: AuthorURL, PostURL: PostURL))
                        }
                        
                        self.collectionView?.reloadData()
                    }
                }catch{
                    print("JSON Serializing Error: \(error)")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
  
    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var  cell:ImageCollectionViewCell? = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as? ImageCollectionViewCell
        if (cell == nil)
        {
            let nib:Array = NSBundle.mainBundle().loadNibNamed("ImageCollectionViewCell", owner: self, options: nil)
            cell = nib[0] as? ImageCollectionViewCell
        }
        let source = self.imageArray[indexPath.row]
        
        if cell!.contentView.viewWithTag(source.ID + 1) == nil{
            cell?.imageView.image = UIImage(named: "PlaceHolder")
            cell!.imageView.tag   = source.ID + 1
            let resizeImageURL    = API.Resize(Width: 200, Height: 0, ImageID: source.ID)
            showStatusBarActivity()
            imageLoader.requestImage(resizeImageURL) { (Status, Image) in
                hideStatusBarActivity()
                if Status{
                   if let updateCell = self.collectionView?.cellForItemAtIndexPath(indexPath) as? ImageCollectionViewCell{
                        updateCell.imageView.image = Image
                        self.imagedDownloaded.append(source.ID)
                   }
                }
            }
        }
        
        return cell!
    }
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize{
        if DeviceType.IS_IPAD{
            return  CGSizeMake(self.view.frame.width/3.3, self.view.frame.width/3.3)
        }else if DeviceType.IS_IPHONE_5{
            return  CGSizeMake(self.view.frame.width/3.6, self.view.frame.width/3.6)
        }else if DeviceType.IS_IPHONE_6P{
            return  CGSizeMake(self.view.frame.width/3.5, self.view.frame.width/3.5)
        }else{
            return  CGSizeMake(self.view.frame.width/3.5, self.view.frame.width/3.5)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 10, 15, 10)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ImageSegueDetails", sender: indexPath)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ImageSegueDetails"{
            let vc           = segue.destinationViewController  as! ImageDetailsViewController
            let indexPath    = sender as! NSIndexPath
            vc.imageDetails  = self.imageArray[indexPath.row]
        }
    }
    
    
    // MARK: UIViewControllerPreviewingDelegate
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let point : CGPoint         = self.collectionView!.convertPoint(location, fromView: collectionView!.superview)
        let indexPath               = self.collectionView!.indexPathForItemAtPoint(point)
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc                      = storyboard.instantiateViewControllerWithIdentifier("ImageDetailsViewController") as! ImageDetailsViewController
        vc.imageDetails             = self.imageArray[indexPath!.row]
        vc.preferredContentSize     = CGSize(width: 0.0, height: 450)
 
        return vc
        
    }
    
    func previewingContext(previewingContext: UIViewControllerPreviewing, commitViewController viewControllerToCommit: UIViewController) {
        showViewController(viewControllerToCommit, sender: self)
    }

    
    

}
