
import Foundation
import Firebase
import FirebaseDatabase

struct User {
    var id : String = ""
    var firstName : String = ""
    var lastName : String = ""
    var imageURL : String = ""
    var email : String = ""
    var token : String = ""
    
    var fullName : String {
        get {  return firstName + " " + lastName }
    }
    
    func hasValidData() -> Bool {
        return !email.isEmpty
    }
    
    init(snapshot: DataSnapshot) {
        if let value = snapshot.value as? [String: Any] {
            self.id = snapshot.key
            self.firstName = value["firstName"] as? String ?? ""
            self.lastName = value["lastName"] as? String ?? ""
            self.imageURL = value["imageURL"] as? String ?? ""
            self.email = value["email"] as? String ?? ""
            self.token = value["token"] as? String ?? ""
        }
    }
    
    init(credentials: Credential) {
        self.firstName = credentials.firstName
        self.lastName = credentials.lastName
        self.email = credentials.email
    }
}

enum CodingError : String {
    case decodingError = "Error decoding"
    case encondingError = "Error encoding"
}

extension User: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case id = "id"
        case firstName = "firstName"
        case lastName = "lastName"
        case imageURL = "imageURL"
        case email = "email"
        case token = "token"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            id = try container.decode(String.self, forKey: .id)
            firstName = try container.decode(String.self, forKey: .firstName)
            lastName = try container.decode(String.self, forKey: .lastName)
            imageURL =  try container.decode(String.self, forKey: .imageURL)
            email =  try container.decode(String.self, forKey: .email)
            token = try container.decode(String.self, forKey: .token)
        } catch {
            print(CodingError.decodingError)
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(self.id, forKey: .id)
            try container.encode(self.firstName, forKey: .firstName)
            try container.encode(self.lastName, forKey: .lastName)
            try container.encode(self.imageURL, forKey: .imageURL)
            try container.encode(self.email, forKey: .email)
            try container.encode(self.token, forKey: .token)
        } catch {
            print(CodingError.encondingError)
        }
    }
}
