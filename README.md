JGProgressHUD-SwiftUI
---------------

This is a lightweight and easy-to-use SwiftUI wrapper for [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD), giving you access to the large and proven feature set of JGProgressHUD. Supports iOS, macCatalyst and tvOS 14.0+.
<p align="center">
<img src="https://github.com/JonasGessner/JGProgressHUD/raw/master/Examples/Screenshots/Presentation.png" style='height: 100%; width: 100%; object-fit: contain'/>
</p>

[![GitHub license](https://img.shields.io/github/license/JonasGessner/JGProgressHUD-SwiftUI.svg)](https://github.com/JonasGessner/JGProgressHUD-SwiftUI.svg/blob/master/LICENSE.txt)
[![SwiftPM compatible](https://img.shields.io/badge/SwiftPM-compatible-brightgreen.svg)](https://swift.org/package-manager/)
[![Mac Catalyst compatible](https://img.shields.io/badge/Catalyst-compatible-brightgreen.svg)](https://developer.apple.com/documentation/xcode/creating_a_mac_version_of_your_ipad_app/)

Installation
--------------

JGProgressHUD-SwiftUI can only be used with the Swift Package Manager.

In Xcode, use the menu File > Swift Packages > Add Package Dependency... and enter the package URL `https://github.com/JonasGessner/JGProgressHUD-SwiftUI.git`.

Usage
---------------

This package builds on top of the UIKit-based [JGProgressHUD](https://github.com/JonasGessner/JGProgressHUD) and provides a trivial way of showing HUDs in SwiftUI code.

You use the view `JGProgressHUDPresenter` as a canvas, which can display HUDs over its contents. Generally you want to use a single `JGProgressHUDPresenter` view as the root view of your application, such that full screen HUDs can be displayed.

To show a HUD from any contained view, define the environment object of type `JGProgressHUDCoordinator` in your view struct. This object is automatically available in the environment via `JGProgressHUDPresenter`. Call its `showHUD(constructor:handleExistingHUD:)` method, providing a `constructor` closure that returns the HUD to show. The returned HUD will be shown automatically, hence you do not need to call the `show()` method on the HUD. You may already schedule the HUD to disappear using the `dismiss(afterDelay:)` method.

The `handleExistingHUD` closure is only called in case a HUD is already presented. You can, for example, dismiss the current HUD and return `true` to continue showing the new HUD. By returning `false` (default), you prevent the new HUD from being shown.

You may furthermore access, modify or dismiss a HUD that is already presented by accessing the `presentedHUD` property of the `JGProgressHUDCoordinator` environment object. After a HUD dismisses, this property is automatically reset to `nil`.

Example
---------------

Also see the [Example Project](https://github.com/JonasGessner/JGProgressHUD-SwiftUI/tree/main/Example).

 ```swift
 import SwiftUI
 import JGProgressHUD_SwiftUI
  
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


Requirements
------------

- Deployment target of iOS/tvOS/macCatalyst 14.0 or higher.


Detailed Documentation
----------------
Please see the [JGProgressHUD project](https://github.com/JonasGessner/JGProgressHUD) for documentation on JGProgressHUD itself. 

See the doc strings in [JGProgressHUD_SwiftUI.swift](https://github.com/JonasGessner/JGProgressHUD-SwiftUI/blob/main/Sources/JGProgressHUD-SwiftUI/JGProgressHUD_SwiftUI.swift) for more info.

License
---------
MIT License.<br/>
© 2020, Jonas Gessner.

Credits
----------
Created and maintained by Jonas Gessner, © 2020.<br/>
