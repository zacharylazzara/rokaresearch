//
//  ContentViewModel.swift
//  Research Assistant
//
//  Created by Zachary Lazzara on 2021-06-08.
//

import Foundation

/* TODO:
 - Load PDFs from local storage
 - Load PDFs from web (HTTPS; may need to give an option to allow HTTP as well)
 - Need to make sure we're doing file navigation properly; want to avoid duplicating things in memory
 */

class DirectoryViewModel: ObservableObject {
    private let fm: FileManager
    private let rootURL: URL
    
    @Published public var directory: Directory
    @Published public var showHidden: Bool
    
    init() {
        self.fm = FileManager.default
        self.rootURL = AppGroup.library.containerURL.appendingPathComponent("Library", isDirectory: true).appendingPathComponent("Papers", isDirectory: true)
        self.showHidden = false
        
        print("Root URL: \(self.rootURL)")
        
        if !self.fm.fileExists(atPath: self.rootURL.path) {
            do {
                print("\(self.rootURL.lastPathComponent) doesn't exist! Creating directory...")
                try self.fm.createDirectory(at: self.rootURL, withIntermediateDirectories: true, attributes: nil)
                print("Successfully created \(self.rootURL.lastPathComponent)!")
            } catch {
                print(error)
            }
        }
        
        self.directory = Directory(url: self.rootURL, name: self.rootURL.lastPathComponent)
        self.directory.children = load(dir: self.directory)
    }
    
    // TODO: we can use .DS_Store to store our custom attributes such as which files are flagged etc
    // TODO: look into  https://developer.apple.com/documentation/appkit/nsoutlineview
    // TODO: Also look into outline groups (this is what we'd use for iOS I think) https://developer.apple.com/documentation/swiftui/outlinegroup
    // TODO: we need to auto-update the view when the directory's children change (currently view only updates when the directory changes, but not when it gets new folders)
    
    public func changeDir(dir: Directory) { // TODO: maybe check to make sure we don't try to change to a data file vs a directory?
        self.directory = dir
    }
    
    public func loadData(doc: Document) -> Data {
        return try! doc.read()
    }
    
    public func loadDir() -> [File] {
        return self.directory.children!
    }
    
    private func load(dir: Directory) -> [File]? {
        print("Loading from directory: \(dir.name)")
        
        var children = [File]()
        let fileChildren: [URL]
        
        do {
            fileChildren = try fm.contentsOfDirectory(at: dir.url, includingPropertiesForKeys: nil) // TODO: look into includingPropertiesForKeys, maybe we can get dates and such with it?
        } catch {
            print(error)
            return nil
        }
        
        print("Found: \(fileChildren)")
        
        for url in fileChildren {
            let child: File
            
            if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory)! {
                child = Directory(url: url, name: url.lastPathComponent, parent: dir)
                (child as! Directory).children = load(dir: child as! Directory)
            } else {
                child = Document(url: url, name: url.lastPathComponent, parent: dir)
            }
            
            children.append(child)
            //children?.sort()
        }
        
        return children
        
        
        
        
//        if let dir = file as? Directory {
//            print("File is a directory")
//
//            var children = [File]()
//            let fileChildren: [URL]
//
//            do {
//                fileChildren = try fm.contentsOfDirectory(at: dir.url, includingPropertiesForKeys: nil) // TODO: look into includingPropertiesForKeys, maybe we can get dates and such with it?
//            } catch {
//                print(error)
//                return nil
//            }
//
//            print("Found: \(fileChildren)")
//
//            for url in fileChildren {
//                let child: File
//
//                if (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory)! {
//                    child = Directory(url: url, name: url.lastPathComponent, parent: dir)
//                    (child as! Directory).children = load(file: child as! Directory)
//                } else {
//                    child = Document(url: url, name: url.lastPathComponent, parent: dir)
//                }
//
////                if let childDir = child as? Directory {
////                    childDir.children = load(file: childDir)
////                }
//
//                children.append(child)
//                //children?.sort()
//            }
//
//            return children
//        } else {
//            return nil
//        }
    }
    
    public func createDir(name: String = "New Folder") {
        var uName = name
        var collisions = 0
        
        while self.directory.children!.contains(where: {file in file.name == uName}) {
            uName = name
            collisions += 1
            uName = "\(uName)(\(collisions))"
        }
        
        do {
            let newDir = Directory(url: self.directory.url.appendingPathComponent(uName), name: uName, parent: self.directory)
            try fm.createDirectory(at: newDir.url, withIntermediateDirectories: false, attributes: nil)
            newDir.children = load(dir: newDir)
            self.directory.children?.append(newDir)
            
            // TODO: we need to refresh the view somehow! Ideally it would be done as a result of data changing, but if that's not feasible we can just do it here somehow
        } catch {
            print(error)
        }
    }
    
    public func delete(offsets: IndexSet, file: File) {
        
        
        
        //try! self.directory.remove(offsets: offsets)
        
        
        //try! fm.trashItem(at: file.url, resultingItemURL: nil) // TODO: we can get the URL of the file in the trash if we want to let users restore it (add this in later)
        
        
    }
}
