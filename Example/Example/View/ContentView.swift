import SwiftUI

struct ContentView: View {
    @State var isInserterOnForSwiftUIList: Bool = true
    
    var body: some View {
        NavigationView {
            VStack {
                Text("""
                The "No Injector" variants showcase something before we apply injector(s) to it.
                """)
                List {
                    Section(header: Text("SwiftUI")) {
                        NavigationLink("List - With Sections") {
                            NavigationLazyView(SwiftUIListWithSections()
                                .navigationTitle("List - With Sections"))
                        }
                        
                        NavigationLink("List - Without Sections") {
                            NavigationLazyView(SwiftUIListNoSections()
                                .navigationTitle("List - Without Sections"))
                        }
                    }
                    /*
                    Section(header: Text("UIKit")) {
                        NavigationLink("UITableView - With Injector") {
                            NavigationLazyView(Text("stub with injector TODO")
                                .navigationTitle("UITableView - With Injector"))
                        }
                        
                        NavigationLink("UICollectionView - With Injector") {
                            NavigationLazyView(Text("stub with injector TODO")
                                .navigationTitle("UICollectionView - With Injector"))
                        }
                    }
                     */
                }
            }
            .navigationTitle("Examples")
        }
        
    }
}

/// Defer body evaluation of navigation destinations until navigated to: https://stackoverflow.com/questions/57594159/swiftui-navigationlink-loads-destination-view-immediately-without-clicking
struct NavigationLazyView<Content: View>: View {
    let build: () -> Content
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    var body: Content {
        build()
    }
}

#Preview {
    ContentView()
}
