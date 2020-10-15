//
//  JGProgressHUD_SwiftUI.swift
//  JGProgressHUD
//
//  Created by Jonas Gessner on 14.10.20.
//  Copyright © 2020 Jonas Gessner. All rights reserved.
//

import Foundation
import SwiftUI
@_exported import JGProgressHUD

/**
 A SwiftUI View used to present instance of JGProgressHUD. Use this view to define the area in which a HUD can be presented. HUDs will be shown over the content of this view. Generally you want this view to be the root view of your app, such that you can present a fullscreen HUDs.
 To show a HUD, use the environment object of type `JGProgressHUDCoordinator` and call its `showHUD(constructor:handleExistingHUD:)` method, supplying a constructor closure that creates the HUD to show. This closure should only create and return the HUD, which will automatically be shown subsequently. You can already schedule the HUD to be dismissed after a delay within the constructor closure.
 
 To update a HUD that is already shown, access the `presentedHUD` property of the `JGProgressHUDCoordinator` environment object.
 
 You may only show one HUD at a time. To check whether a HUD is already visible check the `presentedHUD` property of `JGProgressHUDCoordinator`. If you call `showHUD()` while a HUD is already presented, you may handle this case in the `handleExistingHUD` closure.
 
 You may set whether the HUD captures all user interaction or none at all. The `interactionType` property of `JGProgressHUD` has no effect when using this presenter.
 
 # Example
 ```
 struct NavigationBody: View {
     // This environment object is automatically set by JGProgressHUDPresenter.
     @EnvironmentObject var hudCoordinator: JGProgressHUDCoordinator
 
     var body: some View {
         Button("Press Me") {
             // Simply call showHUD and return your HUD!
             hudCoordinator.showHUD {
                 let hud = JGProgressHUD()
                 hud.textLabel.text = "Hello!"
                 hud.dismiss(afterDelay: 3)
 
                 return hud
             }
         }
     }
 }
 
 struct ContentView: View {
     var body: some View {
         // This presenter can present a fullscreen HUD.
         JGProgressHUDPresenter {
             NavigationView {
                 NavigationBody()
             }
         }
     }
 }
```
*/
public struct JGProgressHUDPresenter<Content: View>: View {
    private let coordinator = JGProgressHUDCoordinator()
    
    let userInteractionOnHUD: Bool
    
    private var content: () -> Content
    public init(userInteractionOnHUD: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.userInteractionOnHUD = userInteractionOnHUD
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
            
            JGProgressHUDHost(constructionCoordinator: coordinator, trigger: coordinator.trigger) .allowsHitTesting(coordinator.wantsPresentation && userInteractionOnHUD)
        }.environmentObject(coordinator)
    }
}

/// An instance of this class will be in the environment inside the content of a `JGProgressHUDPresenter`. Acces this instance via the environment and call the `showHUD()` method to show a HUD. To modify a presented HUD, access the `presentedHUD` property. This property is automatically set to `nil` when a presented HUD disappears. Another HUD can be shown subsequently. See `JGProgressHUDPresenter` for more info.
// Implementation note. This class is an ObservableObject so that it can become an environment object. It never actually sends any change events, because no view except JGProgressHUDHost are interested in changes on this object. By not sending change events on this object, the number of re-evaluated views may drastically shrink. JGProgressHUDHost gets notified of changes via the private trigger object.
public final class JGProgressHUDCoordinator: ObservableObject {
    fileprivate var constructor: (() -> JGProgressHUD)? {
        willSet {
            trigger.triggerChange()
        }
    }
    
    /**
     Shows a HUD created by the closure `constructor`. Return an initialized and ready to be displayed HUD from this closure. You do not need to manually show the HUD, it will be shown automatically.
     
     A HUD may already be presented. If this is the case, you are given a chance to handle this scenario using the `handleExistingHUD` closure. Return `true` from this closure to proceed with presenting the new HUD. For example, you may hide the existing HUD within `handleExistingHUD`. Return `false` (default) to not present the new HUD.
     */
    public func showHUD(constructor: @escaping () -> JGProgressHUD, handleExistingHUD: (JGProgressHUD) -> Bool = { _ in return false }) {
        if let existing = presentedHUD {
            guard handleExistingHUD(existing) else {
#if DEBUG
                print("[DEBUG] A HUD is already presented, not showing the new HUD.")
#endif
                return
            }
            
            presentedHUD = nil
        }
        
        self.constructor = constructor
    }
    
    /// The HUD that is currently displayed, if any.
    public fileprivate(set) var presentedHUD: JGProgressHUD?
    
    // MARK: Private
    
    fileprivate let trigger = PrivateObservable()
    
    fileprivate final class PrivateObservable: ObservableObject {
        func triggerChange() {
            objectWillChange.send()
        }
    }
    
    fileprivate var wantsPresentation: Bool {
        return constructor != nil
    }
}

// MARK: - Private

fileprivate struct JGProgressHUDHost: UIViewRepresentable {
    let constructionCoordinator: JGProgressHUDCoordinator
    @ObservedObject fileprivate var trigger: JGProgressHUDCoordinator.PrivateObservable
    
    func makeUIView(context: Context) -> UIView {
        return UIView()
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        guard let constructor = constructionCoordinator.constructor else { return }
        guard constructionCoordinator.presentedHUD == nil else { return }
        
        let hud = constructor()
        
        constructionCoordinator.presentedHUD = hud
        
        hud.show(in: uiView)
        
        hud.perform(afterDismiss: {
            constructionCoordinator.constructor = nil
            constructionCoordinator.presentedHUD = nil
        })
    }
}
