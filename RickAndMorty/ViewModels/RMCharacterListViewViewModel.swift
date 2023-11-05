//
//  RMCharacterListViewViewModel.swift
//  RickAndMorty
//
//  Created by Olexandr Kostenko on 05.11.2023.
//

import UIKit

protocol RMCharacterListViewViewModelDelegate: AnyObject {
    func didLoadInitialCharacters()
    func didSelectCharacter(_ character: RMCharacter)
}

final class RMCharacterListViewViewModel: NSObject {
    
    public weak var delegate: RMCharacterListViewViewModelDelegate?
    
    private var isLoadingMoreCharacters: Bool = false
    
    private var characters: [RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                cellViewModels.append(viewModel)
            }
        }
    }
    
    private var cellViewModels: [RMCharacterCollectionViewCellViewModel] = []
    
    private var apiInfo: RMGetAllCharactersResponse.Info? = nil
    
    public func fetchCharacters() {
        
        /// Fetch initial set of characters
        RMService.shared.execute(
            .listCharactersRequests,
            expecting: RMGetAllCharactersResponse.self
        ) { [weak self] result in
            switch result {
            case .success (let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.characters = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure (let error):
                print(String(describing: error))
            }
        }
    }
    
    /// Pagianate if additionsl characters are needed
    public func fetchAdditionalCharacters(url: URL) {
        isLoadingMoreCharacters = true
        print("Fetching more characters from \(String(describing: url))")
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            print("Faild to create request")
            return
        }
        RMService.shared.execute(
            request,
            expecting: RMGetAllCharactersResponse.self) { result in
                switch result {
                case .success(let model): print(String(describing: model))
                case .failure(let error): print(String(describing: error))
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator: Bool {
        return apiInfo?.next != nil
    }
}

extension RMCharacterListViewViewModel: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RMCharacterCollectionViewCell.cellIdentifier,
            for: indexPath
        ) as? RMCharacterCollectionViewCell else {
            fatalError("Unsupported cell")
        }
        
        cell.configure(with: cellViewModels[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
                let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: RMFooterLoadingCollectionReusableView.indentifier,
                    for: indexPath
                ) as? RMFooterLoadingCollectionReusableView else {
            fatalError("Unsupported")
        }
        
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let bounds = UIScreen.main.bounds.width
        let width = (bounds-30)/2
        return CGSize(width: width, height: width*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}

extension RMCharacterListViewViewModel: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard 
            shouldShowLoadMoreIndicator,
            !isLoadingMoreCharacters,
            let nextUrlString = apiInfo?.next,
            let url = URL(string: nextUrlString) else {
                return
        }
        let offset = scrollView.contentOffset.y
        let totlaContentHeight = scrollView.contentSize.height
        let totalScrollViewHeight = scrollView.frame.size.height
        
        if offset >= (totlaContentHeight - totalScrollViewHeight - 120) {
            fetchAdditionalCharacters(url: url)
        }
    }
}
