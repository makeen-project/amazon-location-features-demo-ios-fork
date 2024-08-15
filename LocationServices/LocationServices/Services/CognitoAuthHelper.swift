import Foundation
import AmazonLocationiOSAuthSDK
import AWSLocation

public class CognitoAuthHelper {

    private static var _sharedInstance: CognitoAuthHelper?
    var locationCredentialsProvider: LocationCredentialsProvider?
    var amazonLocationClient: AmazonLocationClient?
    var authHelper: AuthHelper?
    
    private init() {
    }
    
    static func initialize(identityPoolId: String) async throws {
        if _sharedInstance == nil {
            _sharedInstance = CognitoAuthHelper()
            _sharedInstance?.authHelper = AuthHelper()
            _sharedInstance?.locationCredentialsProvider = try await _sharedInstance?.authHelper?.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId)
            _sharedInstance?.amazonLocationClient = _sharedInstance?.authHelper?.getLocationClient()
            try await _sharedInstance?.amazonLocationClient?.initialiseLocationClient()
        }
    }
    
    static func `default`() -> CognitoAuthHelper {
        return _sharedInstance!
    }
}
