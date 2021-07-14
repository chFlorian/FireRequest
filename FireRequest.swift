import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

@propertyWrapper
public class FireRequest<T: Decodable> {
    @Published public var wrappedValue: [T] = []
    
    private let store = Firestore.firestore()
    private let collection: String
    
    init(_ collection: String) {
        self.collection = collection
        
        load()
    }
    
    private func load() {
        store
            .collection(collection)
            .getDocuments { snapshot, error in
                guard error == nil,
                      let snapshot = snapshot else {
                      return
                  }
                
                self.wrappedValue = snapshot.documents.compactMap { document in
                    try? document.data(as: T.self)
                }
            }
    }
}
