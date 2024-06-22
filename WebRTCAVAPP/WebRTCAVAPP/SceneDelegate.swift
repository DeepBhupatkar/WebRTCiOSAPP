//
//  SceneDelegate.swift
//  WebRTCAVAPP
//
//  Created by DEEP BHUPATKAR on 22/06/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        // Replace with your initial view controller setup
        let webRTCClient = WebRTCClient(iceServers: Config.default.webRTCIceServers)
        let signalClient = buildSignalingClient()
        let mainViewController = MainViewController()
        mainViewController.configure(signalClient: signalClient, webRTCClient: webRTCClient)
        
        let navigationController = UINavigationController(rootViewController: mainViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        
        window.rootViewController = navigationController
        self.window = window
        window.makeKeyAndVisible()
    }

    private func buildSignalingClient() -> SignalingClient {
        let webSocketProvider: WebSocketProvider
        
        if #available(iOS 13.0, *) {
            webSocketProvider = NativeWebSocket(url: Config.default.signalingServerUrl)
        } else {
            webSocketProvider = StarscreamWebSocket(url: Config.default.signalingServerUrl)
        }
        
        return SignalingClient(webSocket: webSocketProvider)
    }

    // Other methods...
}
