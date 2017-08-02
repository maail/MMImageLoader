//
//  ImageDetailsViewController.swift
//  MMImageLoader
//
//  Created by Mohamed Maail on 5/29/16.
//  Copyright © 2016 Mohamed Maail. All rights reserved.
//

import UIKit

class ImageDetailsViewController: UIViewController {
    
    @IBOutlet weak var PictureImageView: UIImageView!
    @IBOutlet weak var AuthorLabel: UILabel!
    @IBOutlet weak var ProfileImageView: UIImageView!
    @IBOutlet weak var AuthorURLLabel: UILabel!
    
    var imageDetails      : UnsplashModel!
    var imageLoader       = MMImageLoader()
    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setDefault()
        self.setStyle()
        self.setData()
    }
    
    func setDefault(){
        
        self.title = "Image Details"
        
        //add activity indicator on load
        activityIndicator.frame                        = CGRect(x: 0, y: 0, width: 50, height: 50);
        activityIndicator.center.x                     = self.view.center.x
        activityIndicator.center.y                     = self.PictureImageView.center.y - 65
        activityIndicator.hidesWhenStopped             = true
        activityIndicator.activityIndicatorViewStyle   = UIActivityIndicatorViewStyle.whiteLarge
        self.PictureImageView.addSubview(activityIndicator)
    }
    
   
    
    func setStyle(){
        self.view.backgroundColor                          = UIColor(red: 0.797, green: 0.797, blue: 0.797, alpha: 1)
        self.ProfileImageView.layer.cornerRadius           = self.ProfileImageView.frame.size.width / 2
        self.PictureImageView.contentMode                  = .center
        self.PictureImageView.layer.masksToBounds          = true
        self.navigationController?.navigationBar.tintColor = UIColor.gray
    }
    
    func setData(){
        
        self.AuthorLabel.text    = imageDetails.Author
        self.AuthorURLLabel.text = imageDetails.AuthorURL
        
        //show low res image first
        self.activityIndicator.startAnimating()
        let lowResImageURL = API.Resize(Width: 200, Height: 0, ImageID: imageDetails.ID)
        imageLoader.requestImage(lowResImageURL) { (Status, Image) in
            hideStatusBarActivity()
            if Status{
                self.PictureImageView.contentMode = .scaleAspectFill
                self.PictureImageView.image       = Image
            }
        }
        
        //download and set image
        showStatusBarActivity()
        let resizeImageURL = API.Resize(Width: 1700, Height: 1200, ImageID: imageDetails.ID)
        imageLoader.requestImage(resizeImageURL) { (Status, Image) in
            hideStatusBarActivity()
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            if Status{
                self.PictureImageView.alpha = 0
                UIView.animate(withDuration: 0.5, delay: 0.12, options: UIViewAnimationOptions.curveEaseIn, animations: {
                    self.PictureImageView.contentMode = .scaleAspectFill
                    self.PictureImageView.image       = Image
                    self.PictureImageView.alpha = 1
                }, completion: nil)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.PictureImageView.image = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
