//
//  ContentView.swift
//  JGProgressHUD-SwiftUI-Example
//
//  Created by Jonas Gessner on 20.10.20.
//

import SwiftUI
import JGProgressHUD_SwiftUI

struct FormContent: View {
    @State private var dim = false
    @State var showShadow = false
    @State var vibrancy = false
    @Binding var blockTouches: Bool

    @EnvironmentObject private var hudCoordinator: JGProgressHUDCoordinator
    
    private func showIndeterminate() {
        hudCoordinator.showHUD {
            let hud = JGProgressHUD()
            if dim {
                hud.backgroundColor = UIColor(white: 0, alpha: 0.4)
            }
            if showShadow {
                hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 4, opacity: 0.3)
            }
            hud.vibrancyEnabled = vibrancy
            hud.textLabel.text = "Loading"
            
            hud.dismiss(afterDelay: 2)
            return hud
        }
    }
    
    private func showSuccess() {
        hudCoordinator.showHUD {
            let hud = JGProgressHUD()
            if dim {
                hud.backgroundColor = UIColor(white: 0, alpha: 0.4)
            }
            if showShadow {
                hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 4, opacity: 0.3)
            }
            hud.vibrancyEnabled = vibrancy
            hud.textLabel.text = "Loading"
            
            hud.indicatorView = JGProgressHUDPieIndicatorView()
            
            // Simulate some long running task
            var progress: Float = 0.0
            let timer = Timer(timeInterval: 1 / 60, repeats: true) { timer in
                progress += 0.01
                progress = min(1.0, progress)
                hud.progress = progress
                
                if progress == 1 {
                    timer.invalidate()
                    
                    hud.indicatorView = JGProgressHUDSuccessIndicatorView()
                    hud.textLabel.text = "Success"
                    
                    hud.dismiss(afterDelay: 1)
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            
            return hud
        }
    }
    
    private func showError() {
        hudCoordinator.showHUD {
            let hud = JGProgressHUD()
            if dim {
                hud.backgroundColor = UIColor(white: 0, alpha: 0.4)
            }
            if showShadow {
                hud.shadow = JGProgressHUDShadow(color: .black, offset: .zero, radius: 4, opacity: 0.3)
            }
            hud.vibrancyEnabled = vibrancy
            hud.textLabel.text = "Loading"

            hud.indicatorView = JGProgressHUDRingIndicatorView()
            
            // Simulate some long running task
            var progress: Float = 0.0
            let timer = Timer(timeInterval: 1 / 60, repeats: true) { timer in
                progress += 0.01
                hud.progress = progress
                
                if progress >= 0.6 {
                    timer.invalidate()
                    
                    hud.indicatorView = JGProgressHUDErrorIndicatorView()
                    hud.textLabel.text = "Error"
                    hud.detailTextLabel.text = "Some Info"
                    
                    hud.dismiss(afterDelay: 1)
                }
            }
            RunLoop.main.add(timer, forMode: .common)
            
            return hud
        }
    }
    
    var body: some View {
        Section(header: Text("Options").font(.headline)) {
            Toggle("Block Touches", isOn: $blockTouches)
            Toggle("Dim Background", isOn: $dim)
            Toggle("Shadow", isOn: $showShadow)
            Toggle("Vibrancy Effect", isOn: $vibrancy)
        }
        
        Section {
            Button("Show Indeterminate Progress", action: showIndeterminate)
            Button("Show Success", action: showSuccess)
            Button("Show Error", action: showError)
        }
    }
}

struct ContentView: View {
    @State private var blockTouches = false

    var body: some View {
        JGProgressHUDPresenter(userInteractionOnHUD: blockTouches) {
            Form {
                FormContent(blockTouches: $blockTouches)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
