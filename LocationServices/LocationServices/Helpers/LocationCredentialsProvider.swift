import Foundation
import AwsCommonRuntimeKit

public protocol LocationCredentialsProtocol {
    
}

extension CredentialsProvider: LocationCredentialsProtocol {
    
}

public class LocationCredentialsProvider: LocationCredentialsProtocol {
    private var cognitoProvider: AmazonLocationCognitoCredentialsProvider?
    private var apiProvider: AmazonLocationApiCredentialsProvider?
    private var customCredentialsProvider: CredentialsProvider?
    private var region: String?
    
    public init(region: String, identityPoolId: String){
        self.region = region
        self.cognitoProvider = AmazonLocationCognitoCredentialsProvider(identityPoolId: identityPoolId, region: region)
    }
    
    public init(region: String, apiKey: String){
        self.region = region
        self.apiProvider = AmazonLocationApiCredentialsProvider(apiKey: apiKey, region: region)
    }
    
    public init(credentialsProvider: CredentialsProvider){
        self.customCredentialsProvider = credentialsProvider
    }
    
    public func getCognitoProvider() -> AmazonLocationCognitoCredentialsProvider? {
        return cognitoProvider
    }
    
    public func getApiProvider() -> AmazonLocationApiCredentialsProvider? {
        return apiProvider
    }
    
    public func getCustomCredentialsProvider() -> CredentialsProvider? {
        return customCredentialsProvider
    }
    
    public func getCredentialsProvider() -> LocationCredentialsProtocol? {
        if let cognitoProvider = self.cognitoProvider {
            return cognitoProvider
        } else if let customCredentialsProvider = self.customCredentialsProvider {
            return customCredentialsProvider
        } else {
            return nil
        }
    }
    
    public func getIdentityPoolId() -> String? {
        return self.cognitoProvider?.identityPoolId
    }
    
    public func getAPIKey() -> String? {
        return self.apiProvider?.apiKey
    }
    
    public func getRegion() -> String? {
        return region
    }
    
    internal func setAPIKey(apiKey: String) {
        self.apiProvider?.apiKey = apiKey
    }

    internal func setRegion(region: String) {
        self.apiProvider?.region = region
        self.cognitoProvider?.region = region
        self.region = region
    }
}
