//
//  ProductsController.swift
//  InAppStoryExample
//
//  Created by StPashik on 27.11.2025.
//

import UIKit
import InAppStorySDK

/// Local runtime cart storage used only inside the host application.
/// Mirrors the SDK-side data structure from `productCartUpdate` / `productCartGetState`.
/// Holds offers and accumulated pricing without requiring SDK mutation.
final class LocalCart {
    var offers: [ProductCartOffer] = []
    var price: String = "0"
    var oldPrice: String? = nil
    var priceCurrency: String = ""
}

/// Starting with SDK version 1.26.0, the Products widget has added
/// functionality that allows you to add products to the host application's s
/// hopping cart directly from stories.
///
/// For more information see [Widget “Products”](https://docs.inappstory.com/sdk-guides/ios/widget-products.html#shopping-cart)
class ProductsController: UIViewController {
    /// Local storage for cart state used only inside the host application.
    /// Story sends offers one by one → we accumulate them here.
    var cart = LocalCart()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        /// Configuring `InAppStory` before use
        setupInAppStory()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        setupInterface()
    }
}

extension ProductsController {
    /// Configuring InAppStory before use
    fileprivate func setupInAppStory() {
        /// setup `InAppStorySDK` for user with ID
        InAppStory.shared.settings = Settings(userID: "")
        /// setting a closure to handle the story update
        InAppStory.shared.storiesDidUpdated = storiesDidUpdated
        /// closure, called when cart updated from Story
        InAppStory.shared.productCartUpdate = productCartUpdate
        /// Story requests open cart
        InAppStory.shared.productCartClicked = productCartClicked
        /// Story asks for cart
        InAppStory.shared.productCartGetState = productCartGetState
    }
    
    /// Creating a button to show a single story when tapped
    fileprivate func setupInterface() {
        let button = UIButton(frame: CGRect(x: 0.0, y: 0.0, width: 150.0, height: 30.0))
        button.setTitle("Show Single Story", for: .normal)
        button.setTitleColor(.black, for: .normal)
        
        button.center = CGPoint(x: view.frame.size.width  / 2,
                                y: view.frame.size.height / 2)
        
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
}

extension ProductsController {
    @objc func buttonAction(sender: UIButton!) {
        /// show singlel story reader with completion
        InAppStory.shared.showStory(with: "", from: self) { show in
            print("Story reader \(show ? "is" : "not") showing")
        }
    }
}

extension ProductsController {
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
            case .list:
                print("StoryView has content")
            case .single:
                print("SingleStory has content")
            case .onboarding:
                print("Onboarding has content")
            case .ugcList:
                print("UGC StoryView has content")
            @unknown default:
                break
            }
        } else {
            print("No content")
        }
    }
    
    /// Called when Story reports a cart update (single offer).
    /// - Parameters:
    ///   - offer: the product that was selected in stories to be added
    ///   - complete: must be called after adding the product to the host application's cart
    ///
    /// - Note: The exact number of items that should be reflected in the cart
    ///   is received in the `productCartUpdate` loop, in the `ProductCartOffer` object.
    ///   You should not add the number of items to what already is in the cart,
    ///   but replace it with the number received from `productCartUpdate`.
    func productCartUpdate(_ offer: ProductCartOffer,
                           _ complete: @escaping (Result<ProductCart, Error>) -> Void) {
        // If cart is empty (fresh), initialize storage
        if cart.offers.isEmpty && cart.price == "0" {
            cart = LocalCart()
        }

        // update or remove item in cart
        if offer.quantity > 0 {
            // if we already have this offer in cart — update it
            if let idx = cart.offers.firstIndex(where: { $0.offerId == offer.offerId }) {
                cart.offers[idx] = offer
            } else {
                // new offer — add
                cart.offers.append(offer)
            }
        } else {
            // quantity == 0 → remove the offer from cart
            cart.offers.removeAll { $0.offerId == offer.offerId }
        }

        // recalculate totals after change
        // total price = sum of (price * quantity) of all items
        let total = cart.offers.reduce(Decimal(0)) { acc, cur in
            acc + (Decimal(string: cur.price ?? "0") ?? 0) * Decimal(cur.quantity)
        }

        // old price (if provided) — sum of (oldPrice * quantity)
        let totalOld = cart.offers.reduce(Decimal(0)) { acc, cur in
            acc + (Decimal(string: cur.oldPrice ?? "0") ?? 0) * Decimal(cur.quantity)
        }

        cart.price = "\(total)"
        cart.oldPrice = cart.offers.isEmpty ? nil : "\(totalOld)"
        // currency — take from first item (or empty if none)
        cart.priceCurrency = cart.offers.first?.currency ?? ""

        // create ProductCart DTO for Story
        let result = ProductCart(
            offers: cart.offers,
            price: cart.price,
            oldPrice: cart.oldPrice,
            priceCurrency: cart.priceCurrency
        )

        // return updated cart state to WebView
        complete(.success(result))
    }

    /// Called when user taps cart in Story
    func productCartClicked() {
        /// close reader before opening native cart
        InAppStory.shared.closeReader { [weak self] in
            guard let self else { return }
            
            print("Cart opened:\n" + cart.offers.map { "\($0.name ?? "Unnamed"): \($0.quantity)" }.joined(separator: "\n"))
        }
    }

    /// closure must pass the cart status in the same way as in the `productCartUpdate` closure
    /// - Parameters:
    ///   - complete: must be called after getting the product from the host application's cart
    func productCartGetState(_ complete: @escaping (Result<ProductCart, Error>) -> Void) {
        complete(.success(ProductCart(offers: cart.offers,
                                      price: cart.price,
                                      oldPrice: cart.oldPrice,
                                      priceCurrency: cart.priceCurrency)))
    }
}
