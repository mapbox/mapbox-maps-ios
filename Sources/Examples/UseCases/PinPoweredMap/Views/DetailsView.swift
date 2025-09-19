import SwiftUI
import MapboxMaps

struct FeatureDetailsView: View {
    let feature: FeaturesetFeature
    @ObservedObject var favoritesManager: FavoritesManager
    let onDismiss: () -> Void

    @State private var detailedFeature: FeatureDetails?

    @State private var isFavorite: Bool

    init(feature: FeaturesetFeature, favoritesManager: FavoritesManager, onDismiss: @escaping () -> Void, detailedFeature: FeatureDetails? = nil) {
        self.feature = feature
        self.favoritesManager = favoritesManager
        self.onDismiss = onDismiss
        self.detailedFeature = detailedFeature

        isFavorite = favoritesManager.isFavorite(feature)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if detailedFeature != nil {
                    placecardContent
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                } else {
                    skeleton
                        .transition(.opacity.combined(with: .scale(scale: 1.05)))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: detailedFeature)
            .padding(.horizontal, 20)
            .padding(.vertical, 30)
        }
        .task {
            guard case JSONValue.string(let mapboxId)?? = feature.properties["mapbox_id"] else {
                print("Failed to extract mapbox_id from feature")
                return
            }

            do {
                detailedFeature = try await NetworkService.fetchDetails(mapboxId: mapboxId)
            } catch {
                print("Failed to fetch detailed feature: \(error)")
            }
        }
    }

    @ViewBuilder
    private var skeleton: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let wrappedName = feature.properties["name"], let unwrappedName = wrappedName, case let JSONValue.string(name) = unwrappedName {
                Text(name)
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.title2)
                    .fontWeight(.semibold)
            } else {
                Text("Unknown")
                    .font(.title2)
                    .fontWeight(.semibold)
            }

            // Skeleton loading placeholders
            VStack(alignment: .leading, spacing: 12) {
                // Rating skeleton
                HStack(spacing: 2) {
                    ForEach(0..<5) { _ in
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 12, height: 12)
                    }
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 30, height: 12)
                }

                // Address skeleton
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 180, height: 14)
                }

                // Phone skeleton
                HStack(spacing: 8) {
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 16, height: 16)
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 120, height: 14)
                }

                // Photo skeleton
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .cornerRadius(8)
            }
        }
    }

    @ViewBuilder
    private var placecardContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with icon and name
            HStack(alignment: .center, spacing: 12) {
                // Maki icon
                if case JSONValue.string(let icon)?? = feature.properties["icon"] {
                    Image(uiImage: UIImage(named: icon) ?? UIImage(systemName: "mappin")!)
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding(8)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: 0x0F38BF))
                        .clipShape(Circle())
                } else {
                    Image(systemName: "mappin")
                        .foregroundColor(.white)
                        .font(.title3)
                        .padding(8)
                        .frame(width: 40, height: 40)
                        .background(Color(hex: 0x0F38BF))
                        .clipShape(Circle())
                }

                if let name = detailedFeature?.properties.name {
                    Text(name)
                        .fixedSize(horizontal: false, vertical: true)
                        .font(.title)
                        .fontWeight(.semibold)
                }

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundColor(Color(hex: 0x23262D))
                        .frame(width: 40, height: 40)
                        .font(.title3.weight(.semibold))
                        .background(Color(hex: 0xF2F4F7))
                        .clipShape(Circle())
                }
            }
            .padding(.bottom, 16)

            VStack(alignment: .leading, spacing: 8) {
                let rating = feature.rating
                HStack(alignment: .center, spacing: 2) {
                    ForEach(0..<5) { index in
                        Image(systemName: index < Int(rating) ? "star.fill" :
                                Double(index) < rating ? "star.lefthalf.fill" : "star")
                        .foregroundColor(Color(hex: 0x0F38BF))
                        .font(.body)
                    }
                    Text(String(format: "%.1f", rating))
                        .foregroundStyle(Color(hex: 0x05070A))
                    .font(.title3)            }

                // Open status
                if let openHours = detailedFeature?.properties.metadata?.openHours {
                    let openStatus = openHours.openStatus
                    let color: Color = switch openStatus {
                    case .open: Color(hex: 0x09AA74)
                    case .opens: Color(hex: 0x05070A)
                    case .closed: .red
                    }
                    Text(openStatus.description + " ")
                        .foregroundColor(color)
                        .font(.title3.weight(openStatus == .opens ? .regular : .semibold))
                    +
                    Text(openHours.formattedStatus)
                        .font(.title3)
                        .foregroundColor(Color(hex: 0x05070A))

                }
            }

            // Address
            HStack(alignment: .center, spacing: 20) {
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color(hex: 0x23262D))
                Text(detailedFeature?.properties.address ?? "ー")
                    .font(.title3)
                Spacer()
                Button {
                    favoritesManager.toggleFavorite(for: feature)
                    isFavorite.toggle()
                } label: {
                    Image(isFavorite ? "heart.fill" : "custom.heart.badge.plus")
                        .font(.title)
                        .foregroundColor(isFavorite ? .red : .secondary)
                        .safeBounceSymbolEffect(value: isFavorite)
                }
            }

            // Phone
            if let phone = detailedFeature?.properties.metadata?.phone {
                HStack(spacing: 20) {
                    Image(systemName: "phone.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: 0x23262D))
                    Link(phone, destination: URL(string: "tel:\(phone)") ?? URL(string: "tel:00000000000")!)
                        .font(.title3)
                }
            }

            // Website
            if let website = detailedFeature?.properties.metadata?.website {
                HStack(spacing: 20) {
                    Image(systemName: "globe.americas.fill")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(Color(hex: 0x23262D))
                    Link(website, destination: URL(string: website) ?? URL(string: "https://example.com")!)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                }
            }

            // Photo
            if let photoURL = detailedFeature?.properties.metadata?.primaryPhoto ?? detailedFeature?.properties.metadata?.photos?.randomElement()?.url {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(maxHeight: 200)
                        .clipped()
                        .cornerRadius(8)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                        .cornerRadius(8)
                        .overlay(
                            ProgressView()
                        )
                }
                .padding(.vertical, 8)
            }

            // Description
            if let description = detailedFeature?.properties.metadata?.detailedDescription {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Description")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(hex: 0x05070A))

                    Text(description)
                        .font(.title3)
                        .foregroundStyle(Color(hex: 0x05070A))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer()
        }
    }
}

private extension View {
    func safeBounceSymbolEffect<U>(value: U) -> some View where U: Equatable {
        if #available(iOS 17.0, *) {
            return self.symbolEffect(.bounce, options: .speed(1.5), value: value)
        }
        return self
    }
}
