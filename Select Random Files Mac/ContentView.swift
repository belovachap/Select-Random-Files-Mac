//
//  ContentView.swift
//  Select Random Files Mac
//
//  Created by Chapman on 7/2/24.
//

import SwiftUI

struct ContentView: View {
    @State var sourceFolder: URL? = nil
    @State var destinationFolder: URL? = nil
    @State var numFiles: Int = 5

    var body: some View {
        VStack {
            Button("Choose Source Folder") {
                self.selectSourceFolder()
            }
            Label("\(sourceFolder)", systemImage: "folder")
            Button("Choose Destination Folder") {
                self.selectDestinationFolder()
            }
            Label("\(destinationFolder)", systemImage: "folder")
            Stepper("Number of Files: \(numFiles)", value: $numFiles, in: 1...100)
            Button(action: {
                var files = [URL]()
                if let enumerator = FileManager.default.enumerator(at: sourceFolder!, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                    for case let fileURL as URL in enumerator {
                        do {
                            let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                            if fileAttributes.isRegularFile! {
                                files.append(fileURL)
                            }
                        } catch { print(error, fileURL) }
                    }
                    print(files)
                }
                files = Array(files.shuffled().prefix(numFiles))
                for f in files {
                    let dst = destinationFolder!.appendingPathComponent(f.lastPathComponent)

                    do { try FileManager.default.removeItem(at: dst) }
                    catch { print(error) }

                    do { try FileManager.default.copyItem(at: f, to: dst) }
                    catch { print(error) }
                }
            }, label: {
                Text("Copy")
            })
        }
        .padding()
    }
    
    func buildFolderPicker() -> NSOpenPanel {
        let folderChooserPoint = CGPoint(x: 0, y: 0)
        let folderChooserSize = CGSize(width: 500, height: 600)
        let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
        let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)
        
        folderPicker.canChooseDirectories = true
        folderPicker.canChooseFiles = false
        folderPicker.allowsMultipleSelection = false

        return folderPicker
    }

    func selectSourceFolder() {
        let folderPicker = buildFolderPicker()
        folderPicker.begin { response in
            if response == .OK {
                sourceFolder = folderPicker.url
            }
        }
    }
    
    func selectDestinationFolder() {
        let folderPicker = buildFolderPicker()
        folderPicker.begin { response in
            if response == .OK {
                destinationFolder = folderPicker.url
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
