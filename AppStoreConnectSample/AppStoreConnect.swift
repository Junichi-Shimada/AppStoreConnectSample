//
//  AppStoreConnect.swift
//  SwiftJWTSample
//
//  Created by shimada.junichi on 2021/09/14.
//

import SwiftJWT

struct MyClaims: Claims {
    let iss: String
    let iat: Date
    let exp: Date
    let aud: String
    var scope: [String]? = nil
}

class AppStoreConnect {
    
    private let KEY_ID: String = "**********"
    private let ISSUSER_ID: String = "00000000-0000-0000-0000-000000000000"
    private let privateKeyFilePath = Bundle.main.path(forResource: "AuthKey_**********", ofType: "p8")!
    
    private let timeIntervalSinceNow: TimeInterval = 60 * 20   // 20分
    
    private func createToken(keyId: String, IssuserId: String, privateKeyPath: String) -> String {
        let myHeader = Header(kid: keyId)

        let myClaims = MyClaims(iss: IssuserId,
                                iat: Date(),
                                exp: Date(timeIntervalSinceNow: timeIntervalSinceNow),
                                aud: "appstoreconnect-v1")
//                                scope: ["GET /v1/apps?fields[devices]=udid"])

        var myJWT = JWT(header: myHeader, claims: myClaims)

        let privateKeyPath = URL(fileURLWithPath: privateKeyPath)
        let privateKey: Data = try! Data(contentsOf: privateKeyPath, options: .alwaysMapped)

        let jwtSigner = JWTSigner.es256(privateKey: privateKey)
        let signedJWT = try! myJWT.sign(using: jwtSigner)
        
        return signedJWT
    }
    
    func listDevices(completion: @escaping (_ json: Dictionary<String, Any>) -> ()) {
        let url = URL(string: "https://api.appstoreconnect.apple.com/v1/devices")!
        let token = createToken(keyId: KEY_ID, IssuserId: ISSUSER_ID, privateKeyPath: privateKeyFilePath)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data, let response = response as? HTTPURLResponse else { return }
            if response.statusCode == 200 {
                let obj = try! JSONSerialization.jsonObject(with: data) as! Dictionary<String, Any>
                completion(obj)
            }
        }
        task.resume()
    }
}

extension AppStoreConnect: CustomDebugStringConvertible {
    
    var debugDescription: String {
        return "curl -v -H 'Authorization: Bearer \(createToken(keyId: KEY_ID, IssuserId: ISSUSER_ID, privateKeyPath: privateKeyFilePath))' \"https://api.appstoreconnect.apple.com/v1/devices\""
    }
}
