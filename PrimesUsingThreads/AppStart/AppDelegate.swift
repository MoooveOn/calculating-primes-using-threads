//
//  AppDelegate.swift
//  Empty_RIB
//
//  Created by Pavel Selivanov on 2/22/20.
//  Copyright © 2020 Pavel Selivanov. All rights reserved.
//

import UIKit
import RIBs

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    internal var window: UIWindow?
    private var appComponent: AppComponent?
    private var launchRouter: LaunchRouting!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let window = UIWindow(frame: UIScreen.main.bounds)
        self.window = window

        let appComponent = AppComponent(application: application, launchOptions: launchOptions)
        self.appComponent = appComponent
        appComponent.setup()

        launchRouter = RootBuilder(dependency: appComponent).build()
        launchRouter.launchFromWindow(window)

        return true
    }
}
