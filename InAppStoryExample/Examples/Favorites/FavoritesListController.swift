//
//  FavoritesListController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of a screen with a list of favorites
///
/// The list of favorites is created similarly to a simple `StoryView` list, but the `favorite: true` parameter must be specified during initialization.
///
/// By default, the favorites list is created as a vertically scrolling grid with three columns. 
/// If you need to change the view of the list, you need to specify the `direction` parameter in `StoryView`.
/// ```
/// storyView.direction = ListDirection.horizontal(rows: 2)
/// ```
///
/// ### ListDirection
/// - `.horizontal(rows: Int)` - for horizontal scrolling with rows, default 2
/// - `.vertical(colums: Int)` - for vertical scrolling with columns, default 3
///
/// - Tip: stories cells from the favorites list are deleted if a stories has been deleted in the reader and the reader has closed. After the reader is closed, the `storyReaderDidClose` closure is called, followed by `storiesDidUpdated(_:_:)`.  To improve the UX, you could add to the `storiesDidUpdated(_:_:)` closure to track the presence of content and if there is none, close the controller with the list.
/// ```
/// storyView.storiesDidUpdated = { [weak self] isContent, type in
///     guard let self = self else { return }
///
///     if !isContent {
///         self.dismiss(animated: true)
///     }
/// }
/// ```
///
/// # Removing favorites by ID
/// To remove a specific story from favorites, you need to call the `InAppStory.shared.removeFromFavorite(with storyID: <String>)` method and specify the ID required for removal.
/// You can get the story ID from the `StoryCellProtocol` cell in the `var storyID: String property! { get set }`.
/// The request to delete stories is sent immediately after the method call and cannot be cancelled.
/// To use the undo deletion function, you must first collect the ID of the story to be deleted and call the delete method for each through a loop.
/// - Attention: The `storiesDidUpdated(_:_:)` closure will be called after each deletion by ID.
///
/// # Removing all favorites
/// To remove all favorite stories, call the `InAppStory.shared.removeAllFavorites()`. This method also has no undo functionality.
/// The `storiesDidUpdated(_:_:)` closure will also be called after deletion.
class FavoritesListController: UIViewController {
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
        /// On this screen, there is no longer a need for `InAppStory` settings since `Settings` was set on the previous screen.
        /// Create and add a list of stories to the screen
        setupStoryView()
    }
}

extension FavoritesListController {
    /// Create and add a list of stories to the screen
    fileprivate func setupStoryView() {
        /// create instance of `StoryView`
        storyView = StoryView(favorite: true)
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
