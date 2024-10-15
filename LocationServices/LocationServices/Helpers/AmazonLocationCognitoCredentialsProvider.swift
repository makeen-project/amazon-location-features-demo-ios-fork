import Foundation

public class AmazonLocationCognitoCredentialsProvider: LocationCredentialsProtocol {
    internal var identityPoolId: String?
    internal var region: String?
    private var cognitoCredentials: CognitoCredentials?
    private var refreshTimer: Timer?

    public init(identityPoolId: String, region: String?) {
        self.identityPoolId = identityPoolId
        self.region = region
        
        // Start a background timer to refresh credentials every 59 minutes
        startCredentialRefreshTimer()
    }
    
    deinit {
        // Invalidate the timer when the instance is deallocated
        refreshTimer?.invalidate()
    }
    
    public func getCognitoCredentials() -> CognitoCredentials? {
        if self.cognitoCredentials != nil && self.cognitoCredentials!.expiration! > Date() {
            return self.cognitoCredentials
        }
        else if let cognitoCredentialsString = KeyChainHelper.get(key: .cognitoCredentials), let cognitoCredentials = CognitoCredentials.decodeCognitoCredentials(jsonString: cognitoCredentialsString) {
            self.cognitoCredentials = cognitoCredentials
            return self.cognitoCredentials
        }
        return self.cognitoCredentials
    }
    
    public func refreshCognitoCredentialsIfExpired() async throws {
        if let savedCredentials = getCognitoCredentials(), savedCredentials.expiration! > Date() {
            cognitoCredentials = savedCredentials
        } else {
            try? await refreshCognitoCredentials()
        }
    }
    
    public func refreshCognitoCredentials() async throws {
        if let identityPoolId = self.identityPoolId, let region = self.region, let cognitoCredentials = try await CognitoCredentialsProvider.generateCognitoCredentials(identityPoolId: identityPoolId, region: region) {
           setCognitoCredentials(cognitoCredentials: cognitoCredentials)
        }
    }
    
    private func setCognitoCredentials(cognitoCredentials: CognitoCredentials) {
        self.cognitoCredentials = cognitoCredentials
        KeyChainHelper.save(value: CognitoCredentials.encodeCognitoCredentials(credential: cognitoCredentials)!, key: .cognitoCredentials)
    }
    
    // Start a repeating timer that calls refreshCognitoCredentialsIfExpired every 59 minutes
    private func startCredentialRefreshTimer() {
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 59 * 60, repeats: true) { [weak self] _ in
            Task {
                do {
                    try await self?.refreshCognitoCredentialsIfExpired()
                    try await AWSLoginService.default().refreshLoginIfExpired()
                    
                } catch {
                    print("Error refreshing Cognito credentials: \(error)")
                }
            }
        }
    }

}
