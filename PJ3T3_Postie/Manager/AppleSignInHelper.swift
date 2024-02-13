//
//  AppleSignInHelper.swift
//  PJ3T3_Postie
//
//  Created by Eunsu JEONG on 2/5/24.
//

import AuthenticationServices
import CryptoKit

final class AppleSignInHelper: NSObject, ObservableObject {
    static let shared = AppleSignInHelper()
    private var nonce = ""
    var cryptoUtils: CryptoUtils?
    
    private override init() { }
    
    func signInWithAppleRequest(_ request: ASAuthorizationOpenIDRequest) {
        self.cryptoUtils = CryptoUtils()
        
        guard let cryptoUtils = cryptoUtils else {
            print(#function, "Failed to ")
            return
        }
        
        nonce = cryptoUtils.randomNonceString
        request.requestedScopes = [.fullName, .email]
        request.nonce = cryptoUtils.nonce
    }
    
    func signInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let user):
            guard let appleIDCredential = user.credential as? ASAuthorizationAppleIDCredential else {
                print("Credential 23")
                return
            }
            
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Error with token 27")
                return
            }
            
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Error with tokenstring 31")
                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                return
            }
            
            guard let fullName = appleIDCredential.fullName else {
                print("Unalbe to get PersonNameComponents: \(appleIDToken.debugDescription)")
                return
            }
            
            let appleUser = AppleUser(token: idTokenString, nonce: nonce, fullName: fullName)
            
            AuthManager.shared.signInwithApple(user: appleUser)
        case .failure(let failure):
            print(failure.localizedDescription)
        }
    }
}
