import SwiftUI

struct FilterBarView: View {
    @Binding var selectedFilter: FilterType
    let filterCounts: [FilterType: Int]
    let onFilterSelected: (FilterType) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(FilterType.allCases) { filter in
                    FilterTabButton(
                        filter: filter,
                        count: filterCounts[filter] ?? 0,
                        isSelected: selectedFilter == filter,
                        action: {
                            onFilterSelected(filter)
                        }
                    )
                }
            }
        }
        .background(Color(UIColor.systemBackground))
    }
}

struct FilterTabButton: View {
    let filter: FilterType
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 4) {
                    Text(filter.rawValue)
                        .font(.subheadline)
                    if count > 0 {
                        Text("(\(count))")
                            .font(.subheadline)
                    }
                }
                .foregroundColor(isSelected ? .primary : .secondary)
                .fontWeight(isSelected ? .semibold : .regular)

                // Underline indicator
                Rectangle()
                    .fill(isSelected ? Color.primary : Color.clear)
                    .frame(height: 2)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }
}

