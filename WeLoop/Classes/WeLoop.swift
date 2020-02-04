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
}

public class WeLoop: NSObject {

    // MARK: Authentication
    
    /// The apiKey (or project GUID) passed during initialization
    var apiKey: String?
    
    /// The widget settings object return by WeLoop API
    internal var settings: Settings?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    private var configurationError: Error?
    
    /// A ref to the authentication, to cancel an existing previous task
    private var authenticationTask: URLSessionDataTask?
    
    // MARK: Preferences

    /// Position of the floating action button. Change it before the call to `initialize`
    var preferredButtonPosition: ButtonPosition = .bottomRight
    
    /// The preferred invocation method for the SDK. Must be set using `setInvocationMethod`
    var invocationMethod: WeLoopInvocation = .manual
    
    /// The time interval between each notification refresh call. Must be set using `setNotificationRefreshInterval`
    /// This will only be useful is autoAuthentication has been set to true.
    var refreshInterval: TimeInterval = 30.0
  
    // MARK: Object references
    
    /// A reference to the previous window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    private var previousWindow: UIWindow?
    
    /// A reference to the widget with containing the webview
    private var weLoopViewController: WeLoopViewController?
    
    /// A reference to the controller containing the floating action button
    private var fabController: FloatingButtonController?
    
    /// A reference to the polling timer to refresh notifications
    private var notificationRefreshTimer: Timer?
    
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
    
    /// Manually invoke the WeLoop widget.
    @objc public static func invoke() {
        shared.invokeSelector()
    }
    
    /// Set the preferred button position when invoking the SDK with the Floating Action Button (Fab).
    /// You can change this value at any point and the button position will be updated.
    ///
    /// - Parameter position: the desired position for the button
    @objc public static func set(preferredButtonPosition position: ButtonPosition) {
        shared.preferredButtonPosition = position
        shared.fabController?.updatePosition(position)
    }
    
    /// Set the preferred time interval between two calls to refresh the notifications on the weloop project.
    /// You **must** call this before calling `initialize` if you wish to customize this parameter.
    ///
    /// - Parameter position: the desired time elapsed between each notification refresh
    @objc public static func set(notificationRefreshInterval interval: TimeInterval) {
        shared.refreshInterval = interval
    }
    
    // MARK: - Internal API

    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(startNotificationPolling), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(stopNotificationPolling), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func initialize(apiKey: String) {
        self.apiKey = apiKey
        authenticationTask?.cancel()
        configurationError = nil
        
        let dataTask = widgetConfiguration(completionHandler: { (settings)  in
            do {
                let widgetSettings = try settings()
                self.setupInvocation(settings: widgetSettings)
                try self.initializeWidget()
                self.startNotificationPolling()
                self.delegate?.initializationSuccessful?()
            } catch (let error) {
                self.configurationError = error
                self.delegate?.initializationFailed?(with: error)
            }
        })
        authenticationTask = dataTask
        dataTask?.resume()
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
                fabController = FloatingButtonController(position: preferredButtonPosition, settings: settings)
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
        guard let widgetVC = weLoopViewController else { return false }
        return widgetVC.window.isKeyWindow && previousWindow == nil
    }
    
    private func initializeWidget() throws {
        let url = try widgetURL()
        let widgetVC = WeLoopViewController()
        widgetVC.url = url
        self.weLoopViewController = widgetVC
    }
    
    private func showWidget() throws {
        guard let keyWindow = UIApplication.shared.keyWindow else { throw WeLoopError.windowMissing  }
        
        screenshot = keyWindow.takeScreenshot()
        keyWindow.resignKey()
        weLoopViewController?.window.becomeKey()
        weLoopViewController?.window.isHidden = false
        previousWindow = keyWindow
        stopNotificationPolling()
        disableInvocation(method: invocationMethod)
    }
    
    /// Close the widget, and show the previous window instead
    func closeWidget() {
        guard let settings = settings, let window = previousWindow else { return }
        startNotificationPolling()
        weLoopViewController?.window.resignKey()
        weLoopViewController?.window.isHidden = true
        window.makeKeyAndVisible()
        setupInvocation(settings: settings)
    }
    
    private func widgetURL() throws -> URL {
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        return URL(string: "\(appURL)?appGuid=\(apiKey)")!
    }
    
    // MARK: Notification Badge
    
    @objc private func startNotificationPolling() {        
        notificationRefreshTimer?.invalidate()
        notificationRefreshTimer = Timer(timeInterval: refreshInterval, target: self, selector: #selector(refreshNotificationBadge), userInfo: nil, repeats: true)
        RunLoop.main.add(notificationRefreshTimer!, forMode: .default)
    }
    
    @objc private func stopNotificationPolling() {
        notificationRefreshTimer?.invalidate()
        notificationRefreshTimer = nil
    }
    
    @objc func refreshNotificationBadge() {
        refreshNotificationCount { [weak self] (response) in
            do {
                let notification = try response()
                self?.fabController?.setNotificationBadge(hidden: !notification.isNotif)
            } catch let (error) {
                print(error)
            }
        }
    }
}

extension WeLoop: ShakeGestureDelegate {
    
    func didReceiveShakeGesture() {
        WeLoop.invoke()
    }
}
