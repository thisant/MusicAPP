import UIKit

class AlbumView: UIView {
  
  private var coverImageView: UIImageView!
  private var indicatorView: UIActivityIndicatorView!
  private var valueObservation: NSKeyValueObservation! //KVO Pattern
  
  //Destribuição dos objetos
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
 //Dimensão retangular das capas
  init(frame: CGRect, coverUrl: String) {
    super.init(frame: frame)
    commonInit()
    NotificationCenter.default.post(name: .DownloadImage, object: self, userInfo: ["imageView": coverImageView as Any, "coverUrl" : coverUrl])
  }
  
  private func commonInit() {
    // Background com cor do Aplicativo
    backgroundColor = .black
    // Criando a "view" da capa
    coverImageView = UIImageView()
    coverImageView.translatesAutoresizingMaskIntoConstraints = false
    
    //KVO Pattern
    valueObservation = coverImageView.observe(\.image, options: [.new]) { [unowned self] observed, change in
      if change.newValue is UIImage {
        self.indicatorView.stopAnimating()
      }
    }
    
    
    addSubview(coverImageView)
    // Indicador da "view"
    indicatorView = UIActivityIndicatorView()
    indicatorView.translatesAutoresizingMaskIntoConstraints = false
    indicatorView.style = .whiteLarge
    indicatorView.startAnimating()
    addSubview(indicatorView)
    //Posições no layout da tela
    NSLayoutConstraint.activate([
      coverImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 5),
      coverImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -5),
      coverImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5),
      coverImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5),
      indicatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
      indicatorView.centerYAnchor.constraint(equalTo: self.centerYAnchor)
      ])
  }
  //Cor de backgroud da "view"
  func highlightAlbum(_ didHighlightView: Bool) {
    if didHighlightView == true {
      backgroundColor = .white
    } else {
      backgroundColor = .black
    }
  }
  
}
