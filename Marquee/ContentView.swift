//

import SwiftUI

extension View {
    func measureWidth(_ onChange: @escaping (CGFloat) -> ()) -> some View {
        background {
            GeometryReader { proxy in
                let width = proxy.size.width
                Color.clear
                    .onAppear {
                        onChange(width)
                    }.onChange(of: width) { _ in
                        onChange(width)
                    }
            }
        }
    }
}

struct Marquee<Content: View>: View {
    var velocity: Double = 50
    var spacing: CGFloat = 10
    @ViewBuilder var content: Content
    @State private var startDate = Date.now
    @State private var contentWidth: CGFloat? = nil
    @State private var containerWidth: CGFloat? = nil

    func offset(at time: Date) -> CGFloat {
        var result = time.timeIntervalSince(startDate) * -velocity
        if let c = contentWidth {
            result.formTruncatingRemainder(dividingBy: c + spacing)
        }
        return result
    }

    var body: some View {
        TimelineView(.animation) { context in
            HStack(spacing: spacing) {
                HStack(spacing: spacing) {
                    content
                }
                .measureWidth { contentWidth = $0 }
                let contentPlusSpacing = ((contentWidth ?? 0) + spacing)
                if contentPlusSpacing != 0 {
                    let numberOfInstances = Int(((containerWidth ?? 0) / contentPlusSpacing).rounded(.up))
                    ForEach(Array(0..<numberOfInstances), id: \.self) { _ in
                        content
                    }
                }
            }
            .offset(x: offset(at: context.date))
            .fixedSize()
        }
        .onAppear { startDate = .now }
        .frame(maxWidth: .infinity, alignment: .leading)
        .measureWidth { containerWidth = $0 }
    }
}

struct ContentView: View {
    var body: some View {
        Marquee {
            ForEach(0..<5) { i in
                Text("Item \(i)")
                    .padding()
                    .foregroundColor(.white)
                    .background {
                        Capsule()
                            .fill(.blue)
                    }
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
