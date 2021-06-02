//
//  FavoritesController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/Favorites.md
//

import UIKit
import InAppStorySDK

class FavoritesController: UIViewController
{
    fileprivate var storyView: StoryView!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupInAppStory()

        setupStoryView()
    }

}

extension FavoritesController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        // enable favorite button in reader & showinng favorite cell in the end of list
        InAppStory.shared.favoritePanel = true
    }
    
    fileprivate func setupStoryView()
    {
        // create instance of StoryView
        storyView = StoryView(frame: .zero, favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        // set StoryView delegate
        storyView.delegate = self
        
        self.view.addSubview(storyView)
        
        var allConstraints: [NSLayoutConstraint] = []
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[storyView]-(0)-|",
                                                           options: [.alignAllLeading, .alignAllTrailing],
                                                           metrics: nil,
                                                           views: ["storyView": storyView!])
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(16)-[storyView(180)]",
                                                            options: [.alignAllTop, .alignAllBottom],
                                                            metrics: nil,
                                                            views: ["storyView": storyView!])
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
        
        // running internal StoryView logic
        storyView.create()
    }
}

extension FavoritesController: StoryViewDeleagate
{
    // delegate method, called when the data in the StoryView is updated
    func storyViewUpdated(storyView: StoryView, widgetStories: Array<WidgetStory>?)
    {
        if storyView.isContent {
            print("StoryView has content")
        } else {
            print("No content")
        }
    }
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    func storyView(_ storyView: StoryView, actionWith type: ActionType, for target: String)
    {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow()
    {
        print("StoryView reader will show")
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose()
    {
        print("StoryView reader did close")
    }
    
    // delegate method, called when the favorite cell has been selected
    func favoriteCellDidSelect()
    {
        // present controller with favorites story list
        let navigationController = UINavigationController(rootViewController: FavoritesListController())
        navigationController.navigationBar.isTranslucent = false
        
        present(navigationController, animated: true)
    }
}
