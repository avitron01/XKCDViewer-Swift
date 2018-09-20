//
//    ComicServiceManager.swift
//
//    Copyright (c) 2018 avitron01
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.
//

import Foundation

typealias LastestIssueCompletion = (Result<Comic>) -> Void
typealias IssueListCompletion = (Result<[Comic]>) -> Void

class ComicServiceManager {
    static let shared = ComicServiceManager()
    var comicList = [Comic]()
    
    var latestIssueNumber: Int? {
        didSet {
            if let issueNumber = latestIssueNumber {
                issuesRemaining = issueNumber
            }
        }
    }
    var issuesRemaining = 0
    
    func fetchLatestIssue(completion: @escaping LastestIssueCompletion) {
        let endPoint = APIURL.latest
        
        APIManager.fetchData(for: endPoint, type: Comic.self) { result in
            switch result {
            case .success(let comic):
                self.handleLatestComicResult(comic)
            case .error(_):
                break
            }
            completion(result)
        }
    }
    
    func handleLatestComicResult(_ comic: Comic?) {
        guard let comic = comic else {
            print("No comic found")
            return
        }
        
        latestIssueNumber = comic.num
        comicList.append(comic)
    }
    
    //TODO: Need to look into this, very fragile for now
    func fetchIssues(for count: Int, completion: @escaping IssueListCompletion) {
        if let _ = latestIssueNumber {
            let endRange = issuesRemaining
            let startRange = issuesRemaining - count
            for i in startRange...endRange {
                fetchComic(for: i) { result in
                    switch result {
                    case .success(let comic):
                        self.handleComicFetch(for: comic)
                    case .error(_):
                        break
                    }
                    
                    if self.issuesRemaining == startRange {
                        completion(Result.success(self.comicList))
                    }
                }
            }
        } else {
            fetchLatestIssue { result in
                self.fetchIssues(for: count, completion: completion)
            }
        }
    }
    
    func fetchComic(for num: Int, completion: @escaping LastestIssueCompletion) {
        let endPoint = APIURL.issue(num)
        
        APIManager.fetchData(for: endPoint, type: Comic.self) { result in
            completion(result)
        }
    }
    
    func handleComicFetch(for comic: Comic?) {
        guard let comic = comic else {
            print("No comic found")
            return
        }
        
        issuesRemaining -= 1
        comicList.append(comic)
    }
}
