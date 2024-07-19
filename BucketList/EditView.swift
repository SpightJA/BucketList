//
//  EditView.swift
//  BucketList
//
//  Created by Jon Spight on 5/13/24.
//

import SwiftUI

struct EditView: View {
    @Environment(\.dismiss) var dismiss
    var location : Location
    @State private var newName : String
    @State private var newDescription : String
    var onSave: (Location) -> Void
    enum LoadingState {
        case loading, loaded, failed
    }
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Place Name", text: $newName)
                    TextField("Description", text: $newDescription)

                }
                Section {
                    switch loadingState {
                    case .loading:
                        Text("Loading")
                    case .loaded:

                        ForEach(pages, id: \.pageid) { page in
                            Text(page.title)
                                .font(.headline) +
                            Text(": ") +
                            Text(page.description)
                                .italic()
                        }
                    case .failed:
                        Text("Please try again later")
                    }
                }
            }
            
                .navigationTitle("Place Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("Save"){
                            var newLocation = location
                            newLocation.id = UUID()
                            newLocation.name = newName
                            newLocation.description = newDescription
                            onSave(newLocation)
                            dismiss()
                        }
                    }
                }
                .task {
                   await fetchData()
                }
        }
       
        
    }
    init(location : Location, onSave: @escaping (Location) ->Void ){
        self.location = location
        self.onSave = onSave
        
        _newName = State(initialValue: location.name)
        _newDescription = State(initialValue: location.description)
    }
    
    func fetchData() async {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(location.latitude)%7C\(location.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad Url:  \(urlString)")
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(Result.self, from: data)
            pages = decoded.query.pages.values.sorted()
            loadingState = .loaded
                
            
            
        } catch {
            loadingState = .failed
            print(error)
        }
    }
}

#Preview {
    EditView(location: .example, onSave: {_ in })
}
