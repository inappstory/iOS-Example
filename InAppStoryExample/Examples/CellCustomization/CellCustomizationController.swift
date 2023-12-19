//
//  CellCustomizationController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Simple customize a `StoryView` list cell using `InAppStory` parameters and closures.
/// 
/// Customization through properties changes the appearance of a standard cell with fixed rounding and border thickness.
/// Sizes also apply to the favorites cell. To change the appearance, shape and behavior of a cell, you need to create your own cell.
/// You can see an example of how to create your own cell in ``CustomCellController``
///
/// If you use only `InAppStory` parameters to change the cell view, its size is automatically calculated:
/// * for a horizontal list - equal to the `StoryView` height minus the indents and has the aspect ratio set in the console for the project;
/// * for a vertical list - equal to the width of the `StoryView` list minus the indents from the list edge, the indents between cells and the aspect ratio set in the console for the project;
///
/// For your own control over the size and indentation of cells in a list, you should use closures.
/// The list of stories is based on `UICollectionView`, by this closure has been named as `UICollectionViewDelegateFlowLayout` methods and is responsible for the same thing.
/// The implementation of closures can be seen in ``StoriesClosureHandler``
/// ```
/// sizeForItem() -> CGSize
/// insetForSection() -> UIEdgeInsets
/// minimumLineSpacingForSection() -> CGFloat
/// minimumInteritemSpacingForSection() -> CGFloat
/// ```
///
/// A full list of parameters for cell customization can be found here  [List customization](https://docs.inappstory.com/sdk-guides/ios/appearance.html#list-customization)
class CellCustomizationController: UIViewController
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

extension CellCustomizationController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// quality of cover images in cells
        InAppStory.shared.coverQuality = .high
        /// show title in cell
        InAppStory.shared.showCellTitle = true
        /// color of cell border
        InAppStory.shared.cellBorderColor = .purple
        /// cell title font
        InAppStory.shared.cellFont = UIFont.systemFont(ofSize: 12.0)
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
