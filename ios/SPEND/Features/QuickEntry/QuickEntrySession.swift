import Foundation
import Observation
import SwiftData

@MainActor @Observable
final class QuickEntrySession {
    var draft = PurchaseDraft()
    private(set) var errorMessage: String?
    private(set) var isSaving = false
    private(set) var isSaved = false

    func save(in context: ModelContext, locale: Locale = .current,
              commit: (ModelContext) throws -> Void = { try $0.save() }) -> Bool {
        guard !isSaving, !isSaved else { return false }
        isSaving = true
        defer { isSaving = false }
        do {
            try PurchaseWriter.save(draft, in: context, locale: locale, commit: commit)
            isSaved = true
            errorMessage = nil
            return true
        } catch let error as JournalError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = "Couldn't save this purchase. Your entry is still here. Try saving again."
        }
        return false
    }
}
