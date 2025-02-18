//
//  SSLBypass.swift
//  SingingHue2
//
//  Created by Everett Wilson on 2/17/25.
//

import Foundation

// MARK: - SSLBypass for Testing Only
class SSLBypass: NSObject, URLSessionDelegate {
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }
        let credential = URLCredential(trust: serverTrust)
        completionHandler(.useCredential, credential)
    }
}
