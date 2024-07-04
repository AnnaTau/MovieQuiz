import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private lazy var presenter: MovieQuizPresenter = {
        let presenter = MovieQuizPresenter(viewController: self)
        presenter.viewController = self
        return presenter
    }()
    private lazy var alertPresenter: AlertPresenterProtocol = {
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        return alertPresenter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.loadData()
    }
    
    func showNetworkError(message: String) {
        hideLoadingIndicator()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
            self.showLoadingIndicator()
        }
        alertPresenter.show(quiz: model)
    }
    
    // MARK: - Show functions
    func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        resetLayer()
    }
    
    func show(quiz result: QuizResultsViewModel) {
        let message = presenter.makeResultsMessage()
        let alertModel = AlertModel(title: result.title,
                                    message: message,
                                    buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }
            self.presenter.restartGame()
        }
        alertPresenter.show(quiz: alertModel)
    }
    
    // MARK: - Animation functions
    func hideLoadingIndicator() {
        activityIndicator.stopAnimating()
    }
    
    func showLoadingIndicator() {
        activityIndicator.startAnimating()
    }
    
    func lockButtons() {
        yesButton.isEnabled = false
        noButton.isEnabled = false
    }
    
    func unlockButtons() {
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    private func resetLayer() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
    }
    
    // MARK: - Button actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.noButtonClicked()
    }
}
