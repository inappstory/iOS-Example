//
//  UIImageView+CS.swift
//  InAppStoryExample
//

import UIKit

extension UIImageView {
    /// Loading an image into this `UIImageView`
    /// - Parameters:
    ///   - url: image url address
    ///   - mode: method of displaying an image if it does not fit the proportions of the image
    ///   - tag: `UIImageView` identifier to correctly display the image after the download is performed
    ///
    /// This method can be used to assign pictures in `UICollectionView` cells to properly display pictures when the cell is reused.
    /// For correct operation, you can set tag when getting a cell in the `UICollectionViewDelegate.cellForItem(...)` method
    /// equal to the data index for the cell and pass it to `UIImageView`.
    /// This way, `UIImageView` will get the actual tag and when loading an image from the network with a delay,
    /// the picture will be displayed only in the correct cell.
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, withViewTag tag: Int) {
        /// contentMode assignment
        contentMode = mode
        
        /// image loading
        URLSession.shared.dataTask(with: url) { data, response, error in
            /// check if the received data corresponds to the image
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            /// transfer execution to the main thread
            DispatchQueue.main.async() {
                /// if the UIImageView tag matches the one passed in the call, assign to image
                if self.tag == tag {
                    self.image = image
                }
            }
            }.resume()
    }
    
    /// Loading an image into `UIImageView` by `String` link
    /// If the String reference is correct, it is called ``downloadedFrom(url:contentMode:withViewTag:)``
    /// - Parameters:
    ///   - link: url address of the image as `String`
    ///   - mode: method of displaying an image if it does not fit the proportions of the image
    ///   - tag: `UIImageView` identifier to correctly display the image after the download is performed
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, withViewTag tag: Int) {
        /// validation check
        guard let url = URL(string: link) else { return }
        /// calling ``downloadedFrom(url:contentMode:withViewTag:)``
        downloadedFrom(url: url, contentMode: mode, withViewTag: tag)
    }
}

