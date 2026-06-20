import Foundation

extension String {
    var resolvedPublishedDate: String {
        split(separator: " ").first.map(String.init) ?? self
    }
}
