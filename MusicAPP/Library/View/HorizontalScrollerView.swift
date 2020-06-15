import UIKit

//Adapter Pattern
protocol HorizontalScrollerViewDataSource: class {
  //Qauntos "views" são necessários no horizontal scroller
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int
  //Exibição das "views"
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView
}

protocol HorizontalScrollerViewDelegate: class {
  // Delegate indica que indice do "view" foi selecionado na classe do Controller
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int)
}
//Criação do Scroller horizontal
class HorizontalScrollerView: UIView {
  weak var dataSource: HorizontalScrollerViewDataSource?
  weak var delegate: HorizontalScrollerViewDelegate?
  
  //Dimensões, preenchimento, deslocamento das views
  private enum ViewConstants {
    static let Padding: CGFloat = 10
    static let Dimensions: CGFloat = 100
    static let Offset: CGFloat = 100
  }
  
  // Zoom na "view"
  private let scroller = UIScrollView()
  
  // Conteudo da "view" numa area retangular
  private var contentViews = [UIView]()
  
  // Inicaliza scroll view com as dimensões corretas
  override init(frame: CGRect) {
    super.init(frame: frame)
    initializeScrollView()
  }
  // Inicaliza scroll view com a distribuição dos objetos
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    initializeScrollView()
  }
  
  func initializeScrollView() {
    scroller.delegate = self
    //Adiciona no final uma view no recebimento de todas as "views"
    addSubview(scroller)
    
    //Restringi o layout automático do scroller
    scroller.translatesAutoresizingMaskIntoConstraints = false
    
    //Ativa a interação com duas interfaces
    NSLayoutConstraint.activate([
      scroller.leadingAnchor.constraint(equalTo: self.leadingAnchor),
      scroller.trailingAnchor.constraint(equalTo: self.trailingAnchor),
      scroller.topAnchor.constraint(equalTo: self.topAnchor),
      scroller.bottomAnchor.constraint(equalTo: self.bottomAnchor)
      ])
    
    //Gesto de toque da "view"
    let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped(gesture:)))
    scroller.addGestureRecognizer(tapRecognizer)
  }
  // centralização e animação dos movimentos do scroller
  func scrollToView(at index: Int, animated: Bool = true) {
    let centralView = contentViews[index]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: animated)
  }
  //Indicador de toque da "view"
  @objc func scrollerTapped(gesture: UITapGestureRecognizer) {
    let location = gesture.location(in: scroller)
    guard
      let index = contentViews.firstIndex(where: { $0.frame.contains(location)})
      else { return }
    
    delegate?.horizontalScrollerView(self, didSelectViewAt: index)
    scrollToView(at: index)
  }
  //Gerencia o conteudo horizontal da view
  func view(at index :Int) -> UIView {
    return contentViews[index]
  }
  
  func reload() {
    // Verifica se existe uma fonte de dados, senão nada será carregado
    guard let dataSource = dataSource else {
      return
    }
    
    //Remove o indice antigo da view
    contentViews.forEach { $0.removeFromSuperview() }
    // Valor x inicial de cada "view"
    var xValue = ViewConstants.Offset
    // Busca e adiciona as novas "views"
    contentViews = (0..<dataSource.numberOfViews(in: self)).map {
      index in
      // Adiciona a "view"na posição correta
      xValue += ViewConstants.Padding
      let view = dataSource.horizontalScrollerView(self, viewAt: index)
      view.frame = CGRect(x: CGFloat(xValue), y: ViewConstants.Padding, width: ViewConstants.Dimensions, height: ViewConstants.Dimensions)
      scroller.addSubview(view)
      xValue += ViewConstants.Dimensions + ViewConstants.Padding
      // Armazena a "view" para que poder fazer referência depois
      return view
    }
    
    // Tamanho do horizontal scroller
    scroller.contentSize = CGSize(width: CGFloat(xValue + ViewConstants.Offset), height: frame.size.height)
  }
  
  //Centraliza a view atual
  private func centerCurrentView() {
    let centerRect = CGRect(
      origin: CGPoint(x: scroller.bounds.midX - ViewConstants.Padding, y: 0),
      size: CGSize(width: ViewConstants.Padding, height: bounds.height)
    )
    guard let selectedIndex = contentViews.firstIndex(where: { $0.frame.intersects(centerRect) })
      else { return }
    let centralView = contentViews[selectedIndex]
    let targetCenter = centralView.center
    let targetOffsetX = targetCenter.x - (scroller.bounds.width / 2)
    
    scroller.setContentOffset(CGPoint(x: targetOffsetX, y: 0), animated: true)
    delegate?.horizontalScrollerView(self, didSelectViewAt: selectedIndex)
  }
}

//Desacelera o scroller ao se aproximar da "view"
extension HorizontalScrollerView: UIScrollViewDelegate {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
      centerCurrentView()
    }
  }
  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    centerCurrentView()
  }
}

