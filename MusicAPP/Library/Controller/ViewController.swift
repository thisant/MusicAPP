import UIKit

final class ViewController: UIViewController {
  //celulas de dados e indice do album atual
  private enum Constants {
    static let CellIdentifier = "Cell"
    static let IndexRestorationKey = "currentAlbumIndex"
  }
  //Tabelas
  @IBOutlet var tableView: UITableView!
  @IBOutlet weak var horizontalScrollerView: HorizontalScrollerView!
  
  //Delegate Pattern 
  private var currentAlbumIndex = 0
  private var currentAlbumData: [AlbumData]?
  private var allAlbums = [Album]()
  
  //Controle da view carregado na memoria
  override func viewDidLoad() {
    super.viewDidLoad()
    
    allAlbums = LibraryAPI.shared.getAlbums()
    
    tableView.dataSource = self
    horizontalScrollerView.dataSource = self
    horizontalScrollerView.delegate = self
    horizontalScrollerView.reload()
    showDataForAlbum(at: currentAlbumIndex)
  }
  //Controle da view atual
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    horizontalScrollerView.scrollToView(at: currentAlbumIndex, animated: false)
  }
  
  private func showDataForAlbum(at index: Int) {
    //Verifica se o índice solicitado é menor que a quantidade de álbuns
    if (index < allAlbums.count && index > -1) {
      // Busca o album
      let album = allAlbums[index]
      // Salvar dados do ultimo album na tableview
      currentAlbumData = album.tableRepresentation
    } else {
      currentAlbumData = nil
    }
    // Atualizar todos os dados da tableview
    tableView.reloadData()
  }
  
}

//Gerencia dados e fornece células para a tableview
extension ViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let albumData = currentAlbumData else {
      return 0
    }
    return albumData.count
  }
  //Apresenta os dados/celulas nas colunas da tabela
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifier, for: indexPath)
    if let albumData = currentAlbumData {
      let row = indexPath.row
      cell.textLabel!.text = albumData[row].title
      cell.detailTextLabel!.text = albumData[row].value
    }
    return cell
  }
}//--------------------------------------------------------------------------
//Importado na classe HorizontalScrollerView
extension ViewController: HorizontalScrollerViewDelegate {
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, didSelectViewAt index: Int) {
    //Indice do album anterior
    let previousAlbumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    previousAlbumView.highlightAlbum(false)
    //indice do album atual
    currentAlbumIndex = index
    //Mostra o album
    let albumView = horizontalScrollerView.view(at: currentAlbumIndex) as! AlbumView
    albumView.highlightAlbum(true)
    //Dados do album atual
    showDataForAlbum(at: index)
  }
}
//Controla o numero de views
extension ViewController: HorizontalScrollerViewDataSource {
  func numberOfViews(in horizontalScrollerView: HorizontalScrollerView) -> Int {
    return allAlbums.count
  }
  //Controla a movimentação o scroller por index de cada view
  func horizontalScrollerView(_ horizontalScrollerView: HorizontalScrollerView, viewAt index: Int) -> UIView {
    let album = allAlbums[index]
    let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), coverUrl: album.coverUrl)
    if currentAlbumIndex == index {
      albumView.highlightAlbum(true)
    } else {
      albumView.highlightAlbum(false)
    }
    return albumView
  }
}

//Memento Pattern
extension ViewController {
  //Armazena dados da ultima instância
  override func encodeRestorableState(with coder: NSCoder) {
    coder.encode(currentAlbumIndex, forKey: Constants.IndexRestorationKey)
    super.encodeRestorableState(with: coder)
  }
  //Restaura dados
  override func decodeRestorableState(with coder: NSCoder) {
    super.decodeRestorableState(with: coder)
    currentAlbumIndex = coder.decodeInteger(forKey: Constants.IndexRestorationKey)
    showDataForAlbum(at: currentAlbumIndex)
    horizontalScrollerView.reload()
  }
  
}

