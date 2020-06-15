import Foundation
import UIKit

//Singleton Pattern
final class PersistencyManager {
  private var albums = [Album]()
  
  init() {
    //Atribuindo uma constante URL
    let savedURL = documents.appendingPathComponent(Filenames.Albums)
    var data = try? Data(contentsOf: savedURL)
    if data == nil, let bundleURL = Bundle.main.url(forResource: Filenames.Albums, withExtension: nil) {
      data = try? Data(contentsOf: bundleURL)
    }
    //Instancia do arquivo JSon
    if let albumData = data,
      let decodedAlbums = try? JSONDecoder().decode([Album].self, from: albumData) {
      albums = decodedAlbums
      saveAlbums()
    }
  }
  //Retorna os Albuns
  func getAlbums() -> [Album] {
    return albums
  }
  //Adiciona os albuns ao index
  func addAlbum(_ album: Album, at index: Int) {
    if (albums.count >= index) {
      albums.insert(album, at: index)
    } else {
      albums.append(album)
    }
  }
  //Deleta os albuns
  func deleteAlbum(at index: Int) {
    albums.remove(at: index)
  }
  //Armazena a URL em cache
  private var cache: URL {
    return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
  }
  
  //Salvando Imagem
  func saveImage(_ image: UIImage, filename: String) {
    let url = cache.appendingPathComponent(filename)
    guard let data = image.pngData() else {
      return
    }
    try? data.write(to: url, options: [])
  }
  //Pegando Imagem
  func getImage(with filename: String) -> UIImage? {
    let url = cache.appendingPathComponent(filename)
    guard let data = try? Data(contentsOf: url) else {
      return nil
    }
    return UIImage(data: data)
  }
  //Declarando variavél
  private var documents: URL {
    return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
  }
  //Declaração de variável enumerada
  private enum Filenames {
    static let Albums = "albums.json"
  }
  //Salvando albuns
  func saveAlbums() {
    let url = documents.appendingPathComponent(Filenames.Albums)
    let encoder = JSONEncoder()
    guard let encodedData = try? encoder.encode(albums) else {
      return
    }
    try? encodedData.write(to: url)
  }
  
}
