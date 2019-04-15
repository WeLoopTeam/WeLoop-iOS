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
    func initializationSuccessful()
    func failedToLaunch(with error: Error)
}

private let rootURL = "https://staging.getweloop.io/app/plugin/index/#"

public class WeLoop: NSObject {
    
    public weak var delegate: WeLoopDelegate?
    
    /// Position of the floating action button. Change it before the call to `initialize`
    public var preferredButtonPosition: ButtonPosition = .bottomRight
    
    /// The preferred invocation method for the SDK. Must be set using `setInvocationMethod`
    private var invocationMethod: WeLoopInvocation = .manual
  
    /// A reference to the previous controller in the window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    private var previousViewController: UIViewController?
    
    /// A reference to the controller containing the floating action button
    private var fabController: FloatingButtonController?
    
    /// The associated WeLoop project. Must be loaded before trying to invoke the Weloop widget.
    /// Its value is loaded during the initialization phase.
    private var project: Project?
    
    /// The current app user. Must be set before the widget can be loaded
    private var user: User?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    private var authenticationError: Error?
    
    /// The apiKey (or project GUID) passed during initialization
    private var apiKey: String?
    
    /// The authentication method passed during initialization
    private var autoAuthentication: Bool = true
    
    /// A ref to the authentication, to cancel an existing previous task
    private var authenticationTask: URLSessionDataTask?
    
    /// The WeLoop singleton. This instance is not public, all methods are using static functions to keep the API simple
    static let shared = WeLoop()
    
    
    /// Initialize the Weloop SDK
    ///
    /// - Parameters:
    ///   - apiKey: your project Guid
    ///   - autoAuthentication: Default is true. If set to false, the user will have to provide its own credentials inside the widget.
    ///     if autoAuthentication is set to true, you'll have to provide the logged in user infos by calling `identifyUser`
    public static func initialize(apiKey: String, autoAuthentication: Bool = true) {
        
        shared.apiKey = apiKey
        shared.authenticationTask?.cancel()
        shared.authenticationError = nil
        shared.autoAuthentication = autoAuthentication

        let dataTask = authenticate(apiKey: apiKey, autoAuthentication: autoAuthentication, completionHandler: { (project)  in
            do {
                let project = try project()
                shared.project = project
                shared.setupInvocation(settings: project.settings)
            } catch (let error) {
                shared.authenticationError = error
            }
        })
        shared.authenticationTask = dataTask
        dataTask?.resume()
    }
    
    /// Identify the user
    ///
    /// - Important: You **have** to call this method before the SDK can be invoked if you chose autoAuthentication in the `initialize` function
    public static func identifyUser(firstName: String, lastName: String, email: String) {
        let user = User(firstName: firstName, lastName: lastName, email: email)
        shared.user = user
    }
    
    /// Set the method used to invoke the weLoop Widget.
    public static func setInvocationMethod(_ method: WeLoopInvocation) {
        guard method != shared.invocationMethod, let project = shared.project else { return }
        
        shared.disableInvocation(method: shared.invocationMethod)
        shared.invocationMethod = method
        shared.setupInvocation(settings: project.settings)
    }
    
    /// Manually invoke the WeLoop widget.
    public static func invoke() {
        do {
            // Another instance of the widget is already present.
            guard shared.previousViewController == nil else { return }
            
            guard let keyWindow = UIApplication.shared.keyWindow else { throw WeLoopError.windowMissing  }

            let url = try shared.widgetURL()
            let widgetVC = WeLoopViewController()
            widgetVC.url = url
            shared.previousViewController = keyWindow.rootViewController
            UIApplication.shared.keyWindow?.rootViewController = widgetVC
        } catch (let error) {
            print(error)
            shared.delegate?.failedToLaunch(with: error)
        }
    }
    
    /// Close the widget, and show the previous view controller instead
    internal static func close() {
        guard let viewController = WeLoop.shared.previousViewController, let window = UIApplication.shared.keyWindow else { return }
        WeLoop.shared.previousViewController = nil
        window.rootViewController = viewController
    }
    
    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
    }
    
    private func setupInvocation(settings: Settings) {
        switch invocationMethod {
        case .shakeGesture:
            ShakeGestureDetector.shared.startAccelerometers()
            ShakeGestureDetector.shared.delegate = self
        case .fab:
            fabController = FloatingButtonController(position: .bottomRight, settings: settings)
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
    
    private func widgetURL() throws -> URL {
        if let error = authenticationError { throw error }
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        guard let project = project else { throw WeLoopError.authenticationInProgress }
       
        let settingsParams = try project.settings.queryParams()
        
        var urlString = "\(rootURL)/\(apiKey)/project/conversations?params=\(settingsParams)"

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
