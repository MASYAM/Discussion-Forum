
import Foundation
import UIKit

//MARK: Functions
enum QuestionQueries {
    case setQuestion
    case getQuestion
    case getQuestionCount
    case getQuestions
}

//MARK:
protocol QuestionHandler {
    
    //MARK:
    func getQuestion(questionID: String, section: String)
    func setQuestion(question: Question)
    func getQuestions(filter: String, pageSize:Int, lastTimestamp: Int)
    
    //MARK:
    func questionHasArrived(question: Question)
    func questionCountHasArrived(count: Int)
    func questionsHasArrived(questions: [Question])
    func questionWriteCompleted(question: Question)
    func questionServiceHadAnError(query: QuestionQueries, error: String)
}

//MARK:
extension QuestionHandler {
    
    //MARK:
    func questionHasArrived(question: Question) {}
    func questionCountHasArrived(count: Int) {}
    func questionsHasArrived(questions: [Question]) {}
    func questionWriteCompleted(question: Question) {}
    func questionServiceHadAnError(query: QuestionQueries, error: String) {}
}

//MARK:
extension QuestionHandler {
    
    func getQuestion(questionID: String, section: String) {
        let service = QuestionService()
        service.getQuestion(questionID: questionID, section: section, successBlock: { question in
            self.questionHasArrived(question: question)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .getQuestion, error: message)
        })
    }
    
    func getQuestions(filter: String, pageSize:Int, lastTimestamp: Int) {
        let service = QuestionService()
        service.getQuestions(filter: filter, pageSize: pageSize, lastTimestamp: lastTimestamp, successBlock: { questions in
            self.questionsHasArrived(questions: questions)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .getQuestions, error: message)
        })
    }
    
    func getQuestionsBy(email: String, pageSize:Int, lastTimestamp: Int) {
        let service = QuestionService()
        service.getQuestionsBy(email: email, pageSize: pageSize, lastTimestamp: lastTimestamp, successBlock: { questions in
            self.questionsHasArrived(questions: questions)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .getQuestions, error: message)
        })
    }
    
    func getQuestions(pageSize:Int, lastTimestamp: Int) {
        let service = QuestionService()
        service.getQuestions(pageSize: pageSize, lastTimestamp: lastTimestamp, successBlock: { questions in
            self.questionsHasArrived(questions: questions)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .getQuestions, error: message)
        })
    }
    
    func getQuestionCount(userID: String) {
        let service = QuestionService()
        service.getQuestionCount(userID: userID, successBlock: { count in
            self.questionCountHasArrived(count: count)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .getQuestionCount, error: message)
        })
    }
}

extension QuestionHandler {
    
    func setQuestion(question: Question) {
        let service = QuestionService()
        service.setQuestion(question: question, successBlock: { question in
            self.questionWriteCompleted(question: question)
        }, failBlock: { message in
            self.questionServiceHadAnError(query: .setQuestion, error: message)
        })
    }
}
