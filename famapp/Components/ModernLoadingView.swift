import SwiftUI

// MARK: - Modern Loading View

struct ModernLoadingView: View {
    var icon: String = "arrow.clockwise"
    var message: String = "Loading..."
    var iconSize: CGFloat = 60

    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .light))
                .foregroundColor(.orange)
                .rotationEffect(.degrees(isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    var icon: String
    var title: String
    var message: String?
    var iconSize: CGFloat = 60

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .light))
                .foregroundColor(.secondary.opacity(0.6))

            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)

            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Pulsing Loading Indicator

struct PulsingLoadingView: View {
    var icon: String = "circle.fill"
    var message: String = "Loading..."
    var iconSize: CGFloat = 50

    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 1.0

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .medium))
                .foregroundColor(.orange)
                .scaleEffect(scale)
                .opacity(opacity)
                .onAppear {
                    withAnimation(
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                    ) {
                        scale = 1.2
                        opacity = 0.6
                    }
                }

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Bouncing Dots Loading

struct BouncingDotsView: View {
    var message: String = "Loading..."
    var dotSize: CGFloat = 12
    var color: Color = .orange

    @State private var animatingDot = 0

    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(color)
                        .frame(width: dotSize, height: dotSize)
                        .offset(y: animatingDot == index ? -10 : 0)
                }
            }
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { _ in
                    withAnimation(.easeInOut(duration: 0.3)) {
                        animatingDot = (animatingDot + 1) % 3
                    }
                }
            }

            Text(message)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background)
    }
}

// MARK: - Loading Card Overlay

struct LoadingCardOverlay: View {
    var icon: String = "arrow.clockwise"
    var message: String = "Processing..."

    @State private var isAnimating = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 40, weight: .medium))
                    .foregroundColor(.orange)
                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
                    .animation(
                        .linear(duration: 1.5)
                        .repeatForever(autoreverses: false),
                        value: isAnimating
                    )

                Text(message)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.black.opacity(0.8))
            )
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Preview

struct ModernLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ModernLoadingView(
                icon: "arrow.clockwise",
                message: "Loading data..."
            )
            .previewDisplayName("Modern Loading")

            EmptyStateView(
                icon: "doc.text.magnifyingglass",
                title: "No Results",
                message: "Try adjusting your search criteria"
            )
            .previewDisplayName("Empty State")

            PulsingLoadingView(
                icon: "circle.hexagongrid.fill",
                message: "Syncing..."
            )
            .previewDisplayName("Pulsing Loading")

            BouncingDotsView(message: "Please wait...")
                .previewDisplayName("Bouncing Dots")
        }
    }
}
