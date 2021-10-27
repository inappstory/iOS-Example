//
//  CustomCellGoodsController.swift
//  InAppStoryExample
//
//  Created by StPashik on 27.10.2021.
//

import UIKit
import InAppStorySDK

struct CustomGoodObject {
    var sku: String!
}

class CustomCellGoodsController: UIViewController
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
    
    deinit {
        InAppStory.shared.goodCell = nil
        InAppStory.shared.goodsDelegateFlowLayout = nil
    }
}

extension CustomCellGoodsController
{
    fileprivate func setupInAppStory()
    {
        // setup InAppStorySDK for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        
        // set custom GoodsWidget cell realization
        InAppStory.shared.goodCell = CustomGoodCell()
        
        // set delegate for layout of GoodsWidget list
        InAppStory.shared.goodsDelegateFlowLayout = self
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

extension CustomCellGoodsController: InAppStoryDelegate
{
    // delegate method, called when the data is updated
    func storiesDidUpdated(isContent: Bool, from storyType: StoriesType, storyView: StoryView?)
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
            default:
                break
            }
        } else {
            print("No content")
        }
    }
    
    // delegate method, called when a button or SwipeUp event is triggered in the reader
    func storyReader(actionWith target: String, for type: ActionType, from storyType: StoriesType, storyView: StoryView?) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    // delegate method, called when the reader will show
    func storyReaderWillShow(with storyType: StoriesType, storyView: StoryView?)
    {
        switch storyType {
        case .list:
            print("StoryView reader will show")
        case .single:
            print("SingleStory reader will show")
        case .onboarding:
            print("Onboarding reader will show")
        default:
            break
        }
    }
    
    // delegate method, called when the reader did close
    func storyReaderDidClose(with storyType: StoriesType, storyView: StoryView?)
    {
        switch storyType {
        case .list:
            print("StoryView reader did close")
        case .single:
            print("SingleStory reader did close")
        case .onboarding:
            print("Onboarding reader did close")
        default:
            break
        }
    }
    
    // delegate method, called when need get goods object for GoodsWidget
    func getGoodsObject(with skus: Array<String>, complete: @escaping GoodsComplete)
    {
        var goodsArray: Array<CustomGoodObject> = []
        
        for sku in skus {
            let goodsObject = CustomGoodObject(sku: sku)
            
            goodsArray.append(goodsObject)
        }
        
        complete(.success(goodsArray))
    }
    
    // delegate method, called when Goods item select in widget list
    func goodItemSelected(_ item: Any, with storyType: StoriesType, storyView: StoryView?)
    {
        let goodsItem = item as! CustomGoodObject
        let sku = goodsItem.sku!
        
        print("GoodsWidget did select item with SKU - \(sku)")
    }
}

// methods of delegate, like in UICollectionViewDelegateFlowLayout
extension CustomCellGoodsController: GoodsDelegateFlowLayout
{
    func sizeForItem() -> CGSize
    {
        return CGSize(width: 130.0, height: 130.0)
    }
    
    func insetForSection() -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
    }
    
    func minimumLineSpacingForSection() -> CGFloat
    {
        return 8
    }
}
