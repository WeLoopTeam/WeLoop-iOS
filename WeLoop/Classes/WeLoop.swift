import UIKit

@objc public enum WeLoopInvocation: Int {
    case none = 0
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
    
    internal var invocationMethod: WeLoopInvocation = .none
    
    /// A reference to the previous controller in the window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    internal var previousViewController: UIViewController?
    
    /// The associated WeLoop project. Must be loaded before trying to invoke the Weloop widget.
    /// Its value is loaded during the initialization phase.
    internal var project: Project?
    
    /// The current app user. Must be set before the widget can be loaded
    internal var user: User?
    
    /// A ref to an error that occurred during the authentication. Will be passed down to the delegate the next time `invoke` is called
    internal var authenticationError: Error?
    
    /// The apiKey (or project GUID) passed during initialization
    internal var apiKey: String?
    
    /// A ref to the authentication, to cancel an existing previous task
    private var authenticationTask: URLSessionDataTask?
    
    /// The WeLoop singleton. This instance is not public, all methods are using static functions to keep the API simple
    static let shared = WeLoop()
    
    public static func initialize(apiKey: String) {
        
        shared.apiKey = apiKey
        shared.authenticationTask?.cancel()
        shared.authenticationError = nil
        shared.setupInvocation()

        let dataTask = authenticate(apiKey: apiKey, completionHandler: { (project)  in
            do {
                shared.project = try project()
            } catch (let error) {
                shared.authenticationError = error
            }
        })
        shared.authenticationTask = dataTask
        dataTask?.resume()
    }
    
    public static func identifyUser(firstName: String, lastName: String, email: String) {
        let user = User(firstName: firstName, lastName: lastName, email: email)
        shared.user = user
    }
    
    /// Set the method used to invoke the weLoop Widget. Set this before the call to initialize.
    public static func setInvocationMethod(_ method: WeLoopInvocation) {
        shared.invocationMethod = method
    }
    
    /// Manually invoke the WeLoop widget.
    public static func invoke() {
        do {
            guard let keyWindow = UIApplication.shared.keyWindow else { throw WeLoopError.windowMissing  }

            let url = try shared.widgetURL()
            let widgetVC = WeLoopViewController()
            widgetVC.url = url
            shared.previousViewController = keyWindow.rootViewController
            UIApplication.shared.keyWindow?.rootViewController = widgetVC
        } catch (let error) {
            shared.delegate?.failedToLaunch(with: error)
        }
    }
    
    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
    }
    
    private func setupInvocation() {
        switch invocationMethod {
        case .shakeGesture:
            ShakeGestureDetector.shared.startAccelerometers()
            ShakeGestureDetector.shared.delegate = self
        case .fab: break
        default: break
        }
    }
    
    private func widgetURL() throws -> URL {
        if let error = authenticationError { throw error }
        guard let apiKey = apiKey else { throw WeLoopError.missingAPIKey }
        guard let user = user else { throw WeLoopError.missingUserIdentification }
        guard let project = project else { throw WeLoopError.authenticationInProgress }
       
        let settingsParams = try project.settings.queryParams()
        let userParams = try user.queryParams()
        let urlString = "\(rootURL)/\(apiKey)/project/conversations?params=\(settingsParams)&auto=\(userParams)"
        return URL(string: urlString)!
    }
}

extension WeLoop: ShakeGestureDelegate {
    
    func didReceiveShakeGesture() {
        WeLoop.invoke()
    }
}
