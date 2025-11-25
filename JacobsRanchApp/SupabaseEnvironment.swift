import SwiftUI
import Supabase

// Create a placeholder client (valid but never used)
private let placeholderClient = SupabaseClient(
    supabaseURL: URL(string: "https://bzumocwgluhjbicqjioe.supabase.co")!,
    supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ6dW1vY3dnbHVoamJpY3FqaW9lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM1NjQwNDksImV4cCI6MjA3OTE0MDA0OX0.ID0ifV0DabZXGsPw4f05L9roYMKmFRt7yVyWS8RI6io"
)

// MARK: Environment Key
struct SupabaseClientKey: EnvironmentKey {
    static let defaultValue = placeholderClient
}

extension EnvironmentValues {
    var supabase: SupabaseClient {
        get { self[SupabaseClientKey.self] }
        set { self[SupabaseClientKey.self] = newValue }
    }
}

// MARK: View Modifier
extension View {
    func supabase(_ client: SupabaseClient) -> some View {
        environment(\.supabase, client)
    }
}
