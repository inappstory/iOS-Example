//
//  SharingCell.swift
//  InAppStoryExample
//

import UIKit

class SharingCell: UICollectionViewCell {
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    @IBOutlet var icon: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
