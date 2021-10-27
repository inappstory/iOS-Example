//
//  CustomGoodCell.swift
//  InAppStoryApp
//
//  Created by StPashik on 21.10.2021.
//

import UIKit
import InAppStorySDK

class CustomGoodCell: UICollectionViewCell {

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
        backView.layer.cornerRadius = 16.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = ""
    }
}

extension CustomGoodCell: GoodsCellProtocol
{
    func setGoodObject(_ object: Any!)
    {
        if let sku = object as? String {
            titleLabel.text = sku
        }
    }
}
