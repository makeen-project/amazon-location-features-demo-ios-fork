import Foundation
import AWSGeoPlaces
import AWSLocation

public class ApiAuthHelper {

    private static var _sharedInstance: ApiAuthHelper?
    var locationCredentialsProvider: LocationCredentialsProvider?
    var amazonLocationClient: AmazonLocationClient?
    var geoPlacesClient: GeoPlacesClient?
    var authHelper: AuthHelper?
    
    
    static func initialise(apiKey: String, region: String) throws {
        if _sharedInstance == nil {
            _sharedInstance = ApiAuthHelper()
            _sharedInstance?.authHelper = AuthHelper()
            _sharedInstance?.locationCredentialsProvider = try _sharedInstance?.authHelper?.authenticateWithApiKey(apiKey: apiKey, region: region)
            _sharedInstance?.amazonLocationClient = _sharedInstance?.authHelper?.getLocationClient()
            _sharedInstance?.geoPlacesClient = _sharedInstance?.authHelper?.getGeoPlacesClient()
        }
    }
    
    static func `default`() -> ApiAuthHelper {
        return _sharedInstance!
    }
}
