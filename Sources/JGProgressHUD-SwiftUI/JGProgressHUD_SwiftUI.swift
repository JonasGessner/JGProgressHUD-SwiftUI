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
import JGProgressHUD_Private

public struct JGProgressHUDPresenterView<Content: View>: View {
    @StateObject private var coordinator = JGProgressHUDCoordinator()
    
    private var content: () -> Content
    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        ZStack {
            content()
            
            JGProgressHUDPresenter().scaledToFill().allowsHitTesting(coordinator.wantsPresentation)
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
    
    public var wantsPresentation: Bool {
        return constructor != nil
    }
    
    public fileprivate(set) var presentedHUD: JGProgressHUD?
}

fileprivate struct JGProgressHUDPresenter: UIViewRepresentable {
    @EnvironmentObject var constructionCoordinator: JGProgressHUDCoordinator
    
    func makeUIView(context: Context) -> UIView {
        let hud = constructionCoordinator.constructor!()
        
        constructionCoordinator.presentedHUD = hud
        
        hud.show(animated: true)
        
        constructionCoordinator.presentedHUD?.perform(afterDismiss: {
            self.constructionCoordinator.constructor = nil
            constructionCoordinator.presentedHUD = nil
        })
        
        return hud
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
