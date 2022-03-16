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

extension CursorPage {
    func asyncMap<U>(
        _ transform: (T) async throws -> U
    ) async rethrows -> CursorPage<U> {
        var values = [U]()

        for element in self.items {
            try await values.append(transform(element))
        }

        return CursorPage<U>(items: values, metadata: self.metadata)
    }
}

extension Sequence {
    func asyncMap<T>(
        _ transform: (Element) async throws -> T
    ) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
