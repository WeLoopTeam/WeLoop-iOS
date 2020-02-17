import XCTest
@testable import WeLoop

typealias JSON<T> = Dictionary<String, T> where T: Equatable

let settingsData = """
{
    "Widget_Icon": "",
    "Widget_Message": "",
    "Widget_Position": "right",
    "Widget_PrimaryColor": "#ff5c80",
    "Language": "EN"
}
""".data(using: .utf8)!

class Tests: XCTestCase {
    
    func testSettingsDecoding() {
        do {
            let settings = try JSONDecoder().decode(Settings.self, from: settingsData)
            XCTAssertEqual(settings.iconUrl, "")
            XCTAssertEqual(settings.message, "")
            XCTAssertEqual(settings.position, .bottomRight)
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testAESEncryption() {
        let user = User(id: "1", email: "test1@yopmail.com", firstName: "test1", lastName: "test2")
        let token = user.generateToken(appUUID: "273295d0-4686-11ea-ae43-83e39941d033")
        XCTAssertNotNil(token)
    }
    
    private func testBase64ObjectsEqual(string1: String, string2: String) throws {
        
        let json = try JSONSerialization.jsonObject(with: Data(base64Encoded: string1)!, options: [])
        let json2 = try JSONSerialization.jsonObject(with: Data(base64Encoded: string2)!, options: [])
        
        guard let dict1 = json as? JSON<AnyHashable>, let dict2 = json2 as? JSON<AnyHashable> else {
            XCTFail("Failed to cast json")
            return
        }
        
        XCTAssertEqual(dict1, dict2)
    }
    
}
