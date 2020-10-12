
import Foundation
import UIKit

//MARK:
protocol AppNavigable {
    func navigate(to viewController : UIViewController, animated:Bool)
    func navigateBack(from viewController : UIViewController, animated:Bool)
    func navigateHasError(message: String)
}

//MARK: Common
extension AppNavigable where Self: UIViewController {
    func navigate(to viewController : UIViewController, animated:Bool) {}
    func navigateBack(from viewController : UIViewController, animated:Bool) {}
    func navigateHasError(message: String) {}
}

//MARK: Navigation for QuestionsViewController
extension AppNavigable where Self: QuestionsViewController {
    
    func navigateToAnswer(question: Question) {
        let viewController = AnswerViewController.initFromStoryboard() as AnswerViewController
        viewController.question = question
        viewController.delegate = self
        self.navigate(to: viewController, animated: true)
    }
    
    func navigateToNotifications() {
        let viewController = NotificationViewController.initFromStoryboard() as NotificationViewController
        self.navigate(to: viewController, animated: true)
    }
    
    func navigateToAskQuestion(section: Int) {
        let modalViewController = QuestionViewController.initFromStoryboard() as QuestionViewController
        modalViewController.delegate = self
        modalViewController.section = section
        modalViewController.modalPresentationStyle = .overCurrentContext
        modalViewController.modalTransitionStyle = .coverVertical
        present(modalViewController, animated: true, completion:nil)
    }
    
    func navigateToUserProfile(userID: String) {
        let viewController = UserViewController.initFromStoryboard() as UserViewController
        let service = UserService()
        // show preloader
        service.getUserByEmail(email: userID, successBlock: { user in
            viewController.user = user
            self.navigate(to: viewController, animated: true)
        }, failBlock: { message in
            self.navigateHasError(message: message)
        })
    }
}

//MARK: Navigation for AnswerViewController
extension AppNavigable where Self: AnswerViewController {
    func navigateToUserProfile(userID: String) {
        let viewController = UserViewController.initFromStoryboard() as UserViewController
        let service = UserService()
        // show preloader
        service.getUserByEmail(email: userID, successBlock: { user in
            viewController.user = user
            self.navigate(to: viewController, animated: true)
        }, failBlock: { message in
            self.navigateHasError(message: message)
        })
    }
}

//MARK: Navigation for UserViewController
extension AppNavigable where Self: UserViewController {
    func navigateToAnswer(question: Question) {
        let viewController = AnswerViewController.initFromStoryboard() as AnswerViewController
        viewController.question = question
        viewController.delegate = self
        self.navigate(to: viewController, animated: true)
    }
    func navigateToUserProfile(userID: String) {
        let viewController = UserViewController.initFromStoryboard() as UserViewController
        let service = UserService()
        // show preloader
        service.getUserByEmail(email: userID, successBlock: { user in
            viewController.user = user
            self.navigate(to: viewController, animated: true)
        }, failBlock: { message in
            self.navigateHasError(message: message)
        })
    }
}

//MARK: Navigation for UserViewController
extension AppNavigable where Self: NotificationViewController {
    
    func navigateToAnswer(from notification: UserNotification) {
        let viewController = AnswerViewController.initFromStoryboard() as AnswerViewController
        let service = QuestionService()
        service.getQuestion(questionID: notification.questionID,
                            section: notification.section, successBlock: { question in
                                viewController.question = question
                                self.navigate(to: viewController, animated: true)
        }, failBlock: { error in
            self.navigateHasError(message: error)
        })
    }
    
    func navigateToUserProfile(userID: String) {
        let viewController = UserViewController.initFromStoryboard() as UserViewController
        let service = UserService()
        service.getUserByEmail(email: userID, successBlock: { user in
            viewController.user = user
            self.navigate(to: viewController, animated: true)
        }, failBlock: { message in
            self.navigateHasError(message: message)
        })
    }
}
