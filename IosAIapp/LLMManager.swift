//
//  LLMManager.swift
//  IosAIapp
//
//  Created by Will Fk on 5/21/26.
//

import Foundation
import MLX
import MLXLLM
import Tokenizers
import Combine
import MLXLMCommon
import MLXHuggingFace

    
@MainActor
class LLMManager: ObservableObject {
    @Published var outputText: String = "Click 'Load Model' to begin..."
    @Published var isLoading: Bool = false
    @Published var isModelLoaded: Bool = false
    @Published var prompt: String = "Hello, how are you today?"
    
    private var modelContainer: ModelContainer? = nil
    
    func loadModel() async {
        guard modelContainer == nil else { return }
        self.isLoading = true
        self.isModelLoaded = false
        
        guard let bundlePath = Bundle.main.path(forResource: "QwenOptimized", ofType: nil) else {
            self.outputText = "Error: Folder not found."
            return
        }
        do {
            guard let bundlePath = Bundle.main.path(forResource: "QwenOptimized", ofType: nil) else {
                self.outputText = "Error: Folder not found."
                self.isLoading = false
                return
            }
            
            let directoryURL = URL(fileURLWithPath: bundlePath)
            
            
            let configuration = ModelConfiguration(directory: directoryURL)
            
            // 2. Use the real, verified token loader wrapper from the core framework
            
            
            // 3. Fulfill the exact 3-argument signature demanded by the v3 compiler
            let container = try await LLMModelFactory.shared.loadContainer(
                from: directoryURL,
                using: #huggingFaceTokenizerLoader,
                
            )
            self.modelContainer = container
            
            self.isModelLoaded = true
            self.isLoading = false
            self.outputText = ""
            
            
            
            
            let userInput = UserInput(prompt: prompt)
            let lmInput = try await container.processor.prepare(input: userInput)
            
            
            let stream = try await container.generate(
                input: lmInput,
                parameters: GenerateParameters(maxTokens: 500)
            )
            
            
            for await event in stream {
                switch event {
                case .chunk(let text):
                    self.outputText += text
                    print(text, terminator: "")
                    fflush(stdout)
                    
                case .info(let statistics):
                    print("\n\n--- Stats ---")
                    print("Tokens per second: \(String(format: "%.2f", statistics.tokensPerSecond))")
                    
                @unknown default:
                    break
                }
            }
            
        } catch {
            self.isLoading = false
            self.isModelLoaded = false
            self.outputText = "Inference error: \(error.localizedDescription)"
            print("Inference error context: \(error)")
        }
        
    }
    
    func GenerateResponse(prompt : String) async {
        guard let container = modelContainer else {
            self.outputText = "Model not loaded yet."
            return
        }
        
        
        self.outputText = ""
        do {
            let userInput = UserInput(prompt:prompt)
            let lmInput = try await container.processor.prepare(input: userInput)
            
            let stream = try await container.generate(
                input: lmInput,
                parameters: GenerateParameters(maxTokens: 1000)
            )
            for await event in stream {
                switch event {
                case .chunk(let text):
                    self.outputText += text
                    
                case .info(let statistics):
                    print("Tokens per second: \(String(format: "%.2f", statistics.tokensPerSecond))")
                    
                @unknown default:
                    break
                }
            }
        } catch {
           
                        self.outputText = "Generation error: \(error.localizedDescription)"
            
        }
            
        }
        
    }

