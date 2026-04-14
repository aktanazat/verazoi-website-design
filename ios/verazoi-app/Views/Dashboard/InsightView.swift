import SwiftUI

struct InsightView: View {
    @Environment(AppState.self) private var state
    @Environment(\.design) private var design
    @State private var isGenerating = false
    @State private var isLoadingPreview = false
    @State private var showPayloadReview = false

    private var canGenerate: Bool {
        state.weeklyInsightPreview != nil && !isGenerating
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                VLabelText(text: "AI Insights")
                    .padding(.top, 4)

                Text("Weekly Analysis")
                    .font(.vSerif(28))
                    .foregroundStyle(Color.vForeground)
                    .padding(.top, 12)

                VCard {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Review the exact weekly payload before sending it to Anthropic. Nothing is sent until you generate an insight.")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.vMutedForeground)
                            .lineSpacing(3)

                        Button(action: reviewPayload) {
                            HStack(spacing: 8) {
                                if isLoadingPreview {
                                    ProgressView()
                                        .controlSize(.small)
                                        .tint(Color.vMutedForeground)
                                }
                                Text(payloadButtonTitle)
                            }
                            .font(.system(size: 12, weight: .medium))
                            .tracking(0.4)
                            .foregroundStyle(Color.vMutedForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: design.buttonRadius)
                                    .stroke(Color.vBorder, lineWidth: 0.5)
                            )
                        }
                        .disabled(isLoadingPreview)
                        .padding(.top, 16)

                        if let preview = state.weeklyInsightPreview {
                            VStack(alignment: .leading, spacing: 6) {
                                VLabelText(text: "Preview ready")
                                Text("Week of \(preview.weekStart) to \(preview.weekEnd)")
                                    .font(.system(size: 13))
                                    .foregroundStyle(Color.vForeground)
                                Text("\(preview.userPrompt.count) characters in the reviewed payload.")
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.vMutedForeground)
                            }
                            .padding(.top, 20)
                        } else {
                            Text("Load the payload preview before generating so you can verify the exact data sent to Anthropic.")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.vMutedForeground)
                                .lineSpacing(3)
                                .padding(.top, 20)
                        }

                        if let insightError = state.insightError {
                            Text(insightError)
                                .font(.system(size: 12))
                                .foregroundStyle(Color.vAmber)
                                .lineSpacing(3)
                                .padding(.top, 16)
                        }

                        if let insight = state.weeklyInsight {
                            InsightSummaryCard(
                                insight: insight,
                                canGenerate: canGenerate,
                                isGenerating: isGenerating,
                                action: generateInsight
                            )
                            .padding(.top, 20)
                        } else {
                            InsightEmptyState(
                                canGenerate: canGenerate,
                                isGenerating: isGenerating,
                                action: generateInsight
                            )
                            .padding(.top, 20)
                        }
                    }
                }
                .padding(.top, 24)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
        .background(Color.vBackground)
        .task { await state.fetchInsight() }
        .sheet(isPresented: $showPayloadReview) {
            if let preview = state.weeklyInsightPreview {
                PayloadReviewSheet(preview: preview)
            }
        }
    }

    private var payloadButtonTitle: String {
        if isLoadingPreview { return "Loading preview..." }
        if state.weeklyInsightPreview == nil { return "Load AI payload" }
        return "Open AI payload"
    }

    private func reviewPayload() {
        guard !isLoadingPreview else { return }
        if state.weeklyInsightPreview != nil {
            showPayloadReview = true
            return
        }

        isLoadingPreview = true
        Task {
            await state.fetchInsightPreview()
            isLoadingPreview = false
            showPayloadReview = state.weeklyInsightPreview != nil
        }
    }

    private func generateInsight() {
        guard canGenerate else { return }
        isGenerating = true
        Task {
            await state.generateInsight()
            isGenerating = false
        }
    }
}

private struct InsightSummaryCard: View {
    let insight: WeeklyInsight
    let canGenerate: Bool
    let isGenerating: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                VLabelText(text: "Week of \(insight.weekStart)")
                Spacer()
                Text(insight.generatedAt)
                    .font(.system(size: 11))
                    .foregroundStyle(Color.vMutedForeground.opacity(0.7))
            }

            Text(insight.summary)
                .font(.system(size: 13))
                .lineSpacing(4)
                .foregroundStyle(Color.vForeground.opacity(0.8))
                .padding(.top, 16)

            SecondaryInsightButton(
                title: isGenerating ? "Generating..." : "Regenerate insight",
                isLoading: isGenerating,
                isEnabled: canGenerate,
                action: action
            )
            .padding(.top, 20)
        }
    }
}

private struct InsightEmptyState: View {
    let canGenerate: Bool
    let isGenerating: Bool
    let action: () -> Void
    @Environment(\.design) private var design

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 6) {
                Text("No insight generated yet")
                    .font(.system(size: 13))
                    .foregroundStyle(Color.vMutedForeground.opacity(0.6))
                Text("Generate a weekly analysis of your metabolic patterns.")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.vMutedForeground.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)

            Button(action: action) {
                Text(
                    isGenerating
                        ? "Generating..."
                        : (canGenerate ? "Generate insight" : "Review AI payload to continue")
                )
                .font(.system(size: 12, weight: .medium))
                .tracking(0.4)
                .foregroundStyle(Color.vBackground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(canGenerate ? Color.vForeground : Color.vForeground.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: design.buttonRadius))
            }
            .disabled(!canGenerate)
        }
    }
}

private struct SecondaryInsightButton: View {
    let title: String
    let isLoading: Bool
    let isEnabled: Bool
    let action: () -> Void
    @Environment(\.design) private var design

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                        .tint(Color.vMutedForeground)
                }
                Text(title)
            }
            .font(.system(size: 12, weight: .medium))
            .tracking(0.4)
            .foregroundStyle(Color.vMutedForeground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .overlay(
                RoundedRectangle(cornerRadius: design.buttonRadius)
                    .stroke(Color.vBorder, lineWidth: 0.5)
            )
        }
        .disabled(!isEnabled)
    }
}

private struct PayloadReviewSheet: View {
    let preview: WeeklyInsightPreview
    @Environment(\.dismiss) private var dismiss
    @Environment(\.design) private var design
    @State private var showSystemPrompt = false
    @State private var showUserPayload = true

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VCard {
                        VStack(alignment: .leading, spacing: 0) {
                            VLabelText(text: "Payload Review")
                            Text("Week of \(preview.weekStart) to \(preview.weekEnd)")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(Color.vForeground)
                                .padding(.top, 12)

                            Text("Review this before generating. The raw payload stays available here instead of crowding the main insights screen.")
                                .font(.system(size: 13))
                                .foregroundStyle(Color.vMutedForeground)
                                .lineSpacing(4)
                                .padding(.top, 12)
                        }
                    }

                    DisclosureGroup("System prompt", isExpanded: $showSystemPrompt) {
                        payloadBlock(preview.systemPrompt, monospaced: false)
                            .padding(.top, 12)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.vForeground)

                    DisclosureGroup("User payload", isExpanded: $showUserPayload) {
                        payloadBlock(preview.userPrompt, monospaced: true)
                            .padding(.top, 12)
                    }
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.vForeground)
                }
                .padding(20)
                .padding(.bottom, 32)
            }
            .background(Color.vBackground)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func payloadBlock(_ text: String, monospaced: Bool) -> some View {
        Text(text)
            .font(monospaced ? .system(size: 12, design: .monospaced) : .system(size: 12))
            .foregroundStyle(Color.vForeground.opacity(0.82))
            .lineSpacing(3)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Color.vCard)
            .overlay(
                RoundedRectangle(cornerRadius: design.buttonRadius)
                    .stroke(Color.vBorder, lineWidth: 0.5)
            )
            .clipShape(RoundedRectangle(cornerRadius: design.buttonRadius))
            .textSelection(.enabled)
    }
}
