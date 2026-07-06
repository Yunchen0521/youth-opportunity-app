import CoreLocation
import MapKit
import SwiftUI

/// 地圖頁（輔助）：只顯示有固定據點的機會；缺座標者用地址即時 geocode。
struct OpportunityMapView: View {
    @Environment(OpportunityStore.self) private var store

    @State private var positioned: [PositionedOpportunity] = []
    @State private var camera: MapCameraPosition = .region(.taiwan)
    @State private var selectedID: String?
    @State private var resolving = false

    var body: some View {
        NavigationStack {
            Map(position: $camera, selection: $selectedID) {
                ForEach(positioned) { item in
                    Marker(item.opportunity.title,
                           systemImage: item.opportunity.category.symbolName,
                           coordinate: item.coordinate)
                        .tint(Color.accentColor)
                        .tag(item.id)
                }
            }
            .overlay(alignment: .top) { banner }
            .overlay(alignment: .bottom) { selectedCard }
            .navigationTitle("地圖")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Opportunity.self) { opportunity in
                OpportunityDetailView(opportunity: opportunity)
            }
            .task(id: store.all.count) { await resolve() }
        }
    }

    private var banner: some View {
        Text(resolving ? "定位中…" : "地圖上 \(positioned.count) 個實體據點／活動")
            .font(.footnote.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .softGlassCapsule()
            .padding(.top, 10)
    }

    @ViewBuilder private var selectedCard: some View {
        if let selected = positioned.first(where: { $0.id == selectedID }) {
            NavigationLink(value: selected.opportunity) {
                OpportunityRow(opportunity: selected.opportunity)
                    .padding(14)
                    .softGlass(cornerRadius: 16)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)
        }
    }

    /// 把有據點的機會轉成座標；已有經緯度直接用，否則用地址 geocode。
    private func resolve() async {
        guard positioned.isEmpty, !store.mappable.isEmpty else { return }
        resolving = true
        defer { resolving = false }

        let geocoder = CLGeocoder()
        var result: [PositionedOpportunity] = []
        for opportunity in store.mappable {
            guard let location = opportunity.location else { continue }
            if let lat = location.latitude, let lon = location.longitude {
                result.append(.init(opportunity: opportunity,
                                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)))
            } else if let placemarks = try? await geocoder.geocodeAddressString(location.address),
                      let coordinate = placemarks.first?.location?.coordinate {
                result.append(.init(opportunity: opportunity, coordinate: coordinate))
            }
        }
        positioned = result
    }
}

/// 帶座標的機會（地圖標記用）。
struct PositionedOpportunity: Identifiable, Hashable {
    let opportunity: Opportunity
    let coordinate: CLLocationCoordinate2D

    var id: String { opportunity.id }

    static func == (lhs: PositionedOpportunity, rhs: PositionedOpportunity) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension MKCoordinateRegion {
    /// 涵蓋全台的預設視野。
    static let taiwan = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 23.8, longitude: 121.0),
        span: MKCoordinateSpan(latitudeDelta: 3.6, longitudeDelta: 3.6)
    )
}
