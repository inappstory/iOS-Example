//
//  UIImageView+CS.swift
//  InAppStoryExample
//

import UIKit

extension UIImageView
{
    func downloadedFrom(url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFit, withViewTag tag: Int)
    {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                if self.tag == tag {
                    self.image = image
                }
            }
            }.resume()
    }
    
    func downloadedFrom(link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit, withViewTag tag: Int)
    {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode, withViewTag: tag)
    }
}

