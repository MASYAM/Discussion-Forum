
import Foundation
import Firebase
import FirebaseDatabase
import CodableFirebase

//MARK:
enum AnswerServiceError : String {
    case emptySnapshot = "SNAPSHOT_NOT_FOUND"
    case emptyParameter = "INCORRECT_PARAMETER"
}

class AnswerService {
    
    func getAnswer(answerID: Int,
                   successBlock: @escaping (_ answer: Answer)->(),
                   failBlock: @escaping (_ error: String)->()) {
        
    }
    
    func getAnswers(pageSize:Int,
                    lastTimestamp: Int,
                    questionID: String,
                    successBlock: @escaping (_ answers: [Answer])->(),
                    failBlock: @escaping (_ error: String)->()) {
        
        var retValue = [Answer]()
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.answers)
            .queryOrdered(byChild: "questionID")
            .queryEqual(toValue: questionID)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot { retValue.append(Answer(snapshot: snap)) }
                        successBlock(retValue)
                    }
                } else { failBlock(AnswerServiceError.emptySnapshot.rawValue) }
                
            })
    }
    
    func getAnswersCount(userID:String,
                         successBlock: @escaping (_ count: Int)->(),
                         failBlock: @escaping (_ error: String)->()) {
        
        let ref = Database.database().reference()
        ref.child(FirebaseConstants.answers)
            .queryOrdered(byChild: "email")
            .queryEqual(toValue: userID)
            .observeSingleEvent(of: .value, with: { snapshot in
                if snapshot.exists() {
                    successBlock(Int(snapshot.childrenCount))
                } else { failBlock(AnswerServiceError.emptySnapshot.rawValue) }
                
            })
    }
    
}

extension AnswerService {
    func setAnswer(answer : Answer,
                   successBlock: @escaping (_ question: Answer)->(),
                   failBlock: @escaping (_ error: String)->()) {
        if answer.hasValidData() {
            let ref = Database.database().reference()
            let mData: NSDictionary = ["email" : answer.email,
                                       "questionID" : answer.questionID,
                                       "receiverID" : answer.receiverID,
                                       "senderID" : answer.senderID,
                                       "sender" : answer.sender,
                                       "timestamp" : answer.timestamp,
                                       "section" : answer.section,
                                       "comment" : answer.comment]
            
            ref.child(FirebaseConstants.answers).childByAutoId().setValue(mData)
            
            let questionsByCount = ref.child(FirebaseConstants.questionsBy)
                .child(answer.section.uppercased())
                .child("\(answer.questionID)").child("answerCount")
            
            questionsByCount.observeSingleEvent(of: .value, with: { snapshot in
                let count = snapshot.value as? Int ?? 0
                questionsByCount.setValue(count+1)
            })
            
            let questionsCount = ref.child(FirebaseConstants.questions)
                .child("\(answer.questionID)").child("answerCount")
            
            questionsCount.observeSingleEvent(of: .value, with: { snapshot in
                let count = snapshot.value as? Int ?? 0
                questionsCount.setValue(count+1)
            })
            
            successBlock(answer)
        }
        else {
            failBlock(AnswerServiceError.emptyParameter.rawValue)
        }
    }
}
