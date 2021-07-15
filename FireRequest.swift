//
//  FireRequest
//
//  Created by Florian Schweizer on 12.07.21.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

@propertyWrapper
public class FireRequest<T: Decodable> {
    @Published public var wrappedValue: [T] = []
    
    private let store = Firestore.firestore()
    
    init(_ collection: String, _ predicates: [FRPredicate] = []) {
        load(from: collection, withPredicates: predicates)
    }
    
    private func load(from collection: String, withPredicates predicates: [FRPredicate] = []) {
        let reference = store.collection(collection)
        
        if predicates.isEmpty {
            reference
                .getDocuments { snapshot, error in
                    guard error == nil, let snapshot = snapshot else {
                        return
                    }
                    
                    self.wrappedValue = snapshot.documents.compactMap { document in
                        try? document.data(as: T.self)
                    }
                }
        } else {
            var query: Query? = nil
            for predicate in predicates {
                switch predicate {
                    case .isEqualTo(let lhs, let rhs):
                        if let tampQuery = query {
                            query = tampQuery.whereField(lhs, isEqualTo: rhs)
                        } else {
                            query = reference.whereField(lhs, isEqualTo: rhs)
                        }
                }
            }
            
            query?
                .getDocuments { snapshot, error in
                    guard error == nil, let snapshot = snapshot else {
                        return
                    }
                    
                    self.wrappedValue = snapshot.documents.compactMap { document in
                        try? document.data(as: T.self)
                    }
                }
        }
    }
}
