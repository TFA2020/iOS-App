//
//  ViewController.swift
//  I Speak
//
//  Created by Zhiyuan Chen on 4/9/20.
//  Copyright © 2020 TFA. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UIViewController, UITextFieldDelegate, UNUserNotificationCenterDelegate {
    
    //credit https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.black
        let textFont = UIFont(name: "Helvetica Bold", size: 30)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    @IBOutlet weak var background: UIImageView!
    @IBOutlet weak var languageCard: UIImageView!
    @IBOutlet weak var welcome: UIImageView!
    @IBOutlet weak var instruction: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var image:UIImage = UIImage(named : "LanguageCard")!
    var language:String = ""
    
    //notification should be displayed in the corresponding language. declare class variables
    var notTitle:String = ""
    var notContent:String = ""
    
    let userNotificationCenter = UNUserNotificationCenter.current()
    
    //https://programmingwithswift.com/how-to-send-local-notification-with-swift-5/
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.badge,.sound])
    }
    
    //https://www.hackingwithswift.com/example-code/media/uiimagewritetosavedphotosalbum-how-to-write-to-the-ios-photo-album
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            requestNotificationAuthorization()
        }
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
            if success {
                self.sendNotification()
            }
        }
    }

    func sendNotification() {
        // Create new notifcation content instance
        let notificationContent = UNMutableNotificationContent()

        // Add the content to the notification content
        notificationContent.title = notTitle
        notificationContent.body = notContent
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5,repeats: false)
        let request = UNNotificationRequest(identifier: "TFA I Speak", content: notificationContent,trigger: trigger)
        userNotificationCenter.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.delegate = self
        image = languageCard.image!
        
        self.userNotificationCenter.delegate = self
        //request authorization for notification
        
        //keyboard events listeners (Swift 5)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func keyboardWillChange(notification : Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        }else {
            view.frame.origin.y = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func save(_ sender: Any) {
        if self.notTitle != ""{
            UIImageWriteToSavedPhotosAlbum(languageCard.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @IBAction func updateText(_ sender: Any) {
        if !textField.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            //language constant
            let langCodes:[String] = ["af","am","ar","az","ba","be","bg","bn","bs","ca","ceb","cs","cv","cy","da","de","el","en","eo","es","et","eu","fa","fi","fr","ga","gd","gl","gu","he","hi","hr","ht","hu","hy","id","is","it","ja","jv","ka","kk","km","kn","ko","ky","la","lb","lo","lt","lv","mg","mhr","mi","mk","ml","mn","mr","mrj","ms","mt","my","ne","nl","no","pa","pap","pl","pt","ro","ru","sah","si","sk","sl","sq","sr","su","sv","sw","ta","te","tg","th","tl","tr","tt","udm","uk","ur","uz","vi","xh","yi","zh"]

            let languages:[String] = ["Afrikaans","Amharic","Arabic","Azerbaijani","Bashkir","Belarusian","Bulgarian","Bengali","Bosnian","Catalan","Cebuano","Czech","Chuvash","Welsh","Danish","German","Greek","English","Esperanto","Spanish","Estonian","Basque","Persian","Finnish","French","Irish","Scottish Gaelic" ,"Galician","Gujarati","Hebrew","Hindi","Croatian","Haitian","Hungarian","Armenian","Indonesian","Icelandic","Italian","Japanese","Javanese","Georgian","Kazakh","Khmer","Kannada","Korean","Kyrgyz","Latin","Luxembourgish","Lao","Lithuanian","Latvian","Malagasy","Mari","Maori","Macedonian","Malayalam","Mongolian","Marathi","Hill Mari" ,"Malay","Maltese","Burmese","Nepali","Dutch","Norwegian","Punjabi","Papiamento", "Polish","Portuguese","Romanian","Russian", "Yakut","Sinhalese","Slovak","Slovenian","Albanian","Serbian","Sundanese","Swedish","Swahili","Tamil","Telugu","Tajik","Thai","Tagalog","Turkish","Tatar","Udmurt","Ukrainian","Urdu","Uzbek","Vietnamese","Xhosa","Yiddish","Chinese"]
            
            let key:String = "trnsl.1.1.20200407T221957Z.602d93706a270859.dae471cacd06010378460b565fe693fadf160d1a"
            // Prepare URL
            
            let originalString:String = textField.text!
            let escapedString:String = originalString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            var urlString = "https://translate.yandex.net/api/v1.5/tr.json/detect?key=" + key + "&text=" + escapedString
            let detect = postRequest()
            detect.sendRequest(myURL: urlString, target: "lang"){ d in
                self.language = d;
                var i = 0
                for (index,lang) in langCodes.enumerated(){
                    if (lang == self.language){
                        i = index
                        break
                    }
                }
                
                DispatchQueue.main.async { // Correct
                    self.languageCard.image = self.textToImage(drawText: languages[i], inImage: self.image, atPoint: CGPoint(x:245, y:95))
                }
                var message:String = "Do You Speak " + languages[i] + "? " + "Show this card to your healthcare provider to request for free translation services"
                message = message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                urlString = "https://translate.yandex.net/api/v1.5/tr.json/translate?&key=" + key + "&text=" + message + "&lang=" + self.language
                let translate = postRequest()
                translate.sendRequest(myURL: urlString, target: "text"){ t in
                    DispatchQueue.main.async { // Correct
                        self.instruction.text = t
                    }
                    var message2:String = "Check Your Photo Album"
                    message2 = message2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                    urlString = "https://translate.yandex.net/api/v1.5/tr.json/translate?&key=" + key + "&text=" + message2 + "&lang=" + self.language
                    let translate2 = postRequest()
                    translate2.sendRequest(myURL: urlString, target: "text"){ t2 in
                        DispatchQueue.main.async { // Correct
                            self.notTitle = t2
                        }
                        var message3:String = "Your image has been saved to your photo album"
                        message3 = message3.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                        urlString = "https://translate.yandex.net/api/v1.5/tr.json/translate?&key=" + key + "&text=" + message3 + "&lang=" + self.language
                        let translate3 = postRequest()
                        translate3.sendRequest(myURL: urlString, target: "text"){ t3 in
                            DispatchQueue.main.async { // Correct
                                self.notContent = t3
                            }
                            var message4:String = "Save Photo"
                            message4 = message4.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                            urlString = "https://translate.yandex.net/api/v1.5/tr.json/translate?&key=" + key + "&text=" + message4 + "&lang=" + self.language
                            let translate4 = postRequest()
                            translate4.sendRequest(myURL: urlString, target: "text"){ t4 in
                                DispatchQueue.main.async { // Correct
                                    self.saveButton.setTitle(t4, for: .normal)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

class postRequest {
    
    func sendRequest(myURL:String, target:String, completion:  @escaping (String) -> ()){
        
        let url = URL(string: myURL)
        guard let requestUrl = url else { fatalError() }
        // Prepare URL Request Object
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        
        // Perform HTTP Request
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            // Check for Error
            if let error = error {
                print("Error took place \(error)")
                return
            }
            // Convert HTTP Response Data to JSON
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data) as! [String:Any]
                    var output:String
                    if let d = (json[target] as? [String]) {
                        output = d[0]
                    }else{
                        output = (json[target] as? String)!
                    }
                    completion(output);
                } catch let error as NSError {
                    print(error)
                }
            }
        }
        task.resume()
    }
}


