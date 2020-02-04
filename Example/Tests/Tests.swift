import XCTest
@testable import WeLoop

typealias JSON<T> = Dictionary<String, T> where T: Equatable

class Tests: XCTestCase {
    
    func testSettingsDecoding() {
        do {
            let settings = try JSONDecoder().decode(Settings.self, from: settingsData)
            XCTAssertEqual(settings.iconUrl, "")
            XCTAssertEqual(settings.message, "")
            XCTAssertEqual(settings.position, "right")
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
