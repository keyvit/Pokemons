//
//  AppDelegate.swift
//  Pokemons
//
//  Created by Kristina Marchenko on 26.07.2021.
//

import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    private var coordinator: AppCoordinator!
    
    func application(
        _ application: UIApplication,
        willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window
        window.makeKeyAndVisible()
        
        let coordinator = AppCoordinator(navigation: window)
        coordinator.run()
        
        return true
    }
}
