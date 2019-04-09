//
//  TestData.swift
//  WeLoop_Example
//
//  Created by Henry Huck on 09/04/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation

let settingsData = """
{
    "ProjectId": "1",
    "Setting_IconUrl": "",
    "Setting_IsBlur": false,
    "Setting_Message": "",
    "Setting_Position": "right",
    "Setting_PrimaryColor": "#ff5c80",
    "Setting_SecondaryColor": "#ff5c80",
    "Setting_lang": "EN"
}
""".data(using: .utf8)!

let settingsBase64 = "eyJzZXR0aW5nX1ByaW1hcnlDb2xvciI6IiNmZjVjODAiLCJzZXR0aW5nX1NlY29uZGFyeUNvbG9yIjoiI2ZmNWM4MCIsInNldHRpbmdfSWNvblVybCI6IiIsInNldHRpbmdfUG9zaXRpb24iOiJyaWdodCIsInNldHRpbmdfTWVzc2FnZSI6IiIsInNldHRpbmdfbGFuZyI6IkVOIiwic2V0dGluZ19Jc0JsdXIiOmZhbHNlfQ=="

let userData = """
{
    "email": "paseuh.thammavong@weloop.io",
    "firstName": "Paseuth",
    "lastName": "Thammavong"
}
""".data(using: .utf8)!

let userBase64 = "eyJlbWFpbCI6InBhc2V1aC50aGFtbWF2b25nQHdlbG9vcC5pbyIsImZpcnN0TmFtZSI6IlBhc2V1dGgiLCJsYXN0TmFtZSI6IlRoYW1tYXZvbmcifQ=="
