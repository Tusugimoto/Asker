//
//  AskQuestionViewController.swift
//  Asker
//
//  Created by 杉本翼 on 2020/02/10.
//  Copyright © 2020 Tsubasa Sugimoto. All rights reserved.
//
import UIKit
import RealmSwift
import AVFoundation

class AskQuestionViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    //質問の番号を表示するラベル
    @IBOutlet weak var questionNumberLabel: UILabel!
    //質問を表示するラベル
    @IBOutlet weak var questionLabel: UILabel!
    //タイマーカウントを表示するラベル
    @IBOutlet weak var timerLabel: UILabel!
    
    //ゴミ箱ボタン
    @IBOutlet weak var trashButton: UIButton!
    //録音ボタン
    @IBOutlet weak var recordButton: UIButton!
    //再生ボタン
    @IBOutlet weak var playButton: UIButton!
    //スターボタン
    @IBOutlet weak var starButton: UIButton!
    //nextボタン
    @IBOutlet weak var nextButton: UIButton!
    //backボタン
    @IBOutlet weak var backButton: UIButton!
    
    //録音関連
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    var isRecording = false
    var isPlaying = false
    
    //ストップウォッチ関連
    var myTimer = Timer()
    var TimerDisplayed:float_t = 0
    
    //ランダムにときに質問を入れる変数
    var shuffled: [Question] = []
    
    //質問数のカウント
    var count:Int = 0
    
    
    
    
    //recordボタンがタップされたとき
    @IBAction func recordButton(_ sender: Any) {
        recordButtonFunc()
    }
    
    //playボタンがタップされたとき
    @IBAction func playButton(_ sender: Any) {
        playButtonFunc()
    }
    
    //nextボタンがタップされたとき
    @IBAction func nextButton(_ sender: Any) {
        nextButtonFunc()
    }
    
    //backボタンがタップされたとき
    @IBAction func backButton(_ sender: Any) {
        backButtonFunc()
    }
    
    //質問が変わったとき（back or next）
    @IBAction func questionChange(_ sender: Any) {
        questionChangeFunc()
    }
    
    //スターボタンがタップされたとき
    @IBAction func starButton(_ sender: Any) {
        starButtonFunc()
    }
    
    //trashボタンがタップされたとき
    @IBAction func trashButton(_ sender: Any) {
        trashButtonFunc()
    }
    
    
    
    
    func recordButtonFunc(){
        //録音中ではないとき（録音開始）
        if !isRecording{
            //録音中、nextボタンとbackボタンを無効化
            nextButton.isEnabled = false
            backButton.isEnabled = false
            
            //録音処理
            let session = AVAudioSession.sharedInstance()
            try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try! session.setActive(true)
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey:  44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            audioRecorder = try! AVAudioRecorder(url: getURL(), settings: settings)
            audioRecorder.delegate  = self
            audioRecorder.record()
            
            //録音中フラグを立てる
            isRecording = true
            
            //recordの画像をstopに変更
            let image = UIImage(named: "StopOn")
            let state = UIControl.State.normal
            recordButton.setImage(image, for: state)
            
            //playボタンを無効化
            playButton.isEnabled = false
            
            //ストップウォッチスタート
            myTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Action), userInfo: nil, repeats: true)
            
            
        }else {
            //録音をストップ
            audioRecorder.stop()
            isRecording = false
            playButton.isEnabled = true

            //recordの画像をstopに変更
            let image = UIImage(named: "RecordOn")
            let state = UIControl.State.normal
            recordButton.setImage(image, for: state)

            //playボタンを有効化
            playButton.isEnabled = true
        }
    }
    
    //再生終了時の処理
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
            isPlaying = false
            timerStop()
            //stopの画像をplayに変更
            let image = UIImage(named: "PlayOn")
            let state = UIControl.State.normal
            playButton.setImage(image, for: state)
            recordButton.isEnabled = true
       }

//**** タイマー関連の関数
    @objc func Action(){
        TimerDisplayed += 0.1
        timerLabel.text = String(floor(TimerDisplayed*100)/100)
    }
    //timerをストップ
    func timerStop(){
        myTimer.invalidate()
    }
    //timerをリセット
    func timerReset(){
        myTimer.invalidate()
        TimerDisplayed = 0
        timerLabel.text = "0.0"
    }
    
    //    録音データのURL取得
    func getURL() -> URL{
        let paths = FileManager.default.urls(for: .documentDirectory, in:  .userDomainMask)
        let docsDirect  =  paths[0]
        var url: URL
        if randomFlag {
            url  = docsDirect.appendingPathComponent("recording\(shuffled[count].id).m4a")
        }else{
            url  = docsDirect.appendingPathComponent("recording\(results[count].id).m4a")
        }
        return url
    }

    
    func playButtonFunc(){
        //再生中じゃないなら(再生させる)
        if !isPlaying{
            //録音データの取得
            audioPlayer = try! AVAudioPlayer(contentsOf: getURL())
            audioPlayer.delegate = self
            audioPlayer.numberOfLoops = 0
            audioPlayer.play()
            
            //再生中フラグを立たせる
            isPlaying = true
            
            //タイマーをリセット
            timerReset()
            //ストップウォッチスタート
            myTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Action), userInfo: nil, repeats: true)
   
            
            //playの画像をstopに変更
            let image = UIImage(named: "StopOn")
            let state = UIControl.State.normal
            playButton.setImage(image, for: state)
            
            //recordボタンを無効化
            recordButton.isEnabled  = false
           
            
        }
        else{
            //再生を停止
            audioPlayer.stop()
            isPlaying = false
            timerStop()
    
            //stopの画像をplayに変更
            let image = UIImage(named: "PlayOn")
            let state = UIControl.State.normal
            playButton.setImage(image, for: state)
            
            //rrecordボタンを有効化
            recordButton.isEnabled = true
        }
        
    }
    
    func nextButtonFunc(){
        //質問カウントが質問総数より下回るとき
        if count < questionNumber - 1  {
            count += 1
            if randomFlag{
                questionLabel.text = shuffled[count].content
            }else{
                questionLabel.text = results[count].content
            }
        }
        //次の質問を表示
        questionNumberLabel.text = String(count+1)

        //質問カウントが0以上ならbackボタンを有効化
        if count > 0{
        backButton.isEnabled = true
        }
        //質問カウントが0ならbackボタンを無効化
        else{
        backButton.isEnabled = false
        }
        //質問カウントが上限ならnextボタンを無効化
        if count == questionNumber - 1 {
        nextButton.isEnabled = false
        }
        
        //タイマーをリセット
        timerReset()
    }
    
    //backボタンがタップされたときの処理
    func backButtonFunc(){
        count -= 1
        if randomFlag{
            questionLabel.text = shuffled[count].content
        }else{
            questionLabel.text = results[count].content
        }

        if count > 0{
            backButton.isEnabled = true
        }else{
            backButton.isEnabled = false
        }

        if count < questionNumber - 1{
            nextButton.isEnabled = true
        }
        //前の質問を表示
        questionNumberLabel.text = String(count+1)
    }
    
    //質問が切り替わったときにオーディオが存在するかどうか確認する処理
    func questionChangeFunc(){
        if isAudioFile(){
            playButton.isEnabled = true
        }else{
            playButton.isEnabled = false
        }
        //スターかどうかをチェック
        starCheck()
    }
    
    //AudioFileがあるかどうか確認する関数
    func isAudioFile() -> Bool{
        if randomFlag{
            if shuffled[count].isAudio{
                trashButton.isEnabled = true
                return true
            }else{
                trashButton.isEnabled = false
                return false
            }
    }else{
            if results[count].isAudio{
                trashButton.isEnabled = true
                return true
            }else{
                trashButton.isEnabled = false
                return false
            }
        }
    }
    
    func starCheck() {
        if randomFlag{
            //質問がスターかどうかを判断し、ボタンを切り替える処理
            if shuffled[count].star{
                //starの画像をoffに変更
                let image = UIImage(named: "StarOn")
                let state = UIControl.State.normal
                starButton.setImage(image, for: state)
            }else{
                //starの画像をoffに変更
                let image = UIImage(named: "StarOff")
                let state = UIControl.State.normal
                starButton.setImage(image, for: state)
            }
        }else{
        //質問がスターかどうかを判断し、ボタンを切り替える処理
        if results[count].star{
        //starの画像をoffに変更
            let image = UIImage(named: "StarOn")
            let state = UIControl.State.normal
            starButton.setImage(image, for: state)
        }else{
            //starの画像をoffに変更
            let image = UIImage(named: "StarOff")
            let state = UIControl.State.normal
            starButton.setImage(image, for: state)
            }
        }
    }


    
}
