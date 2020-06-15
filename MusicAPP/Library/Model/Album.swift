import Foundation

//Arquivação e Serialização
struct Album: Codable {
  let title : String
  let artist : String
  let genre : String
  let coverUrl : String
  let year : String
}
//Representação textual das variáveis
extension Album: CustomStringConvertible {
  var description: String {
    return "title: \(title)" +
      " artist: \(artist)" +
      " genre: \(genre)" +
      " coverUrl: \(coverUrl)" +
    " year: \(year)"
  }
}
//Decorator Pattern
typealias AlbumData = (title: String, value: String)

extension Album {
  var tableRepresentation: [AlbumData] {
    return [
      ("Artist", artist),
      ("Title", title),
      ("Genre", genre),
      ("Year", year)
    ]
  }
}
