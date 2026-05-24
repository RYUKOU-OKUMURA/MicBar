import Foundation

enum DisplayNameFormatter {
    /// Assigns display names with numeric suffixes for duplicate device names.
    static func format(names: [String]) -> [String] {
        guard !names.isEmpty else { return [] }

        var nameCounts: [String: Int] = [:]
        for name in names {
            nameCounts[name, default: 0] += 1
        }

        var nameIndices: [String: Int] = [:]
        return names.map { name in
            if nameCounts[name, default: 0] <= 1 {
                return name
            }
            let index = (nameIndices[name, default: 0]) + 1
            nameIndices[name] = index
            return index == 1 ? name : "\(name) \(index)"
        }
    }
}
