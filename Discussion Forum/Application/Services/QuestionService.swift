
import Foundation
import Firebase
import FirebaseDatabase
import CodableFirebase

//MARK:
enum QuestionServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
}

class QuestionService {
    
    func getQuestion(questionID: String,
                     section: String,
                     successBlock: @escaping (_ question: Question)->(),
                     failBlock: @escaping (_ error: String)->()) {
        if !questionID.isEmpty
            && !section.isEmpty {
            let ref = Database.database().reference()
            ref.child(FirebaseConstants.questionsBy)
                .child(section)
                .child(questionID)
                .observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        successBlock(Question(snapshot: snapshot))
                    } else { failBlock(QuestionServiceError.emptySnapshot.rawValue) }
                })
        }
        else {
            failBlock(QuestionServiceError.emptyParameter.rawValue)
        }
        
    }
    
    func getQuestions(pageSize:Int,
                      lastTimestamp: Int,
                      successBlock: @escaping (_ questions: [Question])->(),
                      failBlock: @escaping (_ error: String)->()) {
        
        var retValue = [Question]()
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.questions)
            .queryOrdered(byChild: "timestamp")
            .queryStarting(atValue: lastTimestamp - 1)
            .queryLimited(toFirst: UInt(pageSize))
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot { retValue.append(Question(snapshot: snap)) }
                        successBlock(retValue)
                    }
                } else { failBlock(QuestionServiceError.emptySnapshot.rawValue) }
                
            })
    }
    
    func getQuestions(filter: String,
                      pageSize:Int,
                      lastTimestamp: Int,
                      successBlock: @escaping (_ questions: [Question])->(),
                      failBlock: @escaping (_ error: String)->()) {

        var retValue = [Question]()
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.questionsBy)
            .child(filter.uppercased())
            .queryOrdered(byChild: "timestamp")
            .queryStarting(atValue: lastTimestamp - 1)
            .queryLimited(toFirst: UInt(pageSize))
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot { retValue.append(Question(snapshot: snap)) }
                        successBlock(retValue)
                    }
                } else { failBlock(QuestionServiceError.emptySnapshot.rawValue) }
                
        })
    }
    
    // Question array per User
    func getQuestionsBy(email: String,
                        pageSize:Int,
                        lastTimestamp: Int,
                        successBlock: @escaping (_ questions: [Question])->(),
                        failBlock: @escaping (_ error: String)->()) {
        
        var retValue = [Question]()
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.questions)
            .queryOrdered(byChild: "email")
            .queryEqual(toValue: email)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot { retValue.append(Question(snapshot: snap)) }
                        successBlock(retValue)
                    }
                } else { failBlock(QuestionServiceError.emptySnapshot.rawValue) }
                
            })
    }
    
    // Number of Questions per User
    func getQuestionCount(userID:String,
                          successBlock: @escaping (_ count: Int)->(),
                          failBlock: @escaping (_ error: String)->()) {
        
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.questions)
            .queryOrdered(byChild: "email")
            .queryEqual(toValue: userID)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    successBlock(Int(snapshot.childrenCount))
                } else { failBlock(QuestionServiceError.emptySnapshot.rawValue) }
                
            })
    }
}

extension QuestionService {
    func setQuestion(question:Question,
                     successBlock: @escaping (_ question: Question)->(),
                     failBlock: @escaping (_ error: String)->()) {
        if question.hasValidData() {
            
            let ref = Database.database().reference()
                .child(FirebaseConstants.questionsBy)
                .child("\(question.section.uppercased())")
                .childByAutoId()
            
            let mData: NSDictionary = ["title" : question.title,
                                       "email" : question.email ,
                                       "timestamp" : question.timestamp,
                                       "sender" : question.sender,
                                       "senderID" : question.senderID,
                                       "section" : question.section,
                                       "answerCount" : question.answerCount,
                                       "description" : question.description]
            ref.setValue(mData)
            
            if let childAutoId = ref.key {
                let ref = Database.database().reference().child(FirebaseConstants.questions).child(childAutoId)
                ref.setValue(mData)
            }
            
            successBlock(question)
        }
        else {
            failBlock(QuestionServiceError.emptyParameter.rawValue)
        }
    }
}
