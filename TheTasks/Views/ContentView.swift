//
//  ContentView.swift
//  TheTasks
//
//  Created by Keith Irwin on 6/19/22.
//

import SwiftUI
import UniformTypeIdentifiers

fileprivate struct TagOperation {
    var tag = TagManager.Tag(name: "New Tag")
    var presented = false
}

struct ContentView: View {

    @StateObject private var state = NavViewState()

    @State private var dropFocus = false
    @State private var tagRenameOp = TagOperation()
    @State private var tagDeleteOp = TagOperation()

    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section(header: Text("Browse")) {
                        NavigationLink(destination: AvailableView().frame(minWidth: 350), tag: NavViewState.CurrentView.available, selection: $state.activeView) {
                            Label("Available", systemImage: "clock")
                        }

                        NavigationLink(destination: WeeklyView(date: Date()).frame(minWidth: 350), tag: NavViewState.CurrentView.thisWeek, selection: $state.activeView) {
                            Label("This Week", systemImage: "calendar")
                        }

                        NavigationLink(destination: WeeklyView(date: Date().lastWeek()).frame(minWidth: 350), tag: NavViewState.CurrentView.lastWeek, selection: $state.activeView) {
                            Label("Last Week", systemImage: "calendar")
                        }
                    }

                    Section(header: Text("Context")) {
                        ForEach(state.tags, id: \.id) { tag in
                            Label {
                                Text(tag.name)
                            } icon: {
                                Image(systemName: "tag")
                            }
                            .onDrag { NSItemProvider(object: tag.draggable())}
                            .contextMenu {
                                Button("Rename Tag…") {
                                    tagRenameOp.tag = tag
                                    tagRenameOp.presented.toggle()
                                }
                                Button("Delete Tag…") {
                                    tagDeleteOp.tag = tag
                                    tagDeleteOp.presented.toggle()
                                }
                            }
                        }
                    }
                }
                .listStyle(.sidebar)
                .toolbar {
                    Button {
                        toggleSidebar()
                    } label: {
                        Image(systemName: "sidebar.left")
                    }
                }
                Spacer()
                HStack {
                    Button {
                        tagRenameOp.tag = TagManager.Tag(id: UUID(), name: "New Tag")
                        tagRenameOp.presented.toggle()
                    } label: {
                        Label("Add Tag", systemImage: "plus.circle")
                    }
                    .buttonStyle(.borderless)
                    Spacer()
                }
                .padding(.horizontal, 13)
                .padding(.bottom, 6)

                .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}
            }
            .frame(minWidth: 180, idealWidth: 180)

            // When you want to edit a tag, you have to use a modal form.
            .sheet(isPresented: $tagRenameOp.presented) {
                EditTagForm(tag: $tagRenameOp.tag) { newTag in
                    state.upsert(tag: newTag)
                }
            }

            // When you want to delete a tag, you have to click through a warning about how destructive it is.
            .confirmationDialog("Delete '\(tagDeleteOp.tag.name)'?", isPresented: $tagDeleteOp.presented) {
                Button("Delete", role: .destructive) {
                    state.delete(tag: tagDeleteOp.tag)
                }
            } message: {
                Text("This will remove the tag from all tasks, completed or not.")
            }

            Text("Pick a view")
        }
    }

    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
