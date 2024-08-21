import Foundation
import AWSLocation
import AwsCommonRuntimeKit

public class CognitoAuthHelper {

    private static var _sharedInstance: CognitoAuthHelper?
    var locationCredentialsProvider: LocationCredentialsProvider?
    var amazonLocationClient: AmazonLocationClient?
    var authHelper: AuthHelper?
    
    private init() {
    }
    
    static func initialise(identityPoolId: String) async throws {
        _sharedInstance = CognitoAuthHelper()
        _sharedInstance?.authHelper = AuthHelper()
        _sharedInstance?.locationCredentialsProvider = try await _sharedInstance?.authHelper?.authenticateWithCognitoIdentityPool(identityPoolId: identityPoolId)
        _sharedInstance?.amazonLocationClient = _sharedInstance?.authHelper?.getLocationClient()
        try await _sharedInstance?.amazonLocationClient?.initialiseLocationClient()
    }
    
    static func initialise(credentialsProvider: CredentialsProvider, region: String) async throws {
        _sharedInstance = CognitoAuthHelper()
        _sharedInstance?.authHelper = AuthHelper()
        _sharedInstance?.locationCredentialsProvider = try await _sharedInstance?.authHelper?.authenticateWithCredentialsProvider(credentialsProvider: credentialsProvider, region: region)
        _sharedInstance?.amazonLocationClient = _sharedInstance?.authHelper?.getLocationClient()
        try await _sharedInstance?.amazonLocationClient?.initialiseLocationClient()
    }
    
    static func `default`() -> CognitoAuthHelper {
        return _sharedInstance!
    }
}
