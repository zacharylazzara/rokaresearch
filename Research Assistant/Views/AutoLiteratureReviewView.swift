//
//  ImportView.swift
//  Research Assistant
//
//  Created by Zachary Lazzara on 2021-06-09.
//

/* TODO:
 - Import from HTTPS links (give warning when using HTTP but allow users to override if they want to)
 - Import from external databases (may be unable to implement this depending on database APIs)
 - Import from scanned documents (camera; allow photos and also pulling text from photos and converting to text format (keep original photo in these cases, just in case))
 - Import from cloud/network drives
 - iCloud integration (automatically synchronize between device and iCloud if user allows it)
 */

import SwiftUI
import PDFKit

struct AutoLiteratureReviewView: View {
    @EnvironmentObject var dirVM: DirectoryViewModel
    @EnvironmentObject var nlVM: NaturalLanguageViewModel
    @State private var link: String = "" // TODO: download from link somehow
    private let cgfWidth: CGFloat = 5
    
    // From: http://dx.doi.org/10.1016/j.neunet.2016.11.003
    // Using this text for testing purposes for now.
    @State private var citation: String = "The hard problem of consciousness is the problem of explaining how we experience qualia or phenome- nal experiences, such as seeing, hearing, and feeling, and knowing what they are. To solve this problem, a theory of consciousness needs to link brain to mind by modeling how emergent properties of several brain mechanisms interacting together embody detailed properties of individual conscious psychologi- cal experiences. This article summarizes evidence that Adaptive Resonance Theory, or ART, accomplishes this goal. ART is a cognitive and neural theory of how advanced brains autonomously learn to attend, rec- ognize, and predict objects and events in a changing world. ART has predicted that ‘‘all conscious states are resonant states’’ as part of its specification of mechanistic links between processes of consciousness, learning, expectation, attention, resonance, and synchrony. It hereby provides functional and mechanistic explanations of data ranging from individual spikes and their synchronization to the dynamics of con- scious perceptual, cognitive, and cognitive–emotional experiences. ART has reached sufficient maturity to begin classifying the brain resonances that support conscious experiences of seeing, hearing, feeling, and knowing. Psychological and neurobiological data in both normal individuals and clinical patients are clarified by this classification. This analysis also explains why not all resonances become conscious, and why not all brain dynamics are resonant. The global organization of the brain into computationally com- plementary cortical processing streams (complementary computing), and the organization of the cerebral cortex into characteristic layers of cells (laminar computing), figure prominently in these explanations of conscious and unconscious processes. Alternative models of consciousness are also discussed."
    
    // From: DOI 10.1007/s11023-014-9352-8
    // Using this text for testing purposes for now.
    @State private var thesis: String = "If a brain is uploaded into a computer, will consciousness continue in digital form or will it end forever when the brain is destroyed? Philosophers have long debated such dilemmas and classify them as questions about personal identity. There are currently three main theories of personal identity: biological, psycho- logical, and closest continuer theories. None of these theories can successfully address the questions posed by the possibility of uploading. I will argue that uploading requires us to adopt a new theory of identity, psychological branching identity. Psychological branching identity states that consciousness will continue as long as there is continuity in psychological structure. What differentiates this from psychological identity is that it allows identity to continue in multiple selves. According to branching identity, continuity of consciousness will continue in both the original brain and the upload after nondestructive uploading. Branching identity can also resolve long standing questions about split-brain syndrome and can provide clear predictions about identity in even the most difficult cases imagined by philosophers."
    
    @State private var tKeywords: Array<String> = []
    @State private var cKeywords: Array<String> = []
    
    
    //    private var nlViewModel = NaturalLanguageViewModel(doc1: "", doc2: "")
    
    /* TODO:
     We're gonna want to utilize the share menu so we can easily send documents to the app; perhaps we shouldn't even offer the link download option under Import?
     */
    
    // TODO: change this to be the auto-literature review system
    
    var body: some View {
        VStack(alignment: .leading) {
//            Button(action: { analyse() }) {
//                Text("\(Image(systemName: "doc.text.magnifyingglass")) Begin Analysis")
//            }
            /* TODO:
             This view will need to be a list view allowing the user to compare a number of documents. The most relevant document can be put at the top of the list.
             Documents in the list should display a relevance score, this will be based on keywords.
             
             Rather than searching through all documents at first, we can allow the user to select specific documents to search, or search all. We will determine the initial relevancy based on keyword matching. When matching keywords we must take into account the nearest neighbours of each word (words with similar meanings should be included in the matching process, but perhaps with slightly less weight than directly matching words). We may also want to compare abstracts before comparing full documents, as comparing the full document can take a very long time.
             */
            
            ProgressView(value: nlVM.progress)
            
            Divider()
            
            VStack(alignment: .leading) {
                List {
                    ForEach(nlVM.args, id: \.self) { tArg in
                        if tArg.args.count > 0 {
                            HStack(alignment: .top) {
                                Color.blue.frame(width: cgfWidth)
                                VStack(alignment: .leading) {
                                    Text("Thesis Statement:").bold()
                                    tArgView(cgfWidth: cgfWidth, arg: tArg).fixedSize(horizontal: false, vertical: true)
                                    Divider()
                                    Text("Citation Statement(s):").bold()
                                    ForEach(tArg.args, id: \.self) { cArg in
                                        cArgView(cgfWidth: cgfWidth, arg: cArg).fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                        }
                    }
                    HStack(alignment: .center) {
                        Spacer()
                        if nlVM.compareProgress <= 0 {
                            Button(action: { analyse() }) {
                                Text("\(Image(systemName: "doc.text.magnifyingglass")) Begin Analysis")
                            }
                        } else if nlVM.percent >= 100 {
                            Text("Analysis Complete").bold()
                        } else {
                            Text("Analysis Progress:").bold()
                            Text("\(nlVM.percent)% (\(nlVM.compareProgress)/\(nlVM.totalCompares))")
                        }
                        Spacer()
                    }
                }
                keywords()
            }
        }
        .padding()
        .navigationTitle("Auto-Literature Review")
        Spacer()
    }
    
    
    /* TODO:
     We need to scan through all directories within the library, and pull all relevant papers. Perhaps we can match keywords to determine relevance before we commit further computer resources.
     The thesis should be uploaded from outside the app. A file picker should show up allowing the user to select their thesis PDF.
     */
    

    
    
    
    
    
    private func analyse() {
        let docs = loadDocs()
        //thesis =
        citation = docs[0]
        
        
        nlVM.citations(for: thesis, from: citation) // nlViewModel.nearestArgs(for: nlViewModel.citations(for: thesis, from: citation))
        nlVM.keywords(for: thesis)
        nlVM.keywords(for: citation)
        print("\nKeywords: \(nlVM.keywords)")
        
        
        // TODO: everything in the nlVM needs to be on a separate thread, as these things can take a long time depending on source size
        // TODO: make sure to put keywords on a new thread as well as we've seen it does freeze the main thread for a moment
        
        
        
        //tArgs = nlViewModel.args
        //cArgs = nlViewModel.citations(for: citation, from: thesis) // nlViewModel.nearestArgs(for: nlViewModel.citations(for: citation, from: thesis))
        
        /* TODO: Remove all this temporary code
         
         For now I'll be testing the functionality of the natural language view model by testing it here.
         Will need to make a dictionary or list of all the texts in the repository, so that we can search through everything to find the relevant papers.
         */
        
        // TODO: Now we should be able to start making dictionaries of similarity and use the sentiment to roughly determine level of agreement
        // This may be of value: https://www.slideshare.net/vicknickkgp/analyzing-arguments-during-a-debate-using-natural-language-processing-in-python
        
        //print(nlViewModel.citations(for: thesis, from: citation))
        
    }
    
    private func loadDocs() -> [String] {
        var documents: Array<String> = []
        dirVM.loadDir().forEach { file in
            if !file.isHidden() || dirVM.showHidden {
                if let dir = file as? Directory {
                    // File is a directory
                    // TODO: we'll want to navigate through and load all subdirectories as well
                    
//                    Button(action: { changeDir(dir: dir) }) {
//                        Text("\(Image(systemName: "folder")) \(file.name)")
//                    }
                } else {
                    // File is not a directory
                    
                    // TODO: we should make sure the file type is a supported type (in this case a pdf)
                    
                    
                    // Adapted from: https://www.hackingwithswift.com/example-code/libraries/how-to-extract-text-from-a-pdf-using-pdfkit
                    if let pdf = PDFDocument(url: file.url) {
                        let pageCount = pdf.pageCount
                        let documentContent = NSMutableAttributedString()

                        for i in 0 ..< pageCount {
                            guard let page = pdf.page(at: i) else { continue }
                            guard let pageContent = page.attributedString else { continue }
                            documentContent.append(pageContent)
                        }
                        documents.append(documentContent.string)
                    }
                }
            }
        }
        return documents
    }

    
    private func search() {
        /* TODO:
         Upload thesis (need a Word plugin, maybe even the ability to pull form Word? could do OneDrive integration so we can pull relevant files directly?)
         Search through library
         Search through databases (maybe)
         */
    }
    
    
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        AutoLiteratureReviewView()
    }
}

struct tArgView: View {
    let cgfWidth:CGFloat
    var arg: Argument
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("\(arg.sentence)\n")
                
                HStack(alignment: .top) {
                    Text("Sentiment:").bold()
                    Text("\(arg.sentiment == 0 ? "Neutral" : arg.sentiment > 0 ? "Positive" : "Negative")")
                }
            }
            Spacer()
        }
    }
}

struct cArgView: View {
    let cgfWidth: CGFloat
    let cgfHeight: CGFloat = 20
    var arg: Argument
    
    var body: some View {
        HStack(alignment: .top) {
            if arg.supporting! {
                Color.green.frame(width: cgfWidth)
            } else {
                Color.red.frame(width: cgfWidth)
            }
            
            VStack(alignment: .leading) {
                Text("\(arg.sentence)\n")
                
                HStack(alignment: .center) {
                    Text("Sentiment:").bold()
                    Text("\(arg.sentiment == 0 ? "Neutral" : arg.sentiment > 0 ? "Positive" : "Negative")\t")
                    
                    Divider().frame(height: cgfHeight)
                    Text("Relevance:").bold()
                    Text("\(arg.distance! < 0.5 ? "High" : arg.distance! < 1 ? "Medium" : "Low")\t")
                    
                    Divider().frame(height: cgfHeight)
                    Text("Supporting:").bold()
                    Text("\(arg.supporting! ? "Yes" : "No")")
                }
            }
            Spacer()
        }
    }
}

struct keywords: View {
    @EnvironmentObject var nlVM: NaturalLanguageViewModel
    
    var body: some View {
        Text("Keywords:").bold()
        HStack {
            ForEach(nlVM.keywords.map{$0.0}, id: \.self) { keyword in
                Text("\(keyword)")
            }
        }
    }
}

//struct analysisProgress: View {
//    @EnvironmentObject var nlVM: NaturalLanguageViewModel
//
//    var body: some View {
//        HStack(alignment: .center) {
//            Spacer()
//            if nlVM.percent <= 0 {
//                Button(action: { analyse() }) {
//                    Text("\(Image(systemName: "doc.text.magnifyingglass")) Begin Analysis")
//                }
//            } else if nlVM.percent >= 100 {
//                Text("Analysis Complete").bold()
//            } else {
//                Text("Analysis Progress:").bold()
//                Text("\(nlVM.percent)% (\(nlVM.compareProgress)/\(nlVM.totalCompares))")
//            }
//            Spacer()
//        }
//    }
//}
