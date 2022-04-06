//
//  TagsPlaceholdersController.swift
//  InAppStoryExample
//
//  For more information see: https://github.com/inappstory/ios-sdk/blob/main/Samples/Tags.md
//

import UIKit
import InAppStorySDK

class TagsPlaceholdersController: UIViewController
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

extension TagsPlaceholdersController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID & tags
        InAppStory.shared.settings = Settings(userID: "", tags: ["one", "two"])
        // add tags after set settings
        InAppStory.shared.addTags(["three", "four"])
        // remove tags if needed
        InAppStory.shared.removeTags(["three"])
        
        // if the StoryView has already been created, after adding or removing tags, you need to refresh the StoryView
        // storyView.refresh()
        
        // set replacing placeholders list
        InAppStory.shared.placeholders = ["one" : "Replace one", "two" : "Replace two"]
    }
    
    fileprivate func setupStoryView()
    {        
        // create instance of StoryView
        storyView = StoryView(frame: .zero, favorite: false)
        storyView.translatesAutoresizingMaskIntoConstraints = false
        // adding a point from where the reader will be shown
        storyView.target = self
        // set StoryView delegate
        storyView.storiesDelegate = self
        
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

extension TagsPlaceholdersController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType)
    {
        guard let currentStoryView = storyView else {
            return
        }
        
        if currentStoryView.isContent {
            switch storyType {
            case .list:
                print("StoryView has content")
            case .single:
                print("SingleStory has content")
            case .onboarding:
                print("Onboarding has content")
            }
        } else {
            print("No content")
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    // types is .button, .game, .deeplink, .swipe
    func storyReader(actionWith target: String, for type: ActionType, from storyType: StoriesType)
    {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow(with storyType: StoriesType)
    {
        switch storyType {
        case .list:
            print("StoryView reader will show")
        case .single:
            print("SingleStory reader will show")
        case .onboarding:
            print("Onboarding reader will show")
        }
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose(with storyType: StoriesType)
    {
        switch storyType {
        case .list:
            print("StoryView reader did close")
        case .single:
            print("SingleStory reader did close")
        case .onboarding:
            print("Onboarding reader did close")
        }
    }
    
    // delegate method, called when the favorite cell has been selected
    func favoriteCellDidSelect()
    {
        // InAppStory.shared.favoritePanel is false, favorites cell is not displayed
        // method called only the method is called only when the favorite cell is selected
        // see FavoritesController.swift
    }
}
