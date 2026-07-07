import CoreLocation
import MapKit
import SwiftUI

/// 詳情頁的據點小地圖：只在機會有固定地點（venue / 單址）時顯示。
/// 有經緯度直接用；沒有就用地址即時 geocode。點地圖可選 Apple / Google 地圖開啟導航。
struct VenueMapCard: View {
    let location: OppLocation

    @Environment(\.openURL) private var openURL
    @State private var coordinate: CLLocationCoordinate2D?
    @State private var showMapOptions = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("據點位置").font(.headline)

            Group {
                if let coordinate {
                    Map(initialPosition: .region(region(for: coordinate))) {
                        Marker(location.city, coordinate: coordinate)
                            .tint(Color.accentColor)
                    }
                    .allowsHitTesting(false)   // 地圖本身不互動，改用整塊點擊開啟外部地圖
                } else {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(.quaternary)
                        .overlay { ProgressView() }
                }
            }
            .frame(height: 180)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .contentShape(Rectangle())
            .onTapGesture { if coordinate != nil { showMapOptions = true } }

            if coordinate != nil {
                Label("點地圖用 Apple 地圖或 Google 地圖開啟導航", systemImage: "hand.tap")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .softGlass(cornerRadius: 14)
        .task(id: location.address) { await resolve() }
        .confirmationDialog("用哪個地圖開啟？", isPresented: $showMapOptions, titleVisibility: .visible) {
            Button("Apple 地圖") { openInAppleMaps() }
            Button("Google 地圖") { openInGoogleMaps() }
            Button("取消", role: .cancel) {}
        }
    }

    private func region(for c: CLLocationCoordinate2D) -> MKCoordinateRegion {
        MKCoordinateRegion(center: c,
                           span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    }

    private func resolve() async {
        if let lat = location.latitude, let lon = location.longitude {
            coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
            return
        }
        if let placemarks = try? await CLGeocoder().geocodeAddressString(location.address),
           let c = placemarks.first?.location?.coordinate {
            coordinate = c
        }
    }

    private func openInAppleMaps() {
        guard let c = coordinate else { return }
        let item = MKMapItem(placemark: MKPlacemark(coordinate: c))
        item.name = location.address
        item.openInMaps()
    }

    private func openInGoogleMaps() {
        guard let c = coordinate,
              let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(c.latitude),\(c.longitude)")
        else { return }
        openURL(url)   // 有裝 Google 地圖 App 會用 App 開，否則開網頁版
    }
}
