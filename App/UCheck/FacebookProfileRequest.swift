import Firebase
import FirebaseAuth
import FacebookLogin
import FacebookCore
import FBSDKLoginKit

struct ProfileRequest: GraphRequestProtocol {
    struct Response: GraphResponseProtocol {
        var first_name: String?
        var last_name: String?
        var id: String?
        var email: String?
        var profilePictureUrl: String?
        
        init(rawResponse: Any?) {
            // Decode JSON from rawResponse into other properties here.
            guard let response = rawResponse as? Dictionary<String, Any> else {
                return
            }
            
            if let first_name = response["first_name"] as? String {
                self.first_name = first_name
            }
            
            if let last_name = response["last_name"] as? String {
                self.last_name = last_name
            }
            
            if let id = response["id"] as? String {
                self.id = id
            }
            
            if let email = response["email"] as? String {
                self.email = email
            }
            
            if let picture = response["picture"] as? Dictionary<String, Any> {
                
                if let data = picture["data"] as? Dictionary<String, Any> {
                    if let url = data["url"] as? String {
                        self.profilePictureUrl = url
                    }
                }
            }
        }
    }
    
    var graphPath = "/me"
    var parameters: [String : Any]? = ["fields": "id, first_name, last_name, email, picture"]
    var accessToken = AccessToken.current
    var httpMethod: GraphRequestHTTPMethod = .GET
    var apiVersion: GraphAPIVersion = .defaultVersion
}

