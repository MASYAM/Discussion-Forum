
import Foundation
import UIKit

//MARK: Functions
enum AnswerQueries {
    case setAnswer
    case getAnswer
    case getAnswersCount
    case getAnswers
}

//MARK:
protocol AnswerHandler {
    
    //MARK:
    func getAnswer(answerID: Int)
    func setAnswer(answer: Answer)
    func getAnswersCount(userID: String)
    func getAnswers(pageSize:Int, lastTimestamp: Int, questionID: String)
    
    //MARK:
    func answerHasArrived(answer: Answer)
    func answerCountHasArrived(count: Int)
    func answersHasArrived(answers: [Answer])
    func answerWriteCompleted(answer: Answer)
    func answerServiceHadAnError(query: AnswerQueries, error: String)
}

//MARK:
extension AnswerHandler {
    
    //MARK:
    func answerHasArrived(answer: Answer) {}
    func answerCountHasArrived(count: Int) {}
    func answersHasArrived(answers: [Answer]) {}
    func answerWriteCompleted(answer: Answer) {}
    func answerServiceHadAnError(query: AnswerQueries, error: String) {}
}

//MARK:
extension AnswerHandler {
    
    func getAnswer(answerID: Int) {
        let service = AnswerService()
        service.getAnswer(answerID: answerID, successBlock: { answer in
            self.answerHasArrived(answer: answer)
        }, failBlock: { message in
            self.answerServiceHadAnError(query: .getAnswer, error: message)
        })
    }
    
    func getAnswers(pageSize:Int, lastTimestamp: Int, questionID: String) {
        let service = AnswerService()
        service.getAnswers(pageSize: pageSize, lastTimestamp: lastTimestamp, questionID: questionID, successBlock: { answers in
            self.answersHasArrived(answers: answers)
        }, failBlock: { message in
            self.answerServiceHadAnError(query: .getAnswers, error: message)
        })
    }
    
    func getAnswersCount(userID: String) {
        let service = AnswerService()
        service.getAnswersCount(userID: userID, successBlock: { count in
            self.answerCountHasArrived(count: count)
        }, failBlock: { message in
            self.answerServiceHadAnError(query: .getAnswersCount, error: message)
        })
    }
}

extension AnswerHandler {
    
    func setAnswer(answer: Answer) {
        let service = AnswerService()
        service.setAnswer(answer: answer, successBlock: { answer in
            self.answerWriteCompleted(answer: answer)
        }, failBlock: { message in
            self.answerServiceHadAnError(query: .setAnswer, error: message)
        })
    }
}
