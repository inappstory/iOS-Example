//
//  FavoritesController.swift
//  InAppStoryExample
//

import UIKit
import InAppStorySDK

/// Example of how to use favorites
///
/// For the favorites functionality to work, you need:
/// * enable favorites in the console project settings;
/// * enable favorites in sdk via setting the `InAppStory.shared.panelSettings` parameter in SDK;
/// * if necessary, set the icon of the "Favorites" button via the `InAppStory` parameters `favoriteImage` and `favoriteSelectedImag`;
/// * if necessary, create and set a custom favorite cell at `StoryView.favoriteCell`;
/// * create a screen displaying a list of stories that have been added to favorites, see here ``FavoritesListController``;
///
/// - Note: For the favorites functionality to work, it must be enabled in the console and set to true via panelSettings. 
/// If one of the conditions is not met, the favorites will not be displayed on the reader panel.
///
/// # Custom favorites icon
/// The favorite button in the reader can be in two states:
/// * selected - the story is in favorites;
/// * unselected - the story is not in favorites;
///
/// By this, it is necessary to set images for each state.
/// Since the bottom panel with a set of buttons, including favorites, is added when the reader is created, pictures should be set before the reader is attempted.
/// The best solution is to add setting of custom cells at application startup in `AppDelegate`.
/// ```
/// InAppStory.shared.favoriteImage = UIImage(named: "favoriteIcon")
/// InAppStory.shared.favoriteSelectedImag = UIImage(named: "favoriteIcon_selected")
/// ```
///
/// # Custom favorite cell
/// A custom favorite cell must be a class that inherits `UICollectionViewCell` and implements the `FavoriteCellProtocol` protocol.
/// - Note: A favorites cell is an additional list item that allows you to track a user's attempt to go to the favorites screen and does not replace the cells in the list that displays favorites.
///
/// To replace the default favorite cell, you must set your own cell after creating `StoryView` and before calling the `StoryView.create()` method,
/// so that the new cell has time to register with `UICollectionView` and be displayed after the list is loaded.
/// ```
/// let storyView = StoryView(frame: .zero)
/// ...
/// storyView.favoriteCell = CustomFavoriteCell()
/// ...
/// storyView.create()
/// ```
///
/// # Tracking the pressed favorite
/// In order to understand that the user has tapped on a favorite cell, it is necessary to specify the `favoriteCellDidSelect` closure
/// and perform the necessary actions in it, for example, show the controller with the list of favorites.
///
/// For more panel settings, see [Likes, Share, Favorites](https://docs.inappstory.com/sdk-guides/ios/favorites.html#likes-share-favorites)
class FavoritesController: UIViewController {
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

extension FavoritesController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// enable favorite button in reader & showinng favorite cell in the end of list
        InAppStory.shared.panelSettings = PanelSettings(favorites: true)
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
        /// adding a closure that tracks a tap on a favorite cell
        storyView.favoriteCellDidSelect = { [weak self] in
            guard let self = self else { return }
            
            /// present controller with favorites story list ``FavoritesListController``
            let navigationController = UINavigationController(rootViewController: FavoritesListController())
            navigationController.navigationBar.isTranslucent = false
            
            self.present(navigationController, animated: true)
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
