import UIKit

@objc public enum WeLoopInvocation: Int {
    case none = 0
    case shakeGesture = 1
    case fab = 2
}

@objc public protocol WeLoopDelegate {
    
}

private let rootURL = "https://staging.getweloop.io/app/plugin/index/#"

public class WeLoop: NSObject {
    
    internal var invocationMethod: WeLoopInvocation = .none
    
    /// A reference to the previous controller in the window when the widget is invoked. Used to restore
    /// the app's state when the widget is dismissed
    internal var previousViewController: UIViewController?
    
    /// The associated WeLoop project. Must be loaded before trying to invoke the Weloop widget.
    /// Its value is loaded during the initialization phase.
    var project: Project?
    
    /// The current app user. Must be set before the widget can be loaded
    var user: User?
    
    /// A ref to the authentication, to cancel an existing previous task
    private var authenticationTask: URLSessionDataTask?
    
    /// The WeLoop singleton. This instance is not public, all methods are using static functions to keep the API simple
    static let shared = WeLoop()
    
    public static func initialize(apiKey: String) {
        ShakeGestureDetector.shared.startAccelerometers()
        shared.authenticationTask?.cancel()
        let dataTask = authenticate(apiKey: apiKey, completionHandler: { (project)  in
            do {
                shared.project = try project()
            } catch (let error) {
                print(error)
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
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        do {
            
            let url = try shared.widgetURL()
            print(url)
            let widgetVC = WeLoopViewController()
            widgetVC.url = url
            shared.previousViewController = keyWindow.rootViewController
            UIApplication.shared.keyWindow?.rootViewController = widgetVC
        } catch (let error) {
            print(error)
        }
    }
    
    /// Initializer is made private to prevent clients from creating any other instances
    private override init() {
        super.init()
    }
    
    private func widgetURL() throws -> URL {
        guard let project = project, let user = user else {
            throw WeLoopError.requiresAccess
        }
        let settingsParams = try project.settings.queryParams()
        let userParams = try user.queryParams()
        let urlString = "\(rootURL)/\(project.projectId)/project/conversations?params=\(settingsParams)&auto=\(userParams)"
        
        return URL(string: urlString)!
    }
}
