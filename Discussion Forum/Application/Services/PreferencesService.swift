
import Foundation
import Firebase
import FirebaseDatabase
import CodableFirebase

//MARK:
enum PreferencesServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
}

class PreferencesService {
    func getPreferences(successBlock: @escaping (_ preferences: Preferences)->(),
                        failBlock: @escaping (_ error: String)->()) {
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.preferences)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    successBlock(Preferences(snapshot: snapshot))
                } else {
                    let defaultPreferences = Preferences(sections: ["GENERAL", "OTHER"])
                    successBlock(defaultPreferences)
                }
            })
    }
}
