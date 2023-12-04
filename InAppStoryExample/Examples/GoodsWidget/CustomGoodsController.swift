//
//  CustomGoodsController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using a custom goods widget
///
/// In order to completely redesign the appearance and display logic of the goods widget, it is necessary
/// to create an inheritor class from `CustomGoodsView`, see ``GoodsView`` for an example.
/// To apply its use in the SDK, it must be specified in `InAppStory.shared.goodsView` when 
/// configuring `InAppStory`, before creating a `StoryView` or showing Single/Onboarding.
///
/// When using a custom product widget, there is no need to set the `getGoodsObject` closure,
/// because the SKU list is passed directly to `CustomGoodsView`.
///
/// For more information see: [Full widget override](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#full-widget-override)
class CustomGoodsController: UIViewController {
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
        InAppStory.shared.goodsView = nil
    }
}

extension CustomGoodsController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// set custom GoodsWidget view
        InAppStory.shared.goodsView = GoodsView()
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
