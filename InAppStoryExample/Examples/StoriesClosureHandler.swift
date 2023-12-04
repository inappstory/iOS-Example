//
//  StoriesClosureHandler.swift
//  InAppStoryExample
//

import Foundation
import InAppStorySDK

///  StoryView closure handling class. It is also possible to
///  implement a class for processing closures from InAppStory.
///  In the examples there is closure processing inside controllers,
///  this option is used to process events affecting the controller itself.
///  For a full list of closures, see [InAppStory closures](https://docs.inappstory.com/sdk-guides/ios/reference.html#inappstory-closures)
///
///  - Remark: Closures were added in addition to delegate methods in version 1.22.0,
///  delegates will be removed in the future, for migration from earlier versions
///  see [Migration to SDK v1.22.0](https://docs.inappstory.com/sdk-guides/ios/migrations.html#migration-to-inappstory-closures-sdk-v1-22-0)

class StoriesClosureHandler {
    /// Initializing the closure handler for StoryView
    /// - Parameters:
    ///   - storyView: list of stories for which tracking is set
    ///   - withCellLayout: whether it is necessary to set closures to handle cell customization in the list of stories
    init(storyView: StoryView, withCellLayout: Bool = false) {
        /// assignment of closure processing methods
        storyView.storiesDidUpdated = storiesDidUpdated
        storyView.onActionWith = onActionWith
        storyView.storyReaderWillShow = storyReaderWillShow
        storyView.storyReaderDidClose = storyReaderDidClose
        
        /// assigning methods to customize cell sizes and indents
        if withCellLayout {
            storyView.sizeForItem = sizeForItem
            storyView.insetForSection = insetForSection
            storyView.minimumLineSpacingForSection = minimumLineSpacingForSection
            storyView.minimumInteritemSpacingForSection = minimumInteritemSpacingForSection
        }
    }
}

extension StoriesClosureHandler {
    /// Closure, is called every time the content in the list is updated
    /// - Parameters:
    ///   - isContent: displays whether the content is present in the list
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storiesDidUpdated(_ isContent: Bool, _ storyType: StoriesType) {
        if isContent {
            switch storyType {
            case .list(let feed):
                print("StoryView has content in feed \(feed ?? "")")
            case .single:
                print("SingleStory has content")
            case .onboarding(let feed):
                print("Onboarding has content in feed \(feed)")
            case .ugcList:
                print("UGC StoryView has content")
            @unknown default:
                break
            }
        } else {
            print("No content")
        }
    }
    
    /// closure, called when a button or SwipeUp event is triggered in the reader
    /// - Parameters:
    ///   - target: the action by which the link was obtained
    ///   - type: type of action that called this method
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### ActionType
    /// - `.button` - push the button in story;
    /// - `.swipe` - swipe up slide in story;
    /// - `.game` - link from Game;
    /// - `.deeplink` - deeplink from cell in story list.
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func onActionWith(_ target: String, _ type: ActionType, _ storyType: StoriesType) {
        if let url = URL(string: target) {
            UIApplication.shared.open(url)
        }
    }
    
    /// closure, is called each time the reader is opened
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func storyReaderWillShow(_ storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader will show from feed \(feed ?? "")")
        case .single:
            print("SingleStory reader will show")
        case .onboarding(let feed):
            print("Onboarding reader will show from feed \(feed)")
        case .ugcList:
            print("UGC reader will show")
        @unknown default:
            break
        }
    }
    
    /// is called each time the reader is closed
    /// - Parameter storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    ///
    /// > Opening a link within a stories leading to another stories also closes the reader and causes this closure.
    /// > There are cases when the reader may not close when trying to open stories, if the given story is already in the list,
    /// > in this case it is simply flipping to the necessary index.
    /// >
    /// > Also the reader will not be closed if there is an attempt to open the game from stories.
    func storyReaderDidClose(_ storyType: StoriesType)
    {
        switch storyType {
        case .list(let feed):
            print("StoryView reader did close to feed \(feed ?? "")")
        case .single:
            print("SingleStory reader did close")
        case .onboarding(let feed):
            print("Onboarding reader did close to feed \(feed)")
        case .ugcList:
            print("UGC reader did close")
        @unknown default:
            break
        }
    }
}

/// These closures affect the location, size, and indentation of cells in the list.
/// They work similarly to UICollectionViewDelegateFlowLayout methods
///
/// - Tag: listCustomzation
extension StoriesClosureHandler {
    /// returns the cell size for the list
    func sizeForItem() -> CGSize {
        return CGSize(width: 120.0, height: 120.0)
    }
    
    /// returns padding from the edges of the list for cells
    func insetForSection() -> UIEdgeInsets {
        return UIEdgeInsets(top: 16.0, left: 16.0, bottom: 16.0, right: 16.0)
    }
    
    /// the spacing between successive rows or columns of a section
    func minimumLineSpacingForSection() -> CGFloat {
        return 16.0
    }
    
    /// the spacing between successive items of a single row or column
    func minimumInteritemSpacingForSection() -> CGFloat {
        return 16.0
    }
}

extension StoriesClosureHandler {
    
    /// Assigning closures for Goods widget processing
    /// - Parameters:
    ///   - storyView: list of stories for which tracking is set
    ///   - withCellLayout: whether it is necessary to set closures to handle cell customization in the list of stories
    func setGoodsClosures(storyView: StoryView, withCellLayout: Bool = false) {
        /// assignment of closure processing methods
        storyView.getGoodsObject = getGoodsObject
        storyView.goodItemSelected = goodItemSelected
        
        /// assigning methods to customize cell sizes and indents
        if withCellLayout {
            InAppStory.shared.goodsSizeForItem = goodsSizeForItem
            InAppStory.shared.goodsInsetForSection = goodsInsetForSection
            InAppStory.shared.goodsMinimumLineSpacingForSection = goodsMinimumLineSpacingForSection
        }
    }
    
    /// Closure, called when need get goods object for GoodsWidget
    /// - Parameters:
    ///   - skus: list of sku for which information is required
    ///   - complete: closure to which it is necessary to pass the list of Goods of objects created by sku list
    ///
    /// > For more about GoodsComplete, [see](https://docs.inappstory.com/sdk-guides/ios/reference.html#goodscomplete)
    /// >
    /// > For more about goods see in [Widget “Goods”](https://docs.inappstory.com/sdk-guides/ios/widget-goods.html#widget-goods)
    func getGoodsObject(_ skus: Array<String>, _ complete: @escaping GoodsComplete) {
        var goodsArray: Array<CustomGoodObject> = []
        
        for sku in skus {
            let goodsObject = CustomGoodObject()
            goodsObject.sku = sku
            
            goodsArray.append(goodsObject)
        }
        
        complete(.success(goodsArray))
    }
    
    /// closure, called when Goods item select in widget list
    /// - Parameters:
    ///   - item: GoodsObject that was selected from the widget
    ///   - storyType: the type of stories that have been opened, depending on the source
    ///
    /// ### StoriesType
    /// - `.list(feed: <String>?)` - type for StoryView, *feed* - id stories list;
    /// - `.single` - type for single story reader;
    /// - `.onboarding(feed: <String>)` - type for onboarding story reader, *feed* - id stories list.
    func goodItemSelected(_ item: GoodsObjectProtocol, _ storyType: StoriesType) {
        let goodsItem = item as! CustomGoodObject
        let sku = goodsItem.sku!
        
        print("GoodsWidget did select item with SKU - \(sku)")
    }
}

/// These closures affect the location, size, and indentation of cells in the goods widget.
/// They work similarly to UICollectionViewDelegateFlowLayout methods
extension StoriesClosureHandler {
    
    /// returns the cell size for the list
    func goodsSizeForItem() -> CGSize {
        return CGSize(width: 130.0, height: 130.0)
    }
    
    /// returns padding from the edges of the list for cells
    func goodsInsetForSection() -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 8.0, bottom: 0.0, right: 8.0)
    }
    
    /// the spacing between successive rows or columns of a section
    func goodsMinimumLineSpacingForSection() -> CGFloat {
        return 8
    }
}
