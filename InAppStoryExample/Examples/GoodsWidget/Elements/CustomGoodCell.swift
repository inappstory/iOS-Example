//
//  CustomGoodCell.swift
//  InAppStoryApp
//

import UIKit
import InAppStorySDK

/// Example of a custom cell for a goods widget
///
/// It is necessary that the cell class inherits from `UICollectionViewCell` and implements the `GoodsCellProtocol` protocol.
///
/// The example shows how to create a cell with an *.xib* file. In order to use programmatic cell layout it is necessary to return the value `nil` in the variable ``nib``
/// ```
/// static var nib: UINib? { return nil }
/// ```
///
/// - Remark: To display the cell contents correctly, remember to clear the fields in the method ``prepareForReuse()``
///
/// For more information see: [Custom cell](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#custom-cell)
class CustomGoodCell: UICollectionViewCell {
    /// reuse identifier for registering a cell in `UICollectionView`
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    /// nib of cell, if cell created in .xib file
    static var nib: UINib? {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    /// cell title in which the SKU will be displayed
    @IBOutlet weak var titleLabel: UILabel!
    /// cell background with rounded edges
    @IBOutlet weak var backView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = ""
        backView.layer.cornerRadius = 16.0
    }

    /// Called by the collection view before the instance is returned from the reuse queue.
    override func prepareForReuse() {
        super.prepareForReuse()
        
        /// Cleaning the cell before use
        /// If you do not clear the image or video, when you reuse the cell,
        /// the image that was loaded the first time and the content will be duplicated.
        titleLabel.text = ""
    }
}

/// Implementation of the `GoodsCellProtocol protocol`
extension CustomGoodCell: GoodsCellProtocol {
    
    /// Receipt of the object of goods
    /// - Parameter object: object implementing `GoodsObjectProtocol`
    ///
    /// If a product object from the SDK was used, you must cast `object` to the `GoodObject`
    /// type before using it to customize the cell
    /// ```
    /// if let goodObject = object as? GoodObject {
    ///     titleLabel.text = goodObject.title
    /// }
    /// ```
    ///
    /// This example uses a simple custom product object ``CustomGoodObject`` with no parameters 
    /// other than the implemented `.sku` and no need to cast the resulting object to the `CustomGoodObject` type.
    func setGoodObject(_ object: GoodsObjectProtocol!) {
        /// Setting the SKU of the product as the cell title
        titleLabel.text = object.sku
    }
}
