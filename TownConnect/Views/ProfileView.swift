import SwiftUI
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject var userStore: UserStore
    @State private var showingEdit = false

    var body: some View {
        NavigationStack {
            if let me = userStore.currentUser {
                VStack(spacing: 16) {
                    AvatarView(data: me.avatarData)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color("PrimaryBlue"), lineWidth: 2))

                    Text(me.fullName).font(.title2).bold()
                    Text("@\(me.username)").foregroundColor(.secondary)
                    Text(me.bio).multilineTextAlignment(.center)
                    WrapChips(chips: me.interests)
                    Spacer()
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") { showingEdit = true }
                    }
                }
                .sheet(isPresented: $showingEdit) {
                    EditProfileView(user: me)
                        .environmentObject(userStore)
                }
            } else {
                ProgressView()
            }
        }
    }
}

struct AvatarView: View {
    let data: Data?
    var body: some View {
        if let data, let ui = UIImage(data: data) {
            Image(uiImage: ui).resizable().scaledToFill()
        } else {
            ZStack { Circle().fill(Color.gray.opacity(0.2)); Image(systemName: "person.fill").font(.largeTitle) }
        }
    }
}

struct WrapChips: View {
    let chips: [String]
    var body: some View {
        FlexibleView(data: chips, spacing: 8, alignment: .leading) { item in
            Text(item).padding(.horizontal, 10).padding(.vertical, 6)
                .background(Color("SecondaryGreen").opacity(0.15))
                .foregroundColor(Color("PrimaryBlue"))
                .clipShape(Capsule())
        }
    }
}

struct FlexibleView<Data: Collection, Content: View>: View where Data.Element: Hashable {
    let data: Data
    let spacing: CGFloat
    let alignment: HorizontalAlignment
    let content: (Data.Element) -> Content

    init(data: Data, spacing: CGFloat, alignment: HorizontalAlignment, @ViewBuilder content: @escaping (Data.Element) -> Content) {
        self.data = data
        self.spacing = spacing
        self.alignment = alignment
        self.content = content
    }

    var body: some View {
        VStack(alignment: alignment, spacing: spacing) {
            ForEach(computeRows(), id: \.self) { row in
                HStack(spacing: spacing) { ForEach(row, id: \.self) { content($0) } }
            }
        }
    }

    private func computeRows() -> [[Data.Element]] {
        var rows: [[Data.Element]] = [[]]
        var currentRowWidth: CGFloat = 0
        let maxWidth = UIScreen.main.bounds.width - 32
        for item in data {
            let itemWidth: CGFloat = CGFloat(String(describing: item).count * 8 + 24)
            if currentRowWidth + itemWidth > maxWidth {
                rows.append([item])
                currentRowWidth = itemWidth + spacing
            } else {
                rows[rows.count - 1].append(item)
                currentRowWidth += itemWidth + spacing
            }
        }
        return rows
    }
}
