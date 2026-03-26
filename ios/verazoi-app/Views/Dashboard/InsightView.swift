import SwiftUI

struct InsightView: View {
    @Environment(AppState.self) private var state
    @State private var isGenerating = false
    @State private var isLoadingPreview = false

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

                        Button {
                            isLoadingPreview = true
                            Task {
                                await state.fetchInsightPreview()
                                isLoadingPreview = false
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if isLoadingPreview {
                                    ProgressView()
                                        .controlSize(.small)
                                        .tint(Color.vMutedForeground)
                                }
                                Text(isLoadingPreview ? "Loading preview..." : "Review AI payload")
                            }
                            .font(.system(size: 12, weight: .medium))
                            .tracking(0.4)
                            .foregroundStyle(Color.vMutedForeground)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.vBorder, lineWidth: 0.5)
                            )
                        }
                        .disabled(isLoadingPreview)
                        .padding(.top, 16)

                        if let preview = state.weeklyInsightPreview {
                            VStack(alignment: .leading, spacing: 0) {
                                VLabelText(text: "Week of \(preview.weekStart) to \(preview.weekEnd)")
                                    .padding(.top, 20)

                                Text("System prompt")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color.vMutedForeground)
                                    .padding(.top, 12)

                                Text(preview.systemPrompt)
                                    .font(.system(size: 12))
                                    .foregroundStyle(Color.vForeground.opacity(0.8))
                                    .lineSpacing(3)
                                    .padding(.top, 6)

                                Text("User payload")
                                    .font(.system(size: 11, weight: .medium))
                                    .foregroundStyle(Color.vMutedForeground)
                                    .padding(.top, 16)

                                Text(preview.userPrompt)
                                    .font(.system(size: 12, design: .monospaced))
                                    .foregroundStyle(Color.vForeground.opacity(0.8))
                                    .lineSpacing(3)
                                    .padding(.top, 6)
                            }
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

                            Button {
                                guard canGenerate else { return }
                                isGenerating = true
                                Task {
                                    await state.generateInsight()
                                    isGenerating = false
                                }
                            } label: {
                                HStack(spacing: 8) {
                                    if isGenerating {
                                        ProgressView()
                                            .controlSize(.small)
                                            .tint(Color.vMutedForeground)
                                    }
                                    Text(
                                        isGenerating
                                            ? "Generating..."
                                            : (state.weeklyInsightPreview == nil ? "Review AI payload to regenerate" : "Regenerate")
                                    )
                                }
                                .font(.system(size: 12, weight: .medium))
                                .tracking(0.4)
                                .foregroundStyle(Color.vMutedForeground)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.vBorder, lineWidth: 0.5)
                                )
                            }
                            .disabled(!canGenerate)
                            .padding(.top, 20)
                        } else {
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

                            Button {
                                guard canGenerate else { return }
                                isGenerating = true
                                Task {
                                    await state.generateInsight()
                                    isGenerating = false
                                }
                            } label: {
                                Text(
                                    isGenerating
                                        ? "Generating..."
                                        : (state.weeklyInsightPreview == nil ? "Review AI payload to continue" : "Generate insight")
                                )
                                    .font(.system(size: 12, weight: .medium))
                                    .tracking(0.4)
                                    .foregroundStyle(Color.vBackground)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 10)
                                    .background(canGenerate ? Color.vForeground : Color.vForeground.opacity(0.3))
                            }
                            .disabled(!canGenerate)
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
    }
}
