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
            if( traitCollection.forceTouchCapability == .available){
                registerForPreviewing(with: self, sourceView: view)
            }
        }
        
        //register custom UICollectionViewCell
        let xib : UINib           = UINib (nibName: "ImageCollectionViewCell", bundle: nil)
        self.collectionView!.register(xib, forCellWithReuseIdentifier: reuseIdentifier)
        
        //pull to refresh setup
        self.collectionView?.alwaysBounceVertical = true
        self.refreshControl.attributedTitle       = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.tintColor             = UIColor.gray
        self.refreshControl.addTarget(self, action: #selector(ImageCollectionViewController.refresh), for: UIControlEvents.valueChanged)
        collectionView!.addSubview(refreshControl)
        
        //add activity indicator on load
        activityIndicator.frame                        = CGRect(x: 0, y: 0, width: 50, height: 50);
        activityIndicator.center                       = self.view.center
        activityIndicator.hidesWhenStopped             = true
        activityIndicator.activityIndicatorViewStyle   = UIActivityIndicatorViewStyle.whiteLarge
        self.view.addSubview(activityIndicator)
    }
    
    func setStyle(){
        self.collectionView?.backgroundColor = UIColor(red: 0.797, green: 0.797, blue: 0.797, alpha: 1)
    }
    
    func refresh(_ sender:AnyObject?){
        self.loadData("Pull")
    }
    
    func loadData(_ Type:String = ""){
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
                    if let json = try JSONSerialization.jsonObject(with: Data, options: .allowFragments) as? [[String: AnyObject]]{
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
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var  cell:ImageCollectionViewCell? = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? ImageCollectionViewCell
        if (cell == nil)
        {
            let nib:Array = Bundle.main.loadNibNamed("ImageCollectionViewCell", owner: self, options: nil)!
            cell = nib[0] as? ImageCollectionViewCell
        }
        let source = self.imageArray[indexPath.row]
        cell?.imageView.image = UIImage(named: "PlaceHolder")
        if cell!.contentView.viewWithTag(source.ID + 1) == nil{
            cell?.imageView.image = UIImage(named: "PlaceHolder")
            cell!.imageView.tag   = source.ID + 1
            let resizeImageURL    = API.Resize(Width: 200, Height: 0, ImageID: source.ID)
            showStatusBarActivity()
            imageLoader.requestImage(resizeImageURL) { (Status, Image) in
                hideStatusBarActivity()
                if Status{
                    cell?.imageView.image = Image
                    self.imagedDownloaded.append(source.ID)
                }
            }
        }
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize{
        if DeviceType.IS_IPAD{
            return  CGSize(width: self.view.frame.width/3.3, height: self.view.frame.width/3.3)
        }else if DeviceType.IS_IPHONE_5{
            return  CGSize(width: self.view.frame.width/3.6, height: self.view.frame.width/3.6)
        }else if DeviceType.IS_IPHONE_6P{
            return  CGSize(width: self.view.frame.width/3.5, height: self.view.frame.width/3.5)
        }else{
            return  CGSize(width: self.view.frame.width/3.5, height: self.view.frame.width/3.5)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(15, 10, 15, 10)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ImageSegueDetails", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageSegueDetails"{
            let vc           = segue.destination  as! ImageDetailsViewController
            let indexPath    = sender as! IndexPath
            vc.imageDetails  = self.imageArray[indexPath.row]
        }
    }
    
    
    // MARK: UIViewControllerPreviewingDelegate
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        let point : CGPoint         = self.collectionView!.convert(location, from: collectionView!.superview)
        let indexPath               = self.collectionView!.indexPathForItem(at: point)
        let storyboard:UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc                      = storyboard.instantiateViewController(withIdentifier: "ImageDetailsViewController") as! ImageDetailsViewController
        vc.imageDetails             = self.imageArray[indexPath!.row]
        vc.preferredContentSize     = CGSize(width: 0.0, height: 450)
 
        return vc
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        show(viewControllerToCommit, sender: self)
    }

    
    

}
