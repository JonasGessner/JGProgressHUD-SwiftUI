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
 A SwiftUI View used to present JGProgressHUD. Use this view to define the area in which a HUD can be presented. A HUD will be shown over the content of this view. Generally you want this view to be the root view of your app, in order to present a fullscreen HUD.
 To show a HUD, use the environment object of type `JGProgressHUDCoordinator` and set its `constructor` property to a builder that creates the HUD to show. This closure should only create and return the HUD, and it will be shown automatically with an animation. You can already schedule the HUD to be dismissed within this closure.
 
 To update a HUD that is already shown, access the `presentedHUD` property of the `JGProgressHUDCoordinator` environment object.
 
 You may only show one HUD at a time. To check whether a HUD is already visible check the `presentedHUD` property.
 
 You may set whether the HUD captures all user interaction or none at all. The `interactionType` property of `JGProgressHUD` has no effect when using this presenter.
 
 Example:
 ```
 struct NavigationBody: View {
     // This environment object is automatically set by JGProgressHUDPresenter.
     @EnvironmentObject var hudCoordinator: JGProgressHUDCoordinator
 
     var body: some View {
         Button("Press Me") {
             // Simply set the constructor, and return your HUD!
             hudCoordinator.constructor = {
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
    @StateObject private var coordinator = JGProgressHUDCoordinator()
    
    let userInteractionOnHUD: Bool
    
    private var content: () -> Content
    public init(userInteractionOnHUD: Bool = false, @ViewBuilder content: @escaping () -> Content) {
        self.userInteractionOnHUD = userInteractionOnHUD
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
            
            JGProgressHUDHost().allowsHitTesting(coordinator.wantsPresentation && userInteractionOnHUD)
        }.environmentObject(coordinator)
    }
}

public final class JGProgressHUDCoordinator: ObservableObject {
    @Published public var constructor: (() -> JGProgressHUD)? {
        willSet {
            if newValue != nil && presentedHUD != nil {
                print("WARNING: Trying to show JGProgressHUD while another HUD is still being presented by the same presenter. This is not supported. This HUD will not be shown.")
            }
        }
    }
    
    fileprivate var wantsPresentation: Bool {
        return constructor != nil
    }
    
    public fileprivate(set) var presentedHUD: JGProgressHUD?
}

// MARK: - Private

fileprivate struct JGProgressHUDHost: UIViewRepresentable {
    @EnvironmentObject var constructionCoordinator: JGProgressHUDCoordinator
    
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
