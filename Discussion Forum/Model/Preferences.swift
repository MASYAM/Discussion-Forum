
import Foundation
import Firebase
import FirebaseDatabase

//MARK:
struct Preferences {
    
    var sections = [String]()
    
    init(sections: [String]) {
        self.sections = sections
    }
    
    init(snapshot: DataSnapshot) {
        if let _ = snapshot.value as? [String: Any] {
            if snapshot.hasChild("sections") {
                var retValue = [String]()
                let sections = snapshot.childSnapshot(forPath: "sections")
                if let snapshot = sections.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let value = snap.value as? [String:Any] {
                            retValue.append(value["name"] as? String ?? "")
                        }
                    }
                    self.sections = retValue
                }
            }
        }
    }
}

extension Preferences: Codable {
    
    private enum CodingKeys : String, CodingKey {
        case sections = "sections"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            sections = try container.decode([String].self, forKey: .sections)
        } catch {
            print(CodingError.decodingError)
        }
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        do {
            try container.encode(self.sections, forKey: .sections)
        } catch {
            print(CodingError.encondingError)
        }
    }
}

