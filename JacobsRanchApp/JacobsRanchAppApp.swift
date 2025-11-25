import SwiftUI
import Supabase

@main
struct JacobsRanchAppApp: App {

    // Make Supabase a static global so it doesn't mutate self
    static let supabaseClient = SupabaseClient(
        supabaseURL: URL(string: "https://bzumocwgluhjbicqjioe.supabase.co")!,
        supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6dW1vY3dnbHVoamJpY3FqaW9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NjQwNDksImV4cCI6MjA3OTE0MDA0OX0.ID0ifV0DabZXGsPw4f05L9roYMKmFRt7yVyWS8RI6io"
    )

    @StateObject private var boardingInfo = BoardingInfo()
    @StateObject private var horsesVM = HorsesViewModel(client: supabaseClient)

    @AppStorage("isLoggedIn") private var isLoggedIn = false

    var body: some Scene {
        WindowGroup {
            RootView()
                .supabase(Self.supabaseClient)
                .environmentObject(boardingInfo)
                .environmentObject(horsesVM)
        }
    }
}

struct RootView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @EnvironmentObject private var boardingInfo: BoardingInfo
    @EnvironmentObject private var horsesVM: HorsesViewModel
    @Environment(\.supabase) private var supabase

    var body: some View {
        if isLoggedIn {
            NavigationStack {
                HomeView()
                    .task {
                        if let session = try? await supabase.auth.session {
                            let userId = session.user.id.uuidString

                            await boardingInfo.loadProfile(from: supabase, userId: userId)

                            await horsesVM.loadHorses(userId: userId)
                            boardingInfo.horseCount = horsesVM.horses.count

                            // NEW → load total users using WiFi
                            await boardingInfo.loadWifiSubscribers(from: supabase)
                        }
                    }
            }
        } else {
            SplashScreenView()
        }
    }
}
