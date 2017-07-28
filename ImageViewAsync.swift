//
//  ImageViewAsync.swift
//  UiUtilsTestApp
//
//  Created by Gentner, Sebastian on 03.07.17.
//  Copyright © 2017 Datagroup Mobile Solutions AG. All rights reserved.
//

// TODO replace print logs
// TODO remove debug delay
// TODO handle offline

import Foundation
import UIKit

typealias WebURL = URL
typealias FilePathURL = URL

func debugDelay() -> DispatchTimeInterval {
    print()
    let seconds : UInt32 = 1 // max
    return DispatchTimeInterval.milliseconds(Int(arc4random_uniform(seconds * 1000)))
}

class ImageViewAsync : UIImageView, ImageViewAsyncDownloaderDelegate {

    // MARK: - Public
    
    /// image view shows cached image, if available
    public var useCache : Bool = true
    
    /// image view shows UIActivityIndicatorView while downloading
    public var showsIndicator : Bool = true
    public var vActivity : UIActivityIndicatorView = UIActivityIndicatorView()
    
    /// image view shows placeholder if download failed
    public var showsPlaceholder : Bool = true
    
    /// image view animates transition between loading <-> image
    public var animatesTransition : Bool = true
    
    // image view shows additional blur view between image + indicator
    public var showsBlurOverlay : Bool = true
    
    // MARK: - Readonly
    
    /// image view is currently downloading
    public private(set) var isDownloading : Bool = false {
        didSet {
            if isDownloading {
                
                if showsBlurOverlay {
                    vBlur.isHidden = false
                }
                
                if showsIndicator {
                    vActivity.isHidden = false
                    vActivity.startAnimating()
                }
                else {
                    vActivity.isHidden = true
                    vActivity.stopAnimating()
                }
                
            } else {
                vActivity.isHidden = true
                vActivity.stopAnimating()
                
                vBlur.isHidden = true
            }
        }
    }
    
    public private(set) var webURL : WebURL

    // MARK: - Private
    
    private let imgPlaceholderDefault : UIImage = {
        return UIImage(named: "placeholder.png")! // todo bundle, draw?
        // TODO set custom placeholder
    }()
    
    private let imageViewAsyncDownloader = ImageViewAsyncDownloader()
    
    private let vBlur = UIVisualEffectView(effect: UIBlurEffect(style: UIBlurEffectStyle.extraLight))
    
    // MARK: - Init
    
    deinit {
        // todo cleanup
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(webURL: WebURL) {
        self.webURL = webURL
        
        super.init(frame: .zero)
        
        setup()
    }
    
    func setup() {
        imageViewAsyncDownloader.delegate = self
    
        vBlur.isHidden = true
        addSubview(vBlur)
        
        vActivity = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        vActivity.isHidden = true
        vActivity.stopAnimating()
        addSubview(vActivity)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        vBlur.frame = bounds
        vActivity.frame = bounds
    }
    
    // MARK: - Lifecycle
    
    func start() {
        
        var img : UIImage? = nil
        
        if useCache {
            img = ImageViewAsyncCache.loadCachedImage(with: self.webURL) ?? nil
        }
        
        if img != nil {
            print("use cached image")
            swapToImage(img!)
        }
        else {
            if useCache {
                print("no cached image found, start download")
            }
            
            isDownloading = true
            imageViewAsyncDownloader.startDownload(with: self.webURL)
        }
    }
    
    func cancel() {
        imageViewAsyncDownloader.cancel()
    }
    
    // remove cached image
    func clearCache() {
        ImageViewAsyncCache.removeImage(with: self.webURL)
    }
    
    func refresh() {
        clearCache()
        start()
    }

    func nuke() {
        ImageViewAsyncCache.nuke()
    }
    
    /// clears cache with current url, replace url and refresh
    ///
    ///
    func reloadWithNew(webURL : WebURL) {
        clearCache()
        self.webURL = webURL
        start()
    }
    
    // MARK: - ImageViewAsyncDownloaderDelegate
    
    func downloaded(image: UIImage) {
        self.isDownloading = false
        self.swapToImage(image)
        
        if useCache {
            if !ImageViewAsyncCache.save(image: image, webURL: self.webURL) {
                print("error saving image")
            }
        }
    }
    
    func failed(webURL: WebURL?) {
        self.isDownloading = false
        // TODO show if set showsPlaceholder
        self.swapToPlaceholder()
    }
    
    // swap image
    
    func swapToPlaceholder() {
        swapToImage(self.imgPlaceholderDefault)
    }
    
    func swapToImage(_ image : UIImage) {
        
        // rotate
        // rotate(image)
        
        // plop
        plop(image)
        
        // cross dissolve
        // crossDisolve(image)
    }
    
    func rotate(_ image: UIImage) {
        self.layer.transform = CATransform3DMakeRotation(.pi, 1.0, 0.0, 0.0);
        self.image = image
        
        UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            //
            self.layer.transform = CATransform3DIdentity
        }) { (finished) in
            //
        }
    }
    
    func plop(_ image: UIImage) {
        // random rotation direction
        let direction : CGFloat = CGFloat((arc4random() % 2 == 0) ? 1.0 : -1.0)
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1).concatenating(CGAffineTransform(rotationAngle: direction * 1.5 * .pi))
        self.image = image
        
        UIView.animate(withDuration: 0.50, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.8, options: [], animations: {
            //
            self.transform = .identity
        }) { (finished) in
            //
        }
    }
    
    func crossDisolve(_ image: UIImage) {
        UIView.transition(with: self, duration: animatesTransition ? 1.0 : 0.0, options: .transitionCrossDissolve, animations: {
            self.image = image
        }, completion: nil)
    }
}

protocol ImageViewAsyncDownloaderDelegate {
    func downloaded(image: UIImage)
    func failed(webURL: WebURL?)
}

class ImageViewAsyncDownloader : NSObject, URLSessionDownloadDelegate {
    
    var delegate : ImageViewAsyncDownloaderDelegate?
    
    private var session : URLSession?
    
    private func currentSession() -> URLSession {
        if let s = session {
            // session still valid
            return s
        }
        else {
            // create session
            let config = URLSessionConfiguration.default
            
            // disable session cache, use device cache
            config.requestCachePolicy = .reloadIgnoringCacheData
            config.urlCache = nil
        
            session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
            return session!
        }
    }
    
    func cancel() {
        currentSession().getTasksWithCompletionHandler { (tasks, uploads, downloads) in
            downloads.forEach({ (downloadTask) in
                downloadTask.cancel()
            })
        }
    }
    
    func startDownload(with webURL: WebURL) {
        // is already running
        
        let taskDescription = webURL.filenameBase64
        
        var alreadyRunning = false
                
        currentSession().getTasksWithCompletionHandler { [weak self] (tasks, uploads, downloads) in
            
            guard let this = self else {return}
            
            downloads.forEach({ (downloadTask) in
                
                if downloadTask.taskDescription == taskDescription {
                    
                    if downloadTask.state == .running {
                        alreadyRunning = true
                    }
                }
            })
            
            if !alreadyRunning {
                let task : URLSessionDownloadTask = this.currentSession().downloadTask(with: webURL)
                task.taskDescription = taskDescription
                task.resume()
                
                print("(+) startDownload task with url: \(webURL.absoluteString) filename (task description): \(task.taskDescription ?? "empty")")
                print("\n")
            } else {
                print("♽ already started task with url: \(webURL.absoluteString) filename (task description): \(taskDescription)")
                print("\n")
            }
        }
    }
    
    // session & download delegate
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        self.session = nil
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let e = error {
            print(e)
            
            if let err = error {
                print(err)
                // TODO handle
            }
            
            DispatchQueue.global().asyncAfter(deadline: .now() + debugDelay(), execute: {
                DispatchQueue.main.sync {
                    let urlString = task.taskDescription?.fromBase64() ?? ""
                    let url = URL(string: urlString)
                    self.delegate?.failed(webURL: url ?? nil)
                }
            })
            
        } else {
            // success handled via session:downloadTask:didFinishDownloadingTo
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        var success = false
 
        let data = try? Data(contentsOf: location)
        
        if let imageData = data {
            
            if let img = UIImage(data: imageData) {
                success = true
                
                // todo remove debug after delay
                
                DispatchQueue.global().asyncAfter(deadline: .now() + debugDelay(), execute: {
                    DispatchQueue.main.sync {
                        self.delegate?.downloaded(image: img)
                    }
                })
            }
        }
        
        if !success {
            
            // todo remove debug after delay
            
            DispatchQueue.global().asyncAfter(deadline: .now() + debugDelay(), execute: {
                DispatchQueue.main.sync {
                    let urlString = downloadTask.taskDescription?.fromBase64() ?? ""
                    let url = URL(string: urlString)
                    self.delegate?.failed(webURL: url ?? nil)
                }
            })
        }
    }
}

class ImageViewAsyncCache {
    
    private static let foldername = "imageViewAsyncCache"
    
    private static var cacheDir : String? {
        let caches = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        var dir : String?
        
        if let cd = caches.first {
            dir = (cd as NSString).appendingPathComponent(foldername)
        }
        
        return dir
    }
    
    /// check base64
    
    // TODO FIX base64 with / ...
    
    /// in
    /// webURL: https://lorempixel.com/100/100/
    
    /// out
    /// filePathURL: file:///Users/sgentner/Library/Developer/CoreSimulator/Devices/15A4BFCD-BBDE-4FD9-B472-AA1BADADE92B/data/Containers/Data/Application/B369A1EE-3F44-48E0-88EF-3E573B979A72/Library/Caches/imageViewAsyncCache/aHR0cHM6Ly9sb3JlbXBpeGVsLmNvbS8xMDAvMTAwLw==
    ///
    static func imageFilePathURL(from webURL: WebURL) -> FilePathURL? {
        guard let cd = cacheDir else {return nil}
        let filepath = (cd as NSString).appendingPathComponent(webURL.filenameBase64)
        return URL(fileURLWithPath: filepath)
    }
    
    /// in
    /// filePathURL: file:///Users/sgentner/Library/Developer/CoreSimulator/Devices/15A4BFCD-BBDE-4FD9-B472-AA1BADADE92B/data/Containers/Data/Application/B369A1EE-3F44-48E0-88EF-3E573B979A72/Library/Caches/imageViewAsyncCache/aHR0cHM6Ly9sb3JlbXBpeGVsLmNvbS8xMDAvMTAwLw==
    ///
    /// out
    /// webURL: https://lorempixel.com/100/100/
    ///
    static func webURL(from imageFilePathURL: FilePathURL) -> WebURL? {
        let filename = imageFilePathURL.lastPathComponent
        return URL(string: filename.fromBase64() ?? "") ?? nil
    }
    
    static func loadCachedImage(with webURL: WebURL) -> UIImage? {

        if let fileurl = imageFilePathURL(from: webURL) {
            
            do {
                let imageData = try Data(contentsOf: fileurl)
                return UIImage(data: imageData)
            }
            catch {}
        }

        return nil
    }
    
    /// cache jpeg representation of image
    ///
    static func save(image: UIImage, webURL: WebURL) -> Bool {
        guard let cd = cacheDir else {return false}
        
        var saved = false
        
        let fm = FileManager.default
        
        if !fm.fileExists(atPath: cd) {
            
            let url = URL(fileURLWithPath: cd, isDirectory: true)
            
            do {
                try fm.createDirectory(at: url, withIntermediateDirectories: false, attributes: nil)
            } catch {
                return false
            }
        }
        
        // imageAsync cache dir exists, now save image
        
        if fm.fileExists(atPath: cd) {
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                
                if let filePathURL : FilePathURL = imageFilePathURL(from: webURL) {
                    
                    do {
                        try? imageData.write(to: filePathURL)
                        saved = true
                    }
                }
            }
        }
        
        if !saved {
             print("error! image data stored in cache")
        }
        
        return saved
    }
    
    /// removed specific cached image with webURL
    ///
    @discardableResult static func removeImage(with webURL: WebURL) -> Bool {
        var success = false
        
        let fm = FileManager.default
        
        if let filePathURL = imageFilePathURL(from: webURL) {
            
            let path = filePathURL.path
            
            if fm.fileExists(atPath: path) {
                do {
                    try fm.removeItem(atPath: path)
                     success = true
                     print("removed cached image for webURL " + webURL.absoluteString)
                } catch { }
            }
        }
        
        return success
    }
    
    /// clears all cached images
    ///
    static func nuke() {
        guard let cd = cacheDir else {return}
        
        let fm = FileManager.default
        
        do {
            let filepathes = try fm.contentsOfDirectory(atPath: cd)
            
            for filepath in filepathes {
                do {
                    try? fm.removeItem(atPath: (cd as NSString).appendingPathComponent(filepath))
                }
            }
        } catch {}
    }
}

// MARK: - Helper

fileprivate extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

fileprivate extension URL {
    var filenameBase64 : String {
        return self.absoluteString.toBase64()
    }
}
