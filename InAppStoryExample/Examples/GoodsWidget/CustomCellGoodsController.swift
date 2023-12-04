//
//  CustomCellGoodsController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of a custom goods object
///
/// Only the parameter defined by the `GoodsObjectProtocol` protocol is implemented in the object
///
/// Since a custom cell is used, you can add any parameters with any types to this object, 
/// SDK will not pay attention to them.
///
/// - Note: Remember to cast `GoodsObjectProtocol` to the type of this object when the SDK 
/// passes it to your cell via the ``CustomGoodCell/setGoodObject(_:)`` method
class CustomGoodObject: NSObject, GoodsObjectProtocol {
    var sku: String!
}

/// Example of using a custom cell in the Goods widget
///
/// Using a custom product cell, is similar to using a custom cell for a list of stories.
///
/// To fully customize a cell, you need to create a `UICollectionViewCell` successor class
/// that implements the `GoodsCellProtocol` and pass it to `InAppStory.shared.goodCell` 
/// before calling the `StoryView.create()` method or showing the Single/Onbosarding reader.
/// Examples of custom cell implementations can be found at the following links ``CustomGoodCell``
///
/// When using a custom cell in the `getGoodsObject` closure, you can create `GoodObject` objects 
/// just like `SimpleGoodsController` or create your own class with any set of parameters,
/// the main thing is that it implements `GoodsObjectProtocol`.
///
/// When implementing a custom cell and creating your own object for the product model, SDK knows 
/// only the SKU of the product itself and in the `goodItemSelected` closure will pass an abstract object
/// with an indication of the implementation of the protocol `GoodsObjectProtocol`. In order to get 
/// access to the fields of your object, it must be greeted to the created in the `getGoodsObject` closure.
///
/// For more information see: [Custom cell](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#custom-cell)
class CustomCellGoodsController: UIViewController {
    /// List of stories
    fileprivate var storyView: StoryView!
    /// Closure handler from `StoryView`
    fileprivate var closureHandler: StoriesClosureHandler!
    
    /// Customizing the appearance of the controller
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
        /// Create and add a list of stories to the screen
        setupStoryView()
    }
    
    deinit {
        InAppStory.shared.goodCell = nil
        InAppStory.shared.goodsDelegateFlowLayout = nil
    }
}

extension CustomCellGoodsController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// set custom GoodsWidget cell realization
        InAppStory.shared.goodCell = CustomGoodCell()
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
        /// creating a closure handler for `storyView`
        closureHandler = StoriesClosureHandler(storyView: storyView)
        /// creating closures for processing the goods widget
        closureHandler.setGoodsClosures(storyView: storyView, withCellLayout: true)
        /// adding a storyView as a subview to the controller
        self.view.addSubview(storyView)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        
        /// running internal `StoryView` logic
        storyView.create()
    }
}
