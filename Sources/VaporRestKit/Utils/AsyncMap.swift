// From: https://www.swiftbysundell.com/articles/async-and-concurrent-forEach-and-map/
import FluentKit

extension Page {
    func asyncMap<U>(
        _ transform: (T) async throws -> U
    ) async rethrows -> Page<U> {
        var values = [U]()

        for element in self.items {
            try await values.append(transform(element))
        }

        return Page<U>(items: values, metadata: self.metadata)
    }
}
