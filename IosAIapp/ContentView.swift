//
//  ContentView.swift
//  IosAIapp
//
//  Created by Will Fk on 5/20/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
   @State var TextInput : String = ""
    @StateObject private var llmmanager = LLMManager()
    

    var body: some View {
        ScrollView{
                
            Text(llmmanager.outputText)
        }
        Button(action: {
            Task {
                await llmmanager.loadModel()
            }
        }) {
            if llmmanager.isLoading {
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    Text("Processing...")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.gray)
                .cornerRadius(12)
            } else {
                Text(llmmanager.isModelLoaded ? "Run Query Again" : "Load Model & Run")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
          
            
        }
        
        HStack{
            TextField("Ask the model a question here...",text: $TextInput)
            Button  {
                llmmanager.prompt = TextInput
                Task {
                    await llmmanager.GenerateResponse(prompt: TextInput)
                    TextInput = ""
                }
            } label: {
                Image(systemName: "arrow.up")
                    .foregroundStyle(Color.white)
                    .frame(width: 30, height: 30)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
    }
}

#Preview {
    ContentView()
   
}
