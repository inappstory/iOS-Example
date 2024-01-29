//
//  GoodsView.swift
//  InAppStoryApp
//

import UIKit
import InAppStorySDK

/// Example of a custom goods widget
///
/// This class is inherited from `CustomGoodsView` in order to be able to receive and pass this within the SDK.
///
/// - Note: When using a fully custom product widget, the SDK knows nothing about what's going on inside
/// the widget, for the widget to interact with the SDK, you need to call these methods in overridden methods of the superclass.
///
/// Since this implementation of the custom goods widget does not use the `getGoodsObject` closure to get 
/// the goods objects, it is necessary to use its own format for the goods objects, as well as to get and create them
/// in the ``setSKUItems(_:)`` method. At the time of receiving and processing the data, you can display the preloader.
///
/// After the user has tapped on the item, it is necessary to call the method `super.goodsItemClick(with sku: String)`
/// in order for SDK to collect data for statistics about the selected item, otherwise, the statistics displayed in the console will be incorrect.
///
/// For correct operation of the reader, from which this widget was opened, if you need to close the widget, 
/// you need to call the method `super.close()`. This will let the reader know that the widget is closed and
/// it can resume playing the story logic inside itself.
///
/// For more information see: [Full widget override](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#full-widget-override)
class GoodsView: CustomGoodsView {
    /// Widget initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        /// The ``handleSingleTap(_:)`` will be called when you click on the widget's obverse.
        let singleFingerTap = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        self.addGestureRecognizer(singleFingerTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Transmit a list of SKU's of products when this widget is added to the screen.
    /// Here you need to get data about the items and display them, for example, in `UICollectionView`
    override func setSKUItems(_ items: Array<String>) {
        /// It is necessary to call this method on the superclass, for the correct operation of the SDK logic
        super.setSKUItems(items)
        
        print("Get widget skus - \(items.joined(separator: ","))")
    }
    
    /// Send the dimensions of the reader from where the widget was displayed when you added it to the screen.
    /// This method may be needed on tablets, as the story reader is shown in a modal window and
    /// if there will be a need to adjust the list of products to its size.
    override func setReaderFrame(_ frame: CGRect) {
        /// It is necessary to call this method on the superclass, for the correct operation of the SDK logic
        super.setReaderFrame(frame)
        
        print("Reader frame = CGRect(x: \(frame.origin.x), y: \(frame.origin.y), width: \(frame.width), height: \(frame.height)")
    }
    
    /// Close widget by single tap on the screen
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer?) {
        /// To close the widget in the reader, you need to call the `super.close()` method.
        /// This method closes only the goods widget, the reader remains.
        /// To close the reader, you must call `InAppStory.shared.closeReader()`
        super.close()
    }
}
