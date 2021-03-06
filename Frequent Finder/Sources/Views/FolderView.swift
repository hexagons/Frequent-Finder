//
//  FolderView.swift
//  Frequent Finder
//
//  Created by Hexagons on 2020-01-29.
//  Copyright © 2020 Hexagons. All rights reserved.
//

import SwiftUI

struct FolderView: View {
    @EnvironmentObject var ff: FF
    @ObservedObject var folder: Folder
    var body: some View {
        VStack {
            List {
                Section(header: ZStack {
                    HStack {
                        Button(action: {
                            self.ff.goUp()
                        }) {
                            Text("Up")
                        }
                            .disabled(!ff.canGoUp)
                        NameView(path: folder, font: .headline)
                        PathActionView(path: folder as Path)
                        Spacer()
                    }
                }) {
                    Group {
                        if folder.contents != nil {
                            ForEach(folder.contents!) { path in
                                PathView(path: path)
                                    .padding(.top, self.over(limits: [10, 100, 1000], for: path) ? 15 : 0)
                            }
                        } else {
                            Text("Loading...")
                        }
                    }
                }
            }
            HStack {
                Group {
                    ForEach(folder.components, id: \.self) { component in
                        Button(action: {
                            guard let folder: Folder = self.folder(from: component) else { return }
                            self.ff.navigate(to: folder)
                        }) {
                            NameView(path: self.folder(from: component) ?? Folder(URL(fileURLWithPath: "/"), at: 0))
                        }
                            .disabled(component == self.folder.components.last)
                    }
                }
                    .offset(x: 5, y: -5)
                Spacer()
            }
        }
        .onAppear {
            self.folder.fetchContents(done: {})
        }
    }
    func folder(from component: String) -> Folder? {
        let allSections: [String] = self.folder.components.map({ String($0) })
        var targetSections: [String] = []
        guard let index: Int = self.folder.components.firstIndex(of: component) else { return nil }
        for (i, section) in allSections.enumerated() {
            guard i <= index else { break }
            targetSections.append(section)
        }
        let url: URL = URL(fileURLWithPath: "/" + targetSections.joined(separator: "/"))
        let frequencyCount: Int = FF.frequencyCount(for: url)
        let folder: Folder = Folder(url, at: frequencyCount)
        return folder
    }
    func over(limits: [Int], for path: Path) -> Bool {
        for limit in limits {
            if over(limit: limit, for: path) {
                return true
            }
        }
        return false
    }
    func over(limit: Int, for path: Path) -> Bool {
        guard path.frequencyCount < limit else { return false }
        guard let contents: [Path] = self.folder.contents else { return false }
        guard let index: Int = contents.firstIndex(where: { $0.url == path.url }) else { return false }
        let prevIndex: Int = index - 1
        guard prevIndex >= 0 else { return false }
        let prevPath: Path = contents[prevIndex]
        guard prevPath.frequencyCount >= limit else { return false }
        return true
    }
}

struct FolderView_Previews: PreviewProvider {
    static var previews: some View {
        FolderView(folder: Folder(URL(fileURLWithPath: "/Users/hexagons/Documents"), at: -1))
            .environmentObject(FF.shared)
    }
}
