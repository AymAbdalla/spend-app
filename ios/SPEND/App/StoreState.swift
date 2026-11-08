import Observation
import SwiftData

@MainActor @Observable
final class StoreState {
    private(set) var container: ModelContainer?
    private(set) var hasError = false
    private let loader: () throws -> ModelContainer

    init(loader: @escaping () throws -> ModelContainer) { self.loader = loader }
    func load() {
        guard container == nil else { return }
        do {
            container = try loader()
            hasError = false
        } catch {
            hasError = true
        }
    }
}
