//
//  PreloaderController.swift
//  InAppStoryExample
//
//  Created by StPashik on 14.04.2022.
//

import UIKit
import InAppStorySDK

class PreloaderController: UIViewController
{
    fileprivate var loadingIndicator: UIActivityIndicatorView!
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

extension PreloaderController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
    }
    
    fileprivate func setupStoryView()
    {
        // create instance of StoryView
        storyView = StoryView()
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
        
        setupPreloader()
    }
    
    fileprivate func setupPreloader()
    {
        // create preloader activity indicator
        loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.large
        loadingIndicator.startAnimating()
        self.view.addSubview(loadingIndicator)
        
        var allConstraints: [NSLayoutConstraint] = []
        let horConstraint = NSLayoutConstraint.constraints(withVisualFormat: "V:[storyView]-(<=1)-[loadingIndicator]",
                                                         options: NSLayoutConstraint.FormatOptions.alignAllCenterX,
                                                         metrics: nil,
                                                         views: ["storyView": storyView!,"loadingIndicator": loadingIndicator!])
                
        allConstraints += horConstraint
        let vertConstraint = NSLayoutConstraint.constraints(withVisualFormat:"H:[superview]-(<=1)-[loadingIndicator]",
                                                     options: NSLayoutConstraint.FormatOptions.alignAllCenterY,
                                                     metrics: nil,
                                                     views: ["storyView": storyView!, "loadingIndicator": loadingIndicator!])
        
        allConstraints += vertConstraint
        NSLayoutConstraint.activate(allConstraints)
    }
}

extension PreloaderController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType)
    {
        guard let currentStoryView = storyView else {
            return
        }
        
        if isContent { //StoryView has content
            loadingIndicator.stopAnimating()
        } else { //StoryView has't content
            loadingIndicator.stopAnimating()
            currentStoryView.isHidden = true
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    // types is .button, .game, .deeplink, .swipe
    func storyReader(actionWith target: String, for type: ActionType, from storyType: StoriesType) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
}
