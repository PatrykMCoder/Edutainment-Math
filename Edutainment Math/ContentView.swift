//
//  ContentView.swift
//  Edutainment Math
//
//  Created by Patryk Marciszewski on 28/10/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var multiplication = 2
    @State private var maxQuestions = 5
    @State private var correctAnswers = 0
    
    @State private var showQuestion = false
    @State private var doNotAsk = false
    @State private var gameOver = false
    
    @State private var questions: [Question] = []
    @State private var currentQuestionNumber = 0
    @State private var currentQuestion: Int = 0
    @State private var generatedAnswers: [Int] = []
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    @State private var prepareGame = true
    @State private var inGame = false
    
    @State private var buttonColor = Color.blue
    @State private var selected = -1
    private var selections = [5, 10, 20]
    
    var body: some View {
        NavigationStack {
            if inGame {
                Text("Question \(currentQuestionNumber)/\(maxQuestions)")
            }
            Form {
                if prepareGame {
                    Stepper("Select multiplication: \(multiplication)", value: $multiplication, in: 2...12)
                        .onChange(of: multiplication, initial: true) {
                            resetGame()
                        }
                    Section("Select max number of questions") {
                        Picker("", selection: $maxQuestions) {
                            ForEach(selections, id: \.self) { number in
                                Text("\(number)")
                            }
                        }.pickerStyle(.segmented)
                        
                        Button("Start Game") {
                            inGame = true
                            prepareGame = false
                        }.frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                if inGame {
                    if questions.isEmpty {
                        Text("No quesitons here")
                    } else {
                        Text(questions[currentQuestion].question)
                    }
                    HStack {
                        ForEach(0..<generatedAnswers.count, id: \.self) { number in
                            Button {
                                checkAnswer(generatedAnswers[number])
                            }label: {
                                Text("\(generatedAnswers[number])")
                                    .frame(width: 80, height: 80)
                            }
                            .contentShape(Rectangle())
                            .foregroundStyle(.white)
                            .background(selected != -1 ? (selected == questions[currentQuestion].correctAnser  ? Color.green : Color.red) : Color.blue)
                            .foregroundColor(buttonColor)
                            .buttonStyle(.bordered)
                            .animation(.default, value: selected)
                        }
                    }
                }
            }
            .navigationTitle("Learn Math")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(alertTitle, isPresented: $showAlert) {
            if currentQuestionNumber < maxQuestions {
                Button("OK") {
                    if !doNotAsk {
                        askQuestion()
                    }
                }
            } else {
                Button("Restart game", action: resetGame)
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    func generateQuestions() {
        for number in 1...maxQuestions {
            questions.append(Question(number: number, multiplication: multiplication))
        }
        
        askQuestion()
    }
    
    func askQuestion() {
        generatedAnswers.removeAll()
        questions.shuffle()
        if currentQuestionNumber <= maxQuestions {
            currentQuestion = Int.random(in: 0..<maxQuestions)
        }
        
        generatedAnswers.append(questions[currentQuestion].correctAnser)
        for _ in 0...1 {
            generatedAnswers.append(Int.random(in: 0...multiplication * 10))
        }
        
        generatedAnswers.shuffle()
        
        selected = -1
        currentQuestionNumber += 1
    }
    
    func resetGame() {
        questions.removeAll()
        generatedAnswers.removeAll()
        currentQuestionNumber = 0
        selected = -1
        prepareGame = true
        inGame = false
        generateQuestions()
    }
    
    func checkAnswer(_ answer: Int) {
        var correct = false
        selected = answer
        if answer == questions[currentQuestion].correctAnser {
            alertTitle = "Correct!"
            correctAnswers += 1
            correct = true
        } else {
            alertTitle = "Wrong!"
            correct = false
        }
        
        if currentQuestionNumber < maxQuestions {
            alertMessage = correct ? "Your answer is good, good job!" : "Your answer is wrong. This is: \(questions[currentQuestion].correctAnser)"
        } else {
            alertMessage = "Game over! You can restart game."
        }
        
        showAlert = true
    }
}

struct Question {
    let correctAnser: Int
    let question: String
    
    init(number: Int, multiplication: Int) {
        self.correctAnser = multiplication * number
        self.question = "What is \(number) times \(multiplication)?"
    }
}

#Preview {
    ContentView()
}
