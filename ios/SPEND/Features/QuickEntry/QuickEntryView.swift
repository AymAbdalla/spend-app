import SwiftUI
import SwiftData

struct QuickEntryView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Environment(\.locale) private var locale
    @Environment(\.dynamicTypeSize) private var typeSize
    @State private var session = QuickEntrySession()
    @FocusState private var focusedField: Field?
    let commit: (ModelContext) throws -> Void
    let onSave: () -> Void

    private enum Field { case amount, merchant, notes }

    var body: some View {
        NavigationStack {
            Form {
                if let error = session.errorMessage {
                    Section {
                        Label(error, systemImage: "exclamationmark.circle")
                            .foregroundStyle(.primary)
                            .accessibilityIdentifier("entryError")
                    }
                }
                Section {
                    TextField("0.00", text: $session.draft.amount)
                        .font(.largeTitle.monospacedDigit())
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = .amount }
                        .keyboardType(.decimalPad)
                        .focused($focusedField, equals: .amount)
                        .accessibilityLabel("Amount in US dollars")
                        .accessibilityIdentifier("amountField")
                } header: {
                    Text("Amount · USD")
                } footer: {
                    Text("Enter the purchase amount, without thousands separators.")
                }
                Section("Merchant or description") {
                    // The field is a 44-point target at every text size: the content shape
                    // and the tap make the whole 44-point frame focus it, because the text
                    // field alone is only as tall as its line. At the standard sizes the row
                    // keeps its usual height by giving up its insets.
                    TextField("Where or what was it?", text: $session.draft.merchant)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = .merchant }
                        .listRowInsets(typeSize.isAccessibilitySize ? nil
                                       : EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                        .textInputAutocapitalization(.sentences)
                        .focused($focusedField, equals: .merchant)
                        .submitLabel(.done)
                        .accessibilityLabel("Merchant or description")
                        .accessibilityIdentifier("merchantField")
                }
                Section("Details") {
                    Picker("Category", selection: $session.draft.category) {
                        ForEach(PurchaseCategory.allCases) { category in
                            Text(category.title).tag(category)
                        }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("categoryPicker")
                    Picker("Spending type", selection: $session.draft.spendingType) {
                        ForEach(SpendingType.allCases) { type in Text(type.title).tag(type) }
                    }
                    .pickerStyle(.menu)
                    .accessibilityIdentifier("spendingTypePicker")
                    TextField("Notes (optional)", text: $session.draft.notes, axis: .vertical)
                        .lineLimit(2...4)
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                        .onTapGesture { focusedField = .notes }
                        .focused($focusedField, equals: .notes)
                        .accessibilityIdentifier("notesField")
                    LabeledContent("Date", value: session.draft.date.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Quick Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .accessibilityIdentifier("cancelEntry")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        focusedField = nil
                        if session.save(in: context, locale: locale, commit: commit) {
                            onSave()
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(session.isSaving || session.isSaved)
                    .accessibilityLabel("Save purchase")
                    .accessibilityIdentifier("savePurchase")
                }
            }
            .safeAreaInset(edge: .bottom) {
                if focusedField != nil {
                    HStack {
                        Spacer()
                        Button("Done") { focusedField = nil }
                            .accessibilityIdentifier("keyboardDone")
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(.bar)
                }
            }
            .onAppear { focusedField = .amount }
        }
    }
}
