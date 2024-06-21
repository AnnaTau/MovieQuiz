import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()

        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let firstPoster = app.images["Poster"]
        firstPoster.waitForExistence(timeout: 5)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["Yes"].tap()
        sleep(3)	
        let secondPoster = app.images["Poster"]
        firstPoster.waitForExistence(timeout: 5)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testNoButton() {
        let firstPoster = app.images["Poster"]
        firstPoster.waitForExistence(timeout: 5)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        app.buttons["No"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        firstPoster.waitForExistence(timeout: 5)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    
    func testQuestionCounter() {
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.label, "1/10")
        app.buttons["Yes"].tap()
        sleep(3)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    
    func testAlert() {
        let yesButton = app.buttons["Yes"]
        let indexLabel = app.staticTexts["Index"]
        for i in 1...10 {
            XCTAssertEqual(indexLabel.label, "\(i)/10")
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts.firstMatch
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alert.buttons.firstMatch.label, "Сыграть ещё раз")
    }
    
    func testAlertDismiss() {
        let yesButton = app.buttons["Yes"]
        let indexLabel = app.staticTexts["Index"]
        for i in 1...10 {
            XCTAssertEqual(indexLabel.label, "\(i)/10")
            app.buttons["Yes"].tap()
            sleep(2)
        }
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        sleep(2)
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")
    }
}
