import Foundation
import Dispatch

// Structure de données pour représenter une question
struct Question: Codable {
    let question: String
    let options: [String]
    let correctAnswer: Int
    let infos: String
    let difficulty: Int
    let category: String
}

// Structure de données pour représenter un joueur avec le niveau de difficulté
struct Player: Codable {
    var nom: String
    var score: Int
    var rang: Int
    var difficulty: Int
    
    init(nom: String, score: Int, rang: Int, difficulty: Int) {
        self.nom = nom
        self.score = score
        self.rang = rang
        self.difficulty = difficulty
    }
}

// Charger les questions à partir du fichier Questions.json
func loadQuestions() -> [Question] {
    var questions = [Question]()
    
    if let path = Bundle.main.path(forResource: "Questions", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            questions = try JSONDecoder().decode([Question].self, from: data)
        } catch {
            print("Erreur lors du chargement des questions: \(error)")
        }
    }
    
    return questions
}

// Fonction pour mettre à jour et enregistrer les données du joueur
func updatePlayerData(userName: String, userScore: Int, difficulty: Int) {
    var players = [Player]()
    
    // Charger les données des joueurs depuis le fichier Joueurs.json s'il existe
    if let path = Bundle.main.path(forResource: "Joueurs", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            players = try JSONDecoder().decode([Player].self, from: data)
        } catch {
            print("Erreur lors du chargement des données des joueurs: \(error)")
        }
    }
    
    // Mettre à jour les données du joueur actuel ou ajouter un nouveau joueur
    if let playerIndex = players.firstIndex(where: { $0.nom == userName }) {
        players[playerIndex].score = userScore
    } else {
        let newPlayer = Player(nom: userName, score: userScore, rang: 0, difficulty: difficulty) // Rang initial à 0
        players.append(newPlayer)
    }
    
    // Mettre à jour les rangs en fonction des scores
    players.sort { $0.score > $1.score }
    for (index, var player) in players.enumerated() {
        player.rang = index + 1
        players[index] = player
    }
    
    // Enregistrer les données mises à jour dans le fichier Joueurs.json
    do {
        let jsonData = try JSONEncoder().encode(players)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            try jsonString.write(toFile: "Joueurs.json", atomically: true, encoding: .utf8)
        }
    } catch {
        print("Erreur lors de l'enregistrement des données des joueurs: \(error)")
    }
}

// Fonction pour afficher le classement des joueurs par niveau de difficulté
func displayPlayerRanking(difficulty: Int) {
    var players = [Player]()
    
    // Charger les données des joueurs depuis le fichier Joueurs.json s'il existe
    if let path = Bundle.main.path(forResource: "Joueurs", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            players = try JSONDecoder().decode([Player].self, from: data)
        } catch {
            print("Erreur lors du chargement des données des joueurs: \(error)")
            return
        }
    }
    
    // Filtrer et trier les joueurs par niveau de difficulté
    let filteredPlayers = players.filter { $0.score > 0 && $0.difficulty == difficulty }
    let sortedPlayers = filteredPlayers.sorted { $0.score > $1.score }
    
    // Afficher le classement des joueurs
    print("\nClassement des joueurs pour la difficulté \(difficulty):\n")
    for (index, player) in sortedPlayers.enumerated() {
        print("\(index + 1). Joueur: \(player.nom) - Score: \(player.score) - Rang: \(player.rang)")
    }
}

// Fonction principale du jeu
func playQuizGame(questions: [Question], userName: String, difficulty: Int) {
    var userScore = 0
    print("----------------------------------")
    print("Bienvenue dans le jeu de quiz !")
    print("----------------------------------")
    
    for question in questions.shuffled() {
        print("\nQuestion: \(question.question)")
        
        for (index, option) in question.options.enumerated() {
            print("\(index + 1). \(option)")
        }
        
        print("\n----------------------------------")
        
        var userChoice: Int?
        
        repeat {
            print("Choisissez une réponse (1-\(question.options.count)): ")
            
            if let choiceString = readLine(), let choice = Int(choiceString), (1...question.options.count).contains(choice) {
                userChoice = choice
            } else {
                print("Choix invalide. Veuillez saisir un choix valide.")
            }
        } while userChoice == nil
        
        if userChoice! - 1 == question.correctAnswer {
            print("----------------------------------")
            print("Bonne réponse !")
            print("Infos: \(question.infos)")
            print("----------------------------------")
            userScore += 1
        } else {
            print("----------------------------------")
            print("Mauvaise réponse. La réponse correcte est: \(question.options[question.correctAnswer])")
            print("Infos: \(question.infos)")
            print("----------------------------------")
        }
    }
    
    print("\nVotre score final est: \(userScore)\n")
    print("----------------------------------")
    
    // Mettre à jour et enregistrer les données du joueur
    updatePlayerData(userName: userName, userScore: userScore, difficulty: difficulty)
}

// Fonction de validation du nom
func isValidName(_ name: String) -> Bool {
    let nameRegex = "^[a-zA-Z]+$"
    if let range = name.range(of: nameRegex, options: .regularExpression) {
        return range.lowerBound == name.startIndex && range.upperBound == name.endIndex
    } else {
        return false
    }
}

// Fonction de validation de la difficulté
func isValidDifficulty(_ difficulty: Int) -> Bool {
    return (1...3).contains(difficulty)
}

// Point d'entrée du programme
func main() {
    print("----------------------------------")
    print("Bienvenue dans le jeu de quiz !")
    print("----------------------------------")
    
    // Saisie du nom de l'utilisateur
    var userName: String = ""
    repeat {
        print("Veuillez saisir votre nom (lettres uniquement): ")
        if let inputName = readLine(), isValidName(inputName) {
            userName = inputName
        } else {
            print("Nom invalide. Veuillez saisir un nom contenant uniquement des lettres.")
        }
    } while userName.isEmpty
    
    print("----------------------------------")
    print("Bonjour, \(userName) !")
    print("----------------------------------")
    
    // Sélection du niveau de difficulté
    var difficulty: Int = 0
    repeat {
        print("Sélectionnez un niveau de difficulté (1 = Facile, 2 = Moyen, 3 = Difficile): ")
        if let userDifficulty = readLine(), let selectedDifficulty = Int(userDifficulty), isValidDifficulty(selectedDifficulty) {
            difficulty = selectedDifficulty
        } else {
            print("Niveau de difficulté invalide. Veuillez saisir 1, 2 ou 3.")
        }
    } while difficulty == 0
    
    print("----------------------------------")
    print("Niveau de difficulté sélectionné: \(difficulty)")
    
    // Chargement des questions à partir du fichier Questions.json
    let questions = loadQuestions().filter { $0.difficulty == difficulty }
    
    // Vérifier s'il y a des questions pour le niveau de difficulté choisi
    guard !questions.isEmpty else {
        print("----------------------------------")
        print("Aucune question disponible pour le niveau de difficulté sélectionné.")
        print("----------------------------------")
        return
    }
    
    // Jouer le jeu de quiz avec les questions du niveau de difficulté choisi
    playQuizGame(questions: questions, userName: userName, difficulty: difficulty)
    
    // Afficher le classement des joueurs
    print("Merci d'avoir joué !")
    print("----------------------------------")
    
    // Afficher le classement des joueurs par niveau de difficulté
    displayPlayerRanking(difficulty: difficulty)
    print("\n----------------------------------")
}

// Appel de la fonction principale
while true {
    main()
    
    print("\nVoulez-vous quitter le programme ? (0 = Oui, 1 = Non): ")
    if let response = readLine(), response.lowercased() == "0" {
        break
    }
}
