import UIKit
import CoreData

class AddVerbViewController: UIViewController {
    
    var tenses = ["Présent", "Imparfait", "Futur", "Passé", "Passé simple"]
    var articles = ["je", "tu", "il", "nous", "vous", "ils"]
    var dataResultsController = ManagedData.verbResultsController
    var managedObjectContext = ManagedData.persistentContainer.viewContext

    
    
    
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var frenchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBAction func searchWasPressed(_ sender: Any) {
    
    }
    
    override func viewDidLoad() {
        GetConjugation()
    }
    
    func GetConjugation() {
        let urlString = getURL()
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        
        let request = NSMutableURLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request as URLRequest) {
            data, response, error in
            
            if error != nil {
                print(error!.localizedDescription as String)
            } else {
                guard let unwrappedData = data else {
                    return
                }
                
                let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue)
                if let tempData = dataString {
                    let indicatif = self.isolateIndicatif(tempData)
                    
                    for tense in self.tenses {
                        let currentTense = self.isolateTense(currentString: indicatif, tense: tense)
                        
                        print(currentTense)
                        
                        for article in self.articles {
                            let verbConjugation = self.getVerbConjugation(currentTense: currentTense, article: article)
                        
                            print(verbConjugation)
                        }
                    }
                }
            }
        }
        task.resume()
    }
    
    func getURL() -> String {
        var string = ""
        if let frenchStr = frenchTextField.text{
            
            var tempUrl = frenchStr
            tempUrl = tempUrl.lowercased()
            let url = "http://conjugator.reverso.net/conjugation-french-verb-marcher.html"
            
            string = url
        }
        
        return string
    }
    
    func isolateIndicatif(_ URLContent: NSString) -> NSString {
        var indicatif = URLContent as NSString
        let startRange = indicatif.range(of: "<h4>Indicatif")
        indicatif = indicatif.substring(from: startRange.lowerBound) as NSString
        let endRange = indicatif.range(of: "Conditionnel")
        indicatif = indicatif.substring(to: endRange.upperBound) as NSString
        
        return indicatif
    }
    
    func isolateTense(currentString: NSString, tense: String) -> NSString {
        var currentTense = currentString
        let lowRange = currentTense.range(of: tense)
        currentTense = currentTense.substring(from: lowRange.lowerBound) as NSString
        let highRange = currentTense.range(of: "/ul")
        currentTense = currentTense.substring(to: highRange.lowerBound) as NSString
        
        return currentTense
    }
    
    func getVerbConjugation(currentTense: NSString, article: String) -> String {
        var currentArticle = currentTense
        var tempArticle = article
        
        if article == "je" {
            tempArticle = "j"
        }
        
        let articleLowRange = currentArticle.range(of: tempArticle)
        currentArticle = currentArticle.substring(from: articleLowRange.lowerBound) as NSString
        let articleUpperRange = currentArticle.range(of: "</li>")
        currentArticle = currentArticle.substring(to: articleUpperRange.lowerBound) as NSString
        
        let isolateLowRange = currentArticle.range(of: "verbtxt\">")
        currentArticle = currentArticle.substring(from: isolateLowRange.upperBound) as NSString
        let isolateHighRange = currentArticle.range(of: "</i>")
        currentArticle = currentArticle.substring(to: isolateHighRange.lowerBound) as NSString
        
        
        
        return currentArticle as String
    }
    
    func createNewVerb(english: String, french: String) {
        if let newVerb = NSEntityDescription.insertNewObject(forEntityName: "Verbs", into: managedObjectContext) as? Nouns {
            newVerb.creationDate = NSDate() as Date
            
    
            ManagedData.saveContext()
        } else {
            print("couldn't create new object")
        }
        
        do {
            try dataResultsController.performFetch()
        } catch {
            print("fetch failed")
        }
        
        tableView.reloadData()
    }
    
}
