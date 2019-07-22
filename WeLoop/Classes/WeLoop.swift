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
    
    /// The authentication method passed during initialization
    var autoAuthentication: Bool = true
    
    /// The user subdomain used in the api and app urls
    var subdomain: String? = nil
    
    /// The associated WeLoop project. Must be loaded before trying to invoke the Weloop widget.
    /// Its value is loaded during the initialization phase.
    private var project: Project?
    
    /// The current app user. Must be set before the widget can be loaded
    internal var user: User?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    private var authenticationError: Error?
    
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
    ///   - autoAuthentication: Default is true. If set to false, the user will have to provide its own credentials inside the widget.
    ///     if autoAuthentication is set to true, you'll have to provide the logged in user infos by calling `identifyUser`
    ///   - domain: Default to nil. You can specify a domain if your WeLoop urls are customized. For example if your WeLoop App url is `"https://myCompany.getweloop.io/"`
    ///     pass `"myCompany"` for this parameter.
    @objc public static func initialize(apiKey: String, autoAuthentication: Bool = true, subdomain: String? = nil) {
        shared.initialize(apiKey: apiKey, autoAuthentication: autoAuthentication, subdomain: subdomain)
    }
    
    /// Identify the user
    ///
    /// - Important: You **have** to call this method before the SDK can be invoked if you chose autoAuthentication in the `initialize` function
    @objc public static func identifyUser(firstName: String, lastName: String, email: String) {
        let user = User(firstName: firstName, lastName: lastName, email: email)
        shared.user = user
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
    
    func initialize(apiKey: String, autoAuthentication: Bool = true, subdomain: String? = nil) {
        self.apiKey = apiKey
        self.autoAuthentication = autoAuthentication
        self.subdomain = subdomain
        authenticationTask?.cancel()
        authenticationError = nil
        
        let dataTask = authenticate(completionHandler: { (project)  in
            do {
                let project = try project()
                self.project = project
                self.setupInvocation(settings: project.settings)
                try self.initializeWidget()
                self.startNotificationPolling()
                self.delegate?.initializationSuccessful?()
            } catch (let error) {
                self.authenticationError = error
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
        
        guard oldInvocation != method, let project = project else { return }
        
        disableInvocation(method: oldInvocation)
        invocationMethod = method
        setupInvocation(settings: project.settings)
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
        disableInvocation(method: invocationMethod)
        keyWindow.resignKey()
        weLoopViewController?.window.becomeKey()
        weLoopViewController?.window.isHidden = false
        previousWindow = keyWindow
        stopNotificationPolling()
    }
    
    /// Close the widget, and show the previous window instead
    func closeWidget() {
        guard let project = project, let window = previousWindow else { return }
        startNotificationPolling()
        weLoopViewController?.window.resignKey()
        weLoopViewController?.window.isHidden = true
        window.makeKeyAndVisible()
        setupInvocation(settings: project.settings)
    }
    
    private func widgetURL() throws -> URL {
        if let error = authenticationError { throw error }
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        guard let project = project else { throw WeLoopError.authenticationInProgress }
       
        let settingsParams = try project.settings.queryParams()
        
        var urlString = "\(appURL)/\(apiKey)/project/conversations?params=\(settingsParams)"
        if autoAuthentication, let user = user {
            let userParams = try user.queryParams()
            urlString.append("&auto=\(userParams)")
        } else if autoAuthentication && user == nil {
            throw WeLoopError.missingUserIdentification
        }
        return URL(string: urlString)!
    }
    
    // MARK: Notification Badge
    
    @objc private func startNotificationPolling() {
        guard autoAuthentication else { return }
        
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
