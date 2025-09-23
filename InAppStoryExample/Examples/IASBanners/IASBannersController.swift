//
//  IASBannersController.swift
//  InAppStoryExample
//
//  Created by StPashik on 23.09.2025.
//

import UIKit
import InAppStorySDK

/// An example of a simple `IASBannersView` integration. The list from the default feed is displayed.
/// To work correctly, you need to specify *serviceKey* for SDK in ``AppDelegate``.
///
/// For more info, see [Banners place](https://docs.inappstory.com/sdk-guides/ios/banners.html)
class IASBannersController: UIViewController {
    /// View for displaying the list of banners
    fileprivate var bannersView: IASBannersView!
    /// Constraint for the height of the banner list
    fileprivate var bannersHeightConstraint: NSLayoutConstraint!
    /// View for navigating banners using dots
    fileprivate var dotNavigationView: DotNavigationView!
    
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
        setupBannersView()
    }
}

extension IASBannersController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    /// Create and add a list of banners to the screen
    fileprivate func setupBannersView() {
        /// Configuration of banners appearance
        let bannersAppearance: IASBannersAppearance = IASBannersAppearance(shouldLoop: true,
                                                                           sideInset: 16.0,
                                                                           interItemSpacing: 8,
                                                                           cornerRadius: 16.0)
        /// create instance of `StoryView`
        bannersView = IASBannersView(placeID: "default", appearance: bannersAppearance, frame: .zero)
        bannersView.translatesAutoresizingMaskIntoConstraints = false
        /// Setup closures (callbacks) to handle banner events
        setupClosureHandlers()
        /// Adding banners to the view controller
        self.view.addSubview(bannersView)
        
        /// configuring the constants to display the list correctly
        var allConstraints: [NSLayoutConstraint] = []
        /// horizontally - from edge to edge
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bannersView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["bannersView": bannersView!])
        allConstraints += horConstraint
        /// vertically - height 180pt with a 16pt indent at the top
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[bannersView]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["bannersView": bannersView!])
        allConstraints += vertConstraint
        
        /// Height constraint for the banner list
        bannersHeightConstraint = bannersView.heightAnchor.constraint(equalToConstant: 0)
        ///
        allConstraints.append(bannersHeightConstraint)
        
        /// constraints activation
        NSLayoutConstraint.activate(allConstraints)
        ///
        setupDotNavigationView()
        
        /// running internal `bannersView` logic
        bannersView.create()
    }
    
    /// Create dot navigation under banners
    fileprivate func setupDotNavigationView() {
        dotNavigationView = DotNavigationView()
        dotNavigationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dotNavigationView)
        
        NSLayoutConstraint.activate([
            dotNavigationView.topAnchor.constraint(equalTo: bannersView.bottomAnchor, constant: 8),
            dotNavigationView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    /// Setup closures to handle banner events
    fileprivate func setupClosureHandlers() {
        /// Observe content updates of the banner list
        bannersView.bannersDidUpdated = {  [weak self] isContent, count, listHeight in
            guard let self else { return }
            
            if isContent {
                bannersHeightConstraint.constant = listHeight
                dotNavigationView.count = count
                dotNavigationView.isHidden = count < 2
            } else {
                dotNavigationView.isHidden = true
            }
        }
        /// Observe actions in banners (getting url)
        bannersView.onActionWith = { target in
            if let url = URL(string: target) {
                UIApplication.shared.open(url)
            }
        }
        /// Observe banner scroll
        bannersView.bannersDidScroll = { [weak self] index in
            guard let self else { return }
            
            dotNavigationView.selectedIndex = index
        }
        /// Observe taps in dot navigation
        dotNavigationView.onTap = { [weak self] index in
            guard let self else { return }
            
            bannersView.showBannerWith(index: index)
        }
    }
}
