//
//  SimpleGoodsController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of simple use of products in stories
///
/// To add goods to stories, you need to add a widget of goods in the console and specify in it a list
/// of SKUs of goods that should be displayed in stories. At the moment InAppStory does not store
/// data about the goods and therefore they must be passed in the `getGoodsObject` closure.
/// To do this, you can use a closure on InAppStory that will be called for all stories regardless of
/// where they are displayed or specify a closure on a specific list. In the closure it is necessary to
/// get data about goods corresponding to the SKU list and pass it to `complete:<GoodsComplete>`.
///
/// - Note: For simple embedding of goods, it is necessary to pass to the complete list of `GoodObject`or inherit from it.
///
/// This list of items will be used to generate a view in the stories. To track the user's interaction with
/// a particular item, it is necessary to specify the `goodItemSelected` closure, which will be called
/// every time the user taps on the item card.
///
/// ## Customization
/// You can change the appearance of the card by using `InAppStory` parameters.
/// To do this, you must set the desired parameters to `InAppStory` after initialization.
/// ```
/// InAppStory.shared.goodsCellMainTextColor: UIColor = .black
/// InAppStory.shared.goodsCellDiscountTextColor: UIColor = .red
/// ```
///
/// The full list of parameters and descriptions can be found here
/// [Customization](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#customization)
///
/// To customize product cell, see ``CustomCellGoodsController``.
///
/// For more information see: [Widget “Goods”](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#widget-goods)
class SimpleGoodsController: UIViewController {
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
}

extension SimpleGoodsController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
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
        
        /// closure to get the list of products by SKU
        /// it is necessary to have a `GoodObject` or inherit from it.
        storyView.getGoodsObject = { SKUs, complete in
            var items: Array<GoodsObjectProtocol> = []
            for sku in SKUs {
                /// goods object creation
                items.append(GoodObject(sku: sku, title: "Title", subtitle: "Description", imageURL: nil, price: "999", oldPrice: "1999"))
            }
            /// transfer of ready list of goods to SDK
            complete(.success(items))
        }
        
        /// closure to track user action
        storyView.goodItemSelected = { item, storyType in
            /// cast `GoodsObjectProtocol` object to the type passed to `getGoodsObject`
            let goodsItem = item as! GoodObject
            /// obtaining SKU from a goods object
            let sku = goodsItem.sku!
            
            print("GoodsWidget did select item with SKU - \(sku)")
        }
        
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
