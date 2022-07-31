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

    @State private var selectedItem: NavViewState.CurrentView? = .available
    @State private var navVisibility: NavigationSplitViewVisibility = .all

    var body: some View {
        NavigationSplitView(columnVisibility: $navVisibility) {
            VStack {
                List(selection: $selectedItem) {
                    Section(header: Text("Browse")) {
                        Label("Available", systemImage: "clock")
                            .tag(NavViewState.CurrentView.available)
                        Label("This Week", systemImage: "calendar")
                            .tag(NavViewState.CurrentView.thisWeek)
                        Label("Last Week", systemImage: "calendar")
                            .tag(NavViewState.CurrentView.lastWeek)
                    }
                    Section(header: Text("Contexts")) {
                        ForEach(state.tags, id: \.id) { tag in
                            Label {
                                HStack(alignment: .center, spacing: 3) {
                                    Text(tag.name)

                                    Text(tag.pendingTasks == 0 ? "" : String(tag.pendingTasks))
                                        .foregroundColor(.red)
                                        .font(.caption.monospacedDigit())
                                        .baselineOffset(6)
                                    Spacer()
                                }
                            } icon: {
                                Image(systemName: tag.totalTasks > 0 ? "tag" : "tag.slash")
                            }
                            .badge(tag.totalTasks)
                            .onDrag {
                                NSItemProvider(object: tag.draggable())
                            } preview: {
                                TagPreview(tag)
                            }
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
            }
            .navigationSplitViewColumnWidth(180)
        } detail: {

            switch selectedItem {
                case .available:
                    AvailableView()
                case .thisWeek:
                    WeeklyView(date: Date())
                case .lastWeek:
                    WeeklyView(date: Date().lastWeek())
                default:
                    Text("Select View")
            }
        }
        .navigationSplitViewStyle(.prominentDetail)

        .alert(state.error?.localizedDescription ?? "Error", isPresented: $state.showAlert) {}

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
    }

    @ViewBuilder
    private func TagPreview(_ tag: TagManager.Tag) -> some View {
        Label {
            Text(tag.name)
        } icon: {
            Image(systemName: "tag")
        }
        .fixedSize()
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .foregroundColor(.white)
        .background(Color.accentColor)
        .clipShape(RoundedRectangle(cornerRadius: 4, style: .circular))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .frame(width: 800, height: 600)
    }
}
