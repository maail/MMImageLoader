# MMImageLoader
Simple image caching library in Swift

# Installation
To use the library just include the MMTools Folder to your project.

# Usage
MMImageLoader Usage Example:

```swift
let imageLoader = MMImageLoader()
imageLoader.requestImage(resizeImageURL) { (Status, Image) in
      if Status{
                self.ImageView.image  = Image
       }
}
```

#Details
- Caching is taken care of in the MMNetworking class. This class is abstracted to MMImageLoader. 
- MMNetworking can handle any type of data. JSON Example shown in example app "Showcase"
- MMNetworking handles the caching to memory (size set to 50MB and configurable from the class file. Can change to disk cache as well), multiple parallel downloads. Maximum number of connections is set to 10 for parallel downloads (this is configurable as well).

#Example App Details (Showcase)

- Showcase shows the MMImageLoader class in action.
- Showcase shows downloaded pictures in a Collection View. And shows the Image details in a UIViewController.
- There is an extra feature for devices with 3D Touch. So please check that out ;)
- Showcase uses https://unsplash.it  API which is free. The API URL is https://unsplash.it/list 
	- The API does not have any pagination so image parallel download limits have been set to 10 as per requirement.
	- Using the API's resizing future so as not to download large size images into the UICollectionView
		- Please note the URL's for the pictures in the Grid View and the Detail View are different. Different URL's for different sizes
		- Caching can be checked after the picture has been loaded once in the Detail View or the Grid View
	- The API JSON data is downloaded using the MMNetworking class, to show that it can be used for JSON as well
- Showcase app is compatible with all iOS Devices with versions iOS 8.0 and up
- Test classes for MMNetworking and MMImageLoader has been included as well

## License

The MIT License (MIT)

Copyright (c) 2016 

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.