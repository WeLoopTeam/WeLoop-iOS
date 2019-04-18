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
    
    /// The user domain used in the api and app urls
    var domain: String? = nil
    
    /// The associated WeLoop project. Must be loaded before trying to invoke the Weloop widget.
    /// Its value is loaded during the initialization phase.
    private var project: Project?
    
    /// The current app user. Must be set before the widget can be loaded
    private var user: User?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    private var authenticationError: Error?
    
    /// A ref to the authentication, to cancel an existing previous task
    private var authenticationTask: URLSessionDataTask?
    
    // MARK: Preferences

    /// Position of the floating action button. Change it before the call to `initialize`
    var preferredButtonPosition: ButtonPosition = .bottomRight
    
    /// The preferred invocation method for the SDK. Must be set using `setInvocationMethod`
    var invocationMethod: WeLoopInvocation = .manual
  
    // MARK: Object references
    
    /// A reference to the previous controller in the window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    private var previousViewController: UIViewController?
    
    /// A reference to the controller containing the floating action button
    private var fabController: FloatingButtonController?
    
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
    @objc public static func initialize(apiKey: String, autoAuthentication: Bool = true, domain: String? = nil) {
        shared.initialize(apiKey: apiKey, autoAuthentication: autoAuthentication, domain: domain)
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
    
    
    // MARK: - Internal API

    
    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
    }
    
    func initialize(apiKey: String, autoAuthentication: Bool = true, domain: String? = nil) {
        self.apiKey = apiKey
        self.autoAuthentication = autoAuthentication
        self.domain = domain
        authenticationTask?.cancel()
        authenticationError = nil
        
        let dataTask = authenticate(completionHandler: { (project)  in
            do {
                let project = try project()
                self.project = project
                self.setupInvocation(settings: project.settings)
                self.delegate?.initializationSuccessful?()
            } catch (let error) {
                self.authenticationError = error
                self.delegate?.initializationFailed?(with: error)
            }
        })
        authenticationTask = dataTask
        dataTask?.resume()
    }
    
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
            // Another instance of the widget is already present.
            guard previousViewController == nil else { return }
            
            let url = try widgetURL()
            let widgetVC = WeLoopViewController()
            widgetVC.url = url
            try showWidget(viewController: widgetVC)
            
        } catch (let error) {
            print(error)
            delegate?.failedToLaunch?(with: error)
        }
    }
    
    /// Close the widget, and show the previous view controller instead
    func close() {
        guard let viewController = previousViewController, let project = project, let window = UIApplication.shared.keyWindow else { return }
        previousViewController = nil
        window.rootViewController = viewController
        setupInvocation(settings: project.settings)
    }
    
    private func setupInvocation(settings: Settings) {
        switch invocationMethod {
        case .shakeGesture:
            ShakeGestureDetector.shared.startAccelerometers()
            ShakeGestureDetector.shared.delegate = self
        case .fab:
            fabController = FloatingButtonController(position: preferredButtonPosition, settings: settings)
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
            fabController?.tearDown()
            fabController = nil
        default: break
        }
    }
    
    private func showWidget(viewController: WeLoopViewController) throws {
        guard let keyWindow = UIApplication.shared.keyWindow else { throw WeLoopError.windowMissing  }
        
        screenshot = keyWindow.takeScreenshot()
        disableInvocation(method: invocationMethod)
        previousViewController = keyWindow.rootViewController
        UIApplication.shared.keyWindow?.rootViewController = viewController
    }
    
    private func widgetURL() throws -> URL {
        if let error = authenticationError { throw error }
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        guard let project = project else { throw WeLoopError.authenticationInProgress }
       
        let settingsParams = try project.settings.queryParams()
        
        var urlString = "\(appURL())/\(apiKey)/project/conversations?params=\(settingsParams)"

        if autoAuthentication, let user = user {
            let userParams = try user.queryParams()
            urlString.append("&auto=\(userParams)")
        } else if autoAuthentication && user == nil {
            throw WeLoopError.missingUserIdentification
        }
        return URL(string: urlString)!
    }
}

extension WeLoop: ShakeGestureDelegate {
    
    func didReceiveShakeGesture() {
        WeLoop.invoke()
    }
}
