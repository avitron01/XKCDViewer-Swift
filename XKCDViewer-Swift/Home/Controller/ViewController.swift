//
//    ViewController.swift
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

import UIKit

protocol LatestComicProtocol {
    func fetchLatestIssue()
    func handleLatestComicResult(_ comic: Comic?)
    func handleLatestComicFailure(_ error: Error?)
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchLatestIssue()
    }
    
}

extension ViewController: LatestComicProtocol {
    func fetchLatestIssue() {
        ComicServiceManager.fetchLatestIssue { result in
            switch result {
            case .success(let comic):
                self.handleLatestComicResult(comic)
            case .error(let error):
                self.handleLatestComicFailure(error)
            }
        }
    }
    
    func handleLatestComicResult(_ comic: Comic?) {
        guard let comic = comic else {
            print("No latest comic found")
            return
        }
        
        print(comic)
    }
    
    func handleLatestComicFailure(_ error: Error?) {
        guard let error = error else {
            print("No error object to handle")
            return
        }
        
        print(error)
    }
}
