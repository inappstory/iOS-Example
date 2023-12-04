//
//  CustomCellController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of using a cast cell for a list of stories.
/// 
/// To fully customize a cell, you need to create a `UICollectionViewCell` successor class
/// that implements the `StoryCellProtocol` and pass it to `StoryView.storyCell` before calling the `StoryView.create()`method.
/// Examples of custom cell implementations can be found at the following links ``CustomStoryCell`` and ``FramedStoryCell``
///
/// If you do not use closures to set dimensions and indents, the SDK will calculate the dimensions as follows:
/// * for a horizontal list - equal to the `StoryView` height minus the indents and has the aspect ratio set in the console for the project;
/// * for a vertical list - equal to the width of the `StoryView` list minus the indents from the list edge, the indents between cells and the aspect ratio set in the console for the project;
///
///  - Remark: It is recommended to use closures to customize cell sizes and indents for better control of the list display
///
/// The list of stories is based on `UICollectionView`, by this closure has been named as `UICollectionViewDelegateFlowLayout` methods and is responsible for the same thing.
/// The implementation of closures can be seen in ``StoriesClosureHandler``
/// ```
/// sizeForItem() -> CGSize
/// insetForSection() -> UIEdgeInsets
/// minimumLineSpacingForSection() -> CGFloat
/// minimumInteritemSpacingForSection() -> CGFloat
/// ```
///
///  Documentation on cell replacement can be viewed here [Fully custom cells](https://docs.inappstory.com/sdk-guides/ios/appearance.html#fully-custom-cells)
class CustomCellController: UIViewController
{
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

extension CustomCellController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView()
        storyView.translatesAutoresizingMaskIntoConstraints = false
        /// adding a point from where the reader will be shown
        storyView.target = self
        /// creating a closure handler for `storyView` with cell lyout settings
        /// cell settings are set in the extension ``StoriesClosureHandler/sizeForItem()``
        closureHandler = StoriesClosureHandler(storyView: storyView, withCellLayout: true)
        /// setting a custom cell, you can also change it to ``FramedStoryCell``
        storyView.storyCell = CustomStoryCell()
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
