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
    
    @IBOutlet weak var indexLB: UILabel! //題號
    @IBOutlet weak var questionLB: UILabel! //問題label
    @IBOutlet var ansButtArr: [UIButton]! //答案button
    @IBOutlet weak var scoreLB: UILabel! //分數label
    @IBOutlet weak var connectionLB: UILabel! //是否有連線的label
    @IBOutlet weak var acitivityView: NVActivityIndicatorView! //loading 時會出現的icon
    
    let monitor = NWPathMonitor()
    
    var questions : [Questions]?
    var index = 0 //題號
    var score = 0 { //分數
        willSet{
            scoreLB.text = "Score: \(newValue)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        monitorStart() //偵測網路連線
        downLoadQustion() //下載題目
    }
    
    // MARK: setup UI
    
    func setupUI() {
        guard let questions = questions else { return }
        DispatchQueue.main.async {
            for button in self.ansButtArr{ //讀取到問題之後才顯示button & isEnabled = true
                button.isEnabled = true
                button.isHidden = false
            }
            let intArr = [0,1,2,3]
            if questions[self.index].incorrect_answers.count > 2 { //選擇題
                let intRandom = intArr.shuffled()
                var forIntR = 0
                for x in 0...3{
                    if x == 3{
                        let title = questions[self.index].correct_answer.fromBase64() //因為是base64 用frombase64轉成看得懂的
                        self.ansButtArr[intRandom[x]].setTitle(title, for: .normal)
                    }else {
                        let title = questions[self.index].incorrect_answers[x].fromBase64()
                        self.ansButtArr[intRandom[x]].setTitle(title, for: .normal)
                    }
                    forIntR += 1
                }
            } else { //是非題
                self.ansButtArr[0].setTitle("True", for: .normal)
                self.ansButtArr[1].setTitle("False", for: .normal)
                self.ansButtArr[2].isHidden = true
                self.ansButtArr[3].isHidden = true
            }
            let title = questions[self.index].question.fromBase64() //問題
            self.questionLB.text = title
            self.indexLB.text = "\(self.index + 1)" //題號+1
            self.index += 1
            self.acitivityView.stopAnimating() //loading icon 停止
        }
    }
    
    //MARK: Button
    
    @IBAction func next(_ sender: UIButton) { //按了答案button 後
        guard let questions = questions else { return }
        let tag = sender.tag //取得button 的tag
        guard let currentTitle = ansButtArr[tag].currentTitle else { return } //取得所選答案
        var message = ""
        if currentTitle == questions[index - 1].correct_answer.fromBase64() { //答對
            score += 10
            message = "Right"
            print("right")
        } else {
            guard let correctAnswer = questions[index - 1].correct_answer.fromBase64() else { return }
            message = "Wrong\nThe correct answer is \(correctAnswer)" //答錯
            print("wrong")
        }
        if index == 10{ //已經10題了
            message = message + "\nYour score: \(score)"
            alertFunc(title: "", message: message)
        }else {
            alertFunc(title: "", message: message)
        }
    }
    
    // MARK: Service
    
    func monitorStart() { //偵測網路連線
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
    }
    
    func downLoadQustion() { //下載題目
        acitivityView.color = UIColor.red
        acitivityView.type = .pacman
        acitivityView.startAnimating() //loading icon start
        
        for button in ansButtArr{ //每個button 可按
            button.isEnabled = false
        }
        
        let urlStr = "https://opentdb.com/api.php?amount=10&encode=base64"
        guard let url = URL(string: urlStr) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, res, exrr) in
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            if let data = data, let results = try? decoder.decode(Results.self, from: data) {
                self.questions = results.results
                self.setupUI() // 下載完題目後更新UI
                for results in results.results {
                    print(results)
                }
            } else {
                print("error")
            }
        }
        task.resume()
    }
    
    //MARK: Alert
    
    func alertFunc(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if index == 10 { //第10題了
            let restartAction = UIAlertAction(title: "Restart", style: .default) { (_) in
                self.index = 0
                self.score = 0
                self.downLoadQustion() //重新下載題目
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

