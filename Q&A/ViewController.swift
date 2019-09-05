//
//  ViewController.swift
//  Q&A
//
//  Created by lawliet on 2019/9/2.
//  Copyright © 2019 lawliet. All rights reserved.
//

import UIKit
import Network
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    @IBOutlet weak var indexLB: UILabel!
    @IBOutlet weak var questionLB: UILabel!
    @IBOutlet var ansButtArr: [UIButton]!
    @IBOutlet weak var scoreLB: UILabel!
    @IBOutlet weak var acitivityView: NVActivityIndicatorView!
    @IBOutlet weak var connectionLB: UILabel!
    
    let monitor = NWPathMonitor()
    
    var questions : [Questions]?
    var index = 0
    var score = 0 {
        willSet{
            scoreLB.text = "Score: \(newValue)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    print("satisfied")
                    self.connectionLB.isHidden = true
                } else {
                    print("else")
                    self.connectionLB.isHidden = false
                }
            }
        }
        monitor.start(queue: DispatchQueue.global())
        
        downLoadQustion()
    }
    
    func downLoadQustion() {
        acitivityView.color = UIColor.red
        acitivityView.type = .pacman
        acitivityView.startAnimating()
        
        for button in ansButtArr{
            button.isEnabled = false
        }
        
        let urlStr = "https://opentdb.com/api.php?amount=10&encode=base64"
        guard let url = URL(string: urlStr) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, res, exrr) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let data = data, let results = try? decoder.decode(Results.self, from: data) {
                self.questions = results.results
                self.setupUI()
                for results in results.results {
                    print(results)
                }
            } else {
                print("error")
            }
        }
        task.resume()
    }
    
    func setupUI() {
        guard let questions = questions else { return }
        DispatchQueue.main.async {
            for button in self.ansButtArr{
                button.isEnabled = true
            }
            let intArr = [0,1,2,3]
            if questions[self.index].incorrect_answers.count > 2 {
                let intRandom = intArr.shuffled()
                var forIntR = 0
                for x in 0...3{
                    if x == 3{
                        let title = questions[self.index].correct_answer.fromBase64()
                        self.ansButtArr[intRandom[x]].setTitle(title, for: .normal)
                    }else {
                        let title = questions[self.index].incorrect_answers[x].fromBase64()
                        self.ansButtArr[intRandom[x]].setTitle(title, for: .normal)
                    }
                    forIntR += 1
                }
                for button in self.ansButtArr{
                    button.isHidden = false
                }
            } else {
                self.ansButtArr[0].setTitle("True", for: .normal)
                self.ansButtArr[1].setTitle("False", for: .normal)
                self.ansButtArr[2].isHidden = true
                self.ansButtArr[3].isHidden = true
            }
            let title = questions[self.index].question.fromBase64()
            self.questionLB.text = title
            self.indexLB.text = "\(self.index + 1)"
            self.index += 1
            self.acitivityView.stopAnimating()
        }
    }
    
    @IBAction func next(_ sender: UIButton) {
        guard let questions = questions else { return }
        let tag = sender.tag
        guard let currentTitle = ansButtArr[tag].currentTitle else { return }
        var message = ""
        if currentTitle == questions[index - 1].correct_answer.fromBase64() {
            score += 10
            message = "Right"
            print("right")
        } else {
            guard let correctAnswer = questions[index - 1].correct_answer.fromBase64() else { return }
            message = "Wrong\nThe correct answer is \(correctAnswer)"
            print("wrong")
        }
        if index == 10{
            message = message + "\nYour score: \(score)"
            alertFunc(title: "", message: message)
        }else {
            alertFunc(title: "", message: message)
        }
    }
    
    func alertFunc(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if index == 10 {
            let restartAction = UIAlertAction(title: "Restart", style: .default) { (_) in
                self.index = 0
                self.score = 0
                self.downLoadQustion()
            }
            
            alertController.addAction(restartAction)
        } else {
            let okAction = UIAlertAction(title: "Next", style: .default) { (_) in
                self.setupUI()
            }
            alertController.addAction(okAction)
        }
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }
}

