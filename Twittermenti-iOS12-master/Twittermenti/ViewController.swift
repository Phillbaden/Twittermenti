//
//  ViewController.swift
//  Twittermenti
//
//  Created by Angela Yu on 17/07/2018.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import UIKit
import SwifteriOS
import CoreML
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sentimentLabel: UILabel!
    
    let tweetCount = 100
    
    let sentimentClassifier = TweetSentimentClassifier()
    
    let swifter = Swifter(consumerKey: "U93jr6cdMt13U9pNQuWrtefdr", consumerSecret: "62b4R0LL7ucbfJtQu0xKk1Ub1Ef0ws3xlZNAh2K8T49bYT6gqE")

    override func viewDidLoad() {
        super.viewDidLoad()
    
        }

    @IBAction func predictPressed(_ sender: Any) {
    
        fetchTweets()
    
    }
    
    func fetchTweets() {
        
        if let searchText = textField.text {
            
            swifter.searchTweet(using: searchText, lang: "en", count: tweetCount, tweetMode: .extended, success: { (results, metadata) in
                
                var tweets = [TweetSentimentClassifierInput]()
                
                for i in 0..<self.tweetCount {
                    
                    if let tweet = results[i]["full_text"].string {
                        let tweetForClassification = TweetSentimentClassifierInput(text: tweet)
                        tweets.append(tweetForClassification)
                    }
                }
                
                self.makePrediction(with: tweets)
                
            }) { (error) in
                print("There was an error with the Twitter API request, \(error)")
            }
            
        }
        
    }
    
    func makePrediction(with tweets:[TweetSentimentClassifierInput]) {
        
        do {
            
            let predictions = try self.sentimentClassifier.predictions(inputs: tweets)
            
            var sentimentScore = 0
            
            for prediction in predictions {
                let sentiment = prediction.label
                
                if sentiment == "Pos" {
                    sentimentScore += 1
                } else if sentiment == "Neg" {
                    sentimentScore -= 1
                }
            }
            
            updateUI(with: sentimentScore)
            
        } catch {
            
            print("There was an error with making a prediction.")
            
        }
        
    }
    
    func updateUI(with sentimentScore: Int) {
        
        if sentimentScore > 20 {
            self.sentimentLabel.text = "😁"
        } else if sentimentScore > 10 {
            self.sentimentLabel.text = "🙂"
        } else if sentimentScore > -5 {
            self.sentimentLabel.text = "😐"
        } else if sentimentScore > -15 {
            self.sentimentLabel.text = "☹️"
        } else if sentimentScore > -25 {
            self.sentimentLabel.text = "😡"
        } else {
            self.sentimentLabel.text = "🤬"
        }
        
    }
    
}

