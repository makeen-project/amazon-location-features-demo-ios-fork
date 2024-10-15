import Foundation
import AWSLocation

public class ApiAuthHelper {

    private static var _sharedInstance: ApiAuthHelper?
    var locationCredentialsProvider: LocationCredentialsProvider?
    var amazonLocationClient: AmazonLocationClient?
    var authHelper: AuthHelper?
    
    static func initialize(apiKey: String, region: String) {
        if _sharedInstance == nil {
            _sharedInstance = ApiAuthHelper()
            _sharedInstance?.authHelper = AuthHelper()
            _sharedInstance?.locationCredentialsProvider = _sharedInstance?.authHelper?.authenticateWithApiKey(apiKey: apiKey, region: region)
        }
    }
    
    static func `default`() -> ApiAuthHelper {
        return _sharedInstance!
    }
}
