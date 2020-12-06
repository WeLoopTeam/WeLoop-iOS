//
//  WeLoop.swift
//  WeLoop
//
//  Created by Henry Huck on 04/04/2019.
//


import UIKit

@objc public enum WeLoopInvocation: Int {
    case manual = 0
    case shakeGesture = 1
    case fab = 2
}

@objc public protocol WeLoopDelegate {
    @objc optional func initializationSuccessful()
    @objc optional func initializationFailed(with error: Error)
    @objc optional func failedToLaunch(with error: Error)
    @objc optional func notificationCountUpdated(newCount: Int)
}

public class WeLoop: NSObject {

    // MARK: Authentication
    
    /// The apiKey (or project GUID) passed during initialization
    var apiKey: String?
    
    /// The authentication token generated from the user infos
    var authenticationToken: String?
    
    /// The widget settings object return by WeLoop API
    internal var settings: Settings?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    private var configurationError: Error?
    
    /// A ref to the authentication, to cancel an existing previous task
    private var configurationTask: URLSessionDataTask?
    
    // MARK: Preferences
    
    /// The preferred invocation method for the SDK. Must be set using `setInvocationMethod`
    var invocationMethod: WeLoopInvocation = .manual
    
    /// If set to true, weloop windows are attached to your top most foreground active scene
    var sceneBasedApplication: Bool = false
    
    // MARK: Object references
    
    /// A reference to the previous window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    private var previousWindow: UIWindow?
    
    /// A reference to the widget with containing the webview
    private var weLoopViewController: WeLoopViewController?
    
    /// A reference to the controller containing the floating action button
    private var fabController: FloatingButtonController?
    
    /// A reference to the window used to present the Weloop interface
    private var popupWindow: UIWindow?
    
    /// A screenshot of the window is taken right before invoking the SDK. This is a ref to this screenshot
    var screenshot: UIImage?
    
    weak var delegate: WeLoopDelegate?
    
    /// The WeLoop singleton. This instance is not public, all methods are using static functions to keep the API simple
    static let shared = WeLoop()
    
    
    
    // MARK: - Public API

    
    /// Initialize the Weloop SDK
    ///
    /// - Parameters:
    ///   - apiKey: your project Guid
    @objc public static func initialize(apiKey: String) {
        shared.initialize(apiKey: apiKey)
    }
    
    @objc public static func authenticateUser(user: User) {
        shared.authenticate(user: user)
    }
    
    /// Set a delegate to handle issues when invoking the widget. 
    ///
    /// - Parameter delegate: an object conforming to `WeLoopDelegate`
    @objc public static func set(delegate: WeLoopDelegate) {
        shared.delegate = delegate
    }
    
    /// Set the method used to invoke the weLoop Widget.
    @objc public static func set(invocationMethod method: WeLoopInvocation) {
        shared.set(invocationMethod: method)
    }
    
    @objc public static func set(sceneBasedApplication: Bool) {
        shared.sceneBasedApplication = sceneBasedApplication
    }
    
    /// Manually invoke the WeLoop widget.
    @objc public static func invoke() {
        shared.invokeSelector()
    }
        
    // MARK: - Internal API

    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
    }
        
    func initialize(apiKey: String) {
        self.apiKey = apiKey
        configurationTask?.cancel()
        configurationError = nil
        
        let dataTask = widgetConfiguration(completionHandler: { (settings)  in
            do {
                let widgetSettings = try settings()
                self.settings = widgetSettings
                self.setupInvocation(settings: widgetSettings)
                try self.initializeWidget()
                self.delegate?.initializationSuccessful?()
            } catch (let error) {
                self.configurationError = error
                self.delegate?.initializationFailed?(with: error)
            }
        })
        configurationTask = dataTask
        dataTask?.resume()
    }
    
    func authenticate(user: User) {
        guard let apiKey = apiKey else { return }
        self.authenticationToken = user.generateToken(appUUID: apiKey)
    }
    
    // MARK: Invocation
    
    func set(invocationMethod method: WeLoopInvocation) {
        let oldInvocation = invocationMethod
        invocationMethod = method
        
        guard oldInvocation != method, let settings = settings else { return }
        
        disableInvocation(method: oldInvocation)
        invocationMethod = method
        setupInvocation(settings: settings)
    }

    @objc func invokeSelector() {
        do {
            guard !isShowingWidget else { return }
            try showWidget()
        } catch (let error) {
            delegate?.failedToLaunch?(with: error)
        }
    }
    
    private func setupInvocation(settings: Settings) {
        switch invocationMethod {
        case .shakeGesture:
            ShakeGestureDetector.shared.startAccelerometers()
            ShakeGestureDetector.shared.delegate = self
        case .fab:
            if fabController == nil {
                fabController = FloatingButtonController(settings: settings)
            }
            fabController?.view.isHidden = false
           break
        default: break
        }
    }
    
    private func disableInvocation(method: WeLoopInvocation) {
        switch method {
        case .shakeGesture:
            ShakeGestureDetector.shared.stopAccelerometers()
            ShakeGestureDetector.shared.delegate = nil
        case .fab:
            fabController?.view.isHidden = true
        default: break
        }
    }
    
    // MARK: Widget
    
    var isShowingWidget: Bool {
        return popupWindow?.isKeyWindow ?? false && previousWindow == nil
    }
    
    private func initializeWidget() throws {
        let url = try widgetURL()
        let widgetVC = WeLoopViewController()
        widgetVC.url = url
        // Forces the pre-load of the webview 
        widgetVC.loadViewIfNeeded()
        self.weLoopViewController = widgetVC
        try configurePopupWindow()
    }
    
    private func configurePopupWindow() throws {
        if #available(iOS 13.0, *), self.sceneBasedApplication {
            let scene = UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.first
            guard let windowScene = scene as? UIWindowScene else { throw WeLoopError.windowMissing }
            popupWindow = UIWindow(frame: windowScene.coordinateSpace.bounds)
            popupWindow?.windowScene = windowScene
        } else {
            popupWindow = UIWindow(frame: UIScreen.main.bounds)
        }
        
        popupWindow?.backgroundColor = .clear
        popupWindow?.windowLevel = .statusBar + 1
        popupWindow?.rootViewController = weLoopViewController
    }
    
    private func showWidget() throws {
        guard let keyWindow = UIApplication.shared.keyWindow else { throw WeLoopError.windowMissing  }
        
        screenshot = keyWindow.takeScreenshot()
        keyWindow.resignKey()
        popupWindow?.becomeKey()
        popupWindow?.isHidden = false
        previousWindow = keyWindow
        disableInvocation(method: invocationMethod)
    }
    
    /// Close the widget, and show the previous window instead
    func closeWidget() {
        guard let settings = settings, let window = previousWindow else { return }
        popupWindow?.resignKey()
        popupWindow?.isHidden = true
        window.makeKeyAndVisible()
        setupInvocation(settings: settings)
    }
    
    private func widgetURL() throws -> URL {
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        return URL(string: "\(appURL)?appGuid=\(apiKey)")!
    }
        
    func setNotificationBadge(count: Int) {
        fabController?.setNotificationBadge(count: count)
        delegate?.notificationCountUpdated?(newCount: count)
    }
}

extension WeLoop: ShakeGestureDelegate {
    
    func didReceiveShakeGesture() {
        WeLoop.invoke()
    }
}
