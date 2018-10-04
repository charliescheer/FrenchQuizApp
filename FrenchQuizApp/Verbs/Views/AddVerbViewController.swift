import UIKit
import CoreData

class AddVerbViewController: UIViewController, UITextFieldDelegate {
    
    var tenses = ["Présent", "Imparfait", "Futur", "Passé", "Passé simple"]
    var articles = ["je", "tu", "il", "nous", "vous", "ils"]
    var dataResultsController = ManagedData.verbResultsController
    var managedObjectContext = ManagedData.persistentContainer.viewContext
    var newVerbDictionary : [String : [String : String]] = [ : ]
    let dispatchGroup = DispatchGroup()
    
    
    @IBOutlet weak var englishTextField: UITextField!
    @IBOutlet weak var frenchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func searchWasPressed(_ sender: Any) {
        if englishTextField.text == "" || frenchTextField.text == "" {
            displayEmptyVerbAlert()
        } else {
            //get the URL data
            let verbURLString = getURL()
            
            //Isolate the conjugations
            //create the dictionary
            dispatchGroup.enter()
            self.getVerbDescriptionStringFromURL(from: verbURLString)
            dispatchGroup.wait()
            
            //save dictionary to new object
            //add to coredata
            //reset the tableview
            let mutatedDictionary = mutateDictionaryToData()
            createNewVerb(english: englishTextField.text!, french: frenchTextField.text!, dictionaryData: mutatedDictionary)
        }
    }

    
    override func viewDidLoad() {
        
    }
    
    func getURL() -> String {
        var string = ""
        if let frenchStr = frenchTextField.text{
            string = "http://conjugator.reverso.net/conjugation-french-verb-" + frenchStr.lowercased() + ".html"
        }
        return string
    }

    
    override func viewDidAppear(_ animated: Bool) {
        clearNewInputTextFields()
        fetchSavedVerbs()
    }
    
    func getVerbDescriptionStringFromURL(from URLString: String) {
        
        var isolatedWebText : NSString = ""
        
        if let url = URL(string: URLString) {
            let request = NSMutableURLRequest(url: url)
            
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                if error != nil {
                    print(error!.localizedDescription)
                } else {
                    guard let unwrappedData = data else {
                        return
                    }
                    
                    
                    guard let dataString = NSString(data: unwrappedData, encoding: String.Encoding.utf8.rawValue) else {
                        return
                    }
                    
                    
                    
                    if dataString.contains("The verb entered does not match any possible conjugation table") {
                        isolatedWebText = "error"
                        
                    } else {
                        isolatedWebText = self.isolateIndicatif(dataString)
                        self.parseVerbConjugationFromDataString(isolatedWebText)
                    }
                    self.dispatchGroup.leave()
                }
            }
            task.resume()
            
        }
        
        
        
    }
    
    func isolateIndicatif(_ URLContent: NSString) -> NSString {
        var indicatif = URLContent as NSString
        let startRange = indicatif.range(of: "<h4>Indicatif")
        indicatif = indicatif.substring(from: startRange.lowerBound) as NSString
        let endRange = indicatif.range(of: "Conditionnel")
        indicatif = indicatif.substring(to: endRange.upperBound) as NSString
        
        return indicatif
    }
    
    func newParseConjugationsFromString(_ dataString: NSString) {
        let indicatif = dataString
        
        let futurTense = isolateIndicatif(isolateTense(currentString: indicatif, tense: "futur"))
        print(futurTense)
        
    }
    
    func parseVerbConjugationFromDataString(_ dataString : NSString) {
        let indicatif = dataString
        
        for tense in self.tenses {
            let currentTense = self.isolateTense(currentString: indicatif, tense: tense)
            var tempDictionary : [String : String] = [:]
            
            for article in self.articles {
                let verbConjugation = self.getVerbConjugations(currentTense: currentTense, article: article)
                tempDictionary[article as String] = verbConjugation
            }
            self.newVerbDictionary[tense as String] = tempDictionary
            
        }
    }
    
    func isolateTense(currentString: NSString, tense: String) -> NSString {
        var currentTense = currentString
        let lowRange = currentTense.range(of: tense)
        currentTense = currentTense.substring(from: lowRange.lowerBound) as NSString
        let highRange = currentTense.range(of: "/ul")
        currentTense = currentTense.substring(to: highRange.lowerBound) as NSString
        
        return currentTense
    }
    
    func getVerbConjugations(currentTense: NSString, article: String) -> String {
        var currentArticle = currentTense
        var tempArticle = "graytxt\">"
        
        if article == "je" {
            tempArticle = tempArticle + "j"
        } else {
            tempArticle = tempArticle + article
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
    
    
    
    func mutateDictionaryToData() -> Data {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: newVerbDictionary)
        
        return data
    }
    
    func createNewVerb(english : String, french : String, dictionaryData: Data) {
        if let newVerb = NSEntityDescription.insertNewObject(forEntityName: "Verbs", into: managedObjectContext) as? Verbs {
            newVerb.english = english
            newVerb.french = french
            newVerb.creationDate = NSDate() as Date
            newVerb.conjugationDictionary = dictionaryData
            
            ManagedData.saveContext()
        } else {
            print("couldn't create new object")
        }
        
        fetchSavedVerbs()
        clearNewInputTextFields()
    }
    
    func fetchSavedVerbs() {
        do {
            try dataResultsController.performFetch()
        } catch {
            print("fetch failed")
        }
        
        tableView.reloadData()
    }
    
    func clearNewInputTextFields() {
        englishTextField.text = ""
        frenchTextField.text = ""
    }
    
    func displayEmptyVerbAlert () {
        let alert = UIAlertController(title: "Enter Verb", message: "Please enter a Verb for both fields", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func noVerbFoundAlert () {
        let alert = UIAlertController(title: "Error", message: "Couldn't find verb \(String(describing: frenchTextField.text))  Please try again", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    func verbFoundAlert (_ dataString: NSString) {
        let alert = UIAlertController(title: "Verb Found", message: "Would you like to save \(String(describing: frenchTextField.text))?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
            self.parseVerbConjugationFromDataString(dataString)
        }))
        self.present(alert, animated: true)
    }
    
}

extension AddVerbViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        guard  let sections = dataResultsController.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = dataResultsController.sections?[section] else {
            fatalError("No sections in fetchedResultsController")
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: constants.tableViewCellIdentifier, for: indexPath) as! VerbCell
        
        if let verb = dataResultsController.object(at: indexPath) as? Verbs {
            cell.englishVerbLabel.text = verb.english
            cell.frenchVerbLabel.text = verb.french
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == constants.showVerbVC {
            let verbVC = segue.destination as? VerbEditViewController
            
            guard let verbCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: verbCell) else {
                return
            }
            
            if let verb  = dataResultsController.object(at: indexPath) as? Verbs {
                verbVC?.verb = verb
            }
        }
    }
    
}

extension AddVerbViewController {
    enum constants {
        static let tableViewCellIdentifier = "verbCell"
        static let showVerbVC = "showVerbSegue"
    }
}
