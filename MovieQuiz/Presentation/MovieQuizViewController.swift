import UIKit

final class MovieQuizViewController: UIViewController, AlertPresenterDelegate {
    
    // MARK: - IB Outlets
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let presenter = MovieQuizPresenter()
    private var correctAnswers = 0
    private var currentQuestion: QuizQuestion?
    private lazy var questionFactory: QuestionFactoryProtocol = {
        return QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
    }()
    private lazy var alertPresenter: AlertPresenterProtocol = {
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        return alertPresenter
    }()
    private lazy var statisticService: StatisticService = {
        return StatisticServiceImplementation()
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewController = self
        activityIndicator.startAnimating()
        questionFactory.loadData()
    }
    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
        resetLayer()
    }
    
    func showAnswerResult(isCorrect: Bool) {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        if isCorrect {
            correctAnswers += 1
        }
        yesButton.isEnabled = false
        noButton.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
            let currentRecord = "\(statisticService.bestGame.correct)/\(statisticService.bestGame.total)"
            let totalCount = "\(statisticService.gamesCount)"
            let recordTime = statisticService.bestGame.date.dateTimeString
            let accuracy = String(format: "%.2f", statisticService.totalAccuracy)
            let text = """
                Ваш результат: \(correctAnswers)/\(presenter.questionsAmount)
                Количество сыгранных квизов: \(totalCount)
                Рекорд: \(currentRecord) (\(recordTime))
                Средняя точность: \(accuracy)%
                """
            let alertModel = AlertModel(title: "Этот раунд окончен!",
                                        message: text,
                                        buttonText: "Сыграть ещё раз") { [weak self] in
                guard let self = self else { return }
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                self.questionFactory.clearShownMoviesList()
                self.questionFactory.requestNextQuestion()
            }
            alertPresenter.show(quiz: alertModel)
        } else {
            presenter.switchToNextQuestion()
            questionFactory.requestNextQuestion()
            activityIndicator.startAnimating()
        }
        yesButton.isEnabled = true
        noButton.isEnabled = true
    }
    
    private func resetLayer() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0
        imageView.layer.cornerRadius = 20
    }
    
    private func showNetworkError(message: String) {
        activityIndicator.stopAnimating()
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            self.presenter.resetQuestionIndex()
            self.correctAnswers = 0
            self.activityIndicator.startAnimating()
            self.questionFactory.loadData()
        }
        alertPresenter.show(quiz: model)
    }
    
    // MARK: - Button actions
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.yesButtonClicked()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter.currentQuestion = currentQuestion
        presenter.noButtonClicked()
    }
}

// MARK: - QuestionFactoryDelegate
extension MovieQuizViewController: QuestionFactoryDelegate {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else {
            return
        }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.activityIndicator.stopAnimating()
            self.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        activityIndicator.stopAnimating()
        questionFactory.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: any Error) {
        showNetworkError(message: error.localizedDescription)
    }
}
