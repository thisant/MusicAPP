import Foundation
import UIKit

//Singleton Pattern
final class LibraryAPI {
  
  static let shared = LibraryAPI()
  //Facade Pattern
  private let persistencyManager = PersistencyManager()
  private let httpClient = HTTPClient()
  private let isOnline = false
  //-----------------------------------------------------
  
  private init() {
    // Observer Pattern
    NotificationCenter.default.addObserver(self, selector: #selector(downloadImage(with:)), name: .DownloadImage, object: nil)
  }
  //Pega os albuns
  func getAlbums() -> [Album] {
    return persistencyManager.getAlbums()
  }
  //Adiciona album
  func addAlbum(_ album: Album, at index: Int) {
    persistencyManager.addAlbum(album, at: index)
    if isOnline {
      httpClient.postRequest("/api/addAlbum", body: album.description)
    }
  }
  //Deleta o album
  func deleteAlbum(at index: Int) {
    persistencyManager.deleteAlbum(at: index)
    if isOnline {
      httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
    }
  }
  // Baixando imagem e notificando
  @objc func downloadImage(with notification: Notification) {
    guard let userInfo = notification.userInfo,
      let imageView = userInfo["imageView"] as? UIImageView,
      let coverUrl = userInfo["coverUrl"] as? String,
      let filename = URL(string: coverUrl)?.lastPathComponent else {
        return
    }
    //Salva a imagem
    if let savedImage = persistencyManager.getImage(with: filename) {
      imageView.image = savedImage
      return
    }
    //Dispacha a imagem baixada 
    DispatchQueue.global().async {
      let downloadedImage = self.httpClient.downloadImage(coverUrl) ?? UIImage()
      DispatchQueue.main.async {
        imageView.image = downloadedImage
        self.persistencyManager.saveImage(downloadedImage, filename: filename)
      }
    }
  }
}
