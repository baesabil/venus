import SwiftUI

/// Pilihan tahun (baris atas) dan bulan (baris bawah), ibarat laci arsip.
struct MonthYearPicker: View {
    let years: [Int]
    @Binding var selectedYear: Int
    @Binding var selectedMonth: Int
    /// Berapa note di bulan tertentu (untuk badge angka kecil).
    let countForMonth: (Int) -> Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(years, id: \.self) { year in
                        chip(String(year), selected: year == selectedYear) {
                            selectedYear = year
                        }
                    }
                }
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(1...12, id: \.self) { month in
                        chip(Calendar.current.shortMonthSymbols[month - 1],
                             selected: month == selectedMonth,
                             badge: countForMonth(month)) {
                            selectedMonth = month
                        }
                    }
                }
            }
        }
    }

    private func chip(_ title: String, selected: Bool, badge: Int = 0, action: @escaping () -> Void) -> some View {
        Button {
            HapticsManager.shared.tick()
            withAnimation(.snappy) { action() }
        } label: {
            HStack(spacing: 6) {
                Text(title).font(.subheadline.weight(.semibold))
                if badge > 0 {
                    Text("\(badge)")
                        .font(.caption2.weight(.bold))
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(selected ? Color.white.opacity(0.25) : Theme.ink.opacity(0.1), in: Capsule())
                }
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background(selected ? Theme.ink : Theme.surface, in: Capsule())
            .foregroundStyle(selected ? Color.white : Theme.ink)
        }
        .buttonStyle(.plain)
    }
}
