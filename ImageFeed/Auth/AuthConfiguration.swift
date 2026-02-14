import Foundation

enum Constants {
    static let accessKey = "I067v-NoTb1We5tgQIABkEao3syTZZUK4-vKs2uhTWA"
    static let secretKey = "DLNsESSMomF9MM_tD2msiAj8NZ50kwXdloRE1v0kRec"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    static let defaultBaseURL = "https://api.unsplash.com"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static var oauthTokenURL: URL {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            assertionFailure("Invalid OAuth token URL")
            return URL(fileURLWithPath: "/")
        }
        return url
    }
    
    struct AuthConfiguration {
        let accessKey: String
        let secretKey: String
        let redirectURI: String
        let accessScope: String
        let defaultBaseURL: String
        let authURLString: String
        
        init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: String, authURLString: String) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.redirectURI = redirectURI
            self.accessScope = accessScope
            self.defaultBaseURL = defaultBaseURL
            self.authURLString = authURLString
        }
        
        static var standart: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     defaultBaseURL: Constants.defaultBaseURL,
                                     authURLString: Constants.unsplashAuthorizeURLString)
        }
    }

}
