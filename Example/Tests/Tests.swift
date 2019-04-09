import XCTest
@testable import WeLoop

typealias JSON<T> = Dictionary<String, T> where T: Equatable

class Tests: XCTestCase {
    
    func testSettingsDecoding() {
        do {
            let settings = try JSONDecoder().decode(Settings.self, from: settingsData)
            XCTAssertEqual(settings.iconUrl, "")
            XCTAssertEqual(settings.isBlur, false)
            XCTAssertEqual(settings.message, "")
            XCTAssertEqual(settings.position, "right")
            XCTAssertEqual(settings.primaryColor, "#ff5c80")
            XCTAssertEqual(settings.secondaryColor, "#ff5c80")
            XCTAssertEqual(settings.language, "EN")
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testSettingsBase64Encoding() {
        do {
           
            let queryParam = try JSONDecoder().decode(Settings.self, from: settingsData).queryParams()
            try testBase64ObjectsEqual(string1: queryParam, string2: settingsBase64)
            
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testUserEncoding() {
        do {
            let user = try JSONDecoder().decode(User.self, from: userData)
            XCTAssertEqual(user.email, "paseuh.thammavong@weloop.io")
            XCTAssertEqual(user.firstName, "Paseuth")
            XCTAssertEqual(user.lastName, "Thammavong")
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
    }
    
    func testUserBase64Encoding() {
        do {
            
            let queryParam = try JSONDecoder().decode(User.self, from: userData).queryParams()
            try testBase64ObjectsEqual(string1: queryParam, string2: userBase64)
            
        } catch (let error) {
            XCTFail(error.localizedDescription)
        }
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
