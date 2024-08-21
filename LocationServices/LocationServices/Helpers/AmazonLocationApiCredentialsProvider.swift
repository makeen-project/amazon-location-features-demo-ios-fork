import Foundation

public class AmazonLocationApiCredentialsProvider: NSObject {
    internal var apiKey: String?
    internal var region: String?
    
    public init(apiKey: String, region: String?) {
        self.apiKey = apiKey
        self.region = region
    }
}
