//
//  SearchViewController.swift
//  NetlixClone
//
//  Created by 양중창 on 2020/03/24.
// Copyright © 2020 Netflex. All rights reserved.
//

import UIKit
import SnapKit

// 찾는 데이터 없으면 없다는 표시 나오는 기능 구현 => 체크해서 쓸데없는 부분 쳐낼것
// indicator
// 상세화면 구현

class SearchViewController: UIViewController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    // MARK: Search Result CollectionView Datas
    // 더미
    let data = ["3"]
    var filteredData = [String]()
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredData = data.filter({(dataString: String) -> Bool in
            return dataString.range(of: searchText, options: .caseInsensitive) != nil
        })
        searchView.searchResultCollectionView.reloadData()
    }
    
    private func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if (filteredItemCount == totalItemCount) {
            return
        } else if (filteredItemCount == 0 && contentsSearchBar.text?.isEmpty == false) {
            searchView.searchResultCollectionView.isHidden = true
            searchView.noSearchResultsLabel.isHidden = false
        } else if (filteredItemCount == 0 && contentsSearchBar.text?.isEmpty == true) {
            searchView.searchResultCollectionView.isHidden = false
            searchView.noSearchResultsLabel.isHidden = true
        } else {
            searchView.searchResultCollectionView.isHidden = false
            searchView.noSearchResultsLabel.isHidden = true
            print("검색 결과: \(filteredItemCount)개")
            
        }
    }
    
    private let flowLayout = FlowLayout(itemsInLine: 3, linesOnScreen: 3.5)
    
    // MARK: Properties
    private let searchView = SearchView()
    private let searchController = UISearchController(searchResultsController: nil)
    lazy var contentsSearchBar = self.searchController.searchBar
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        searchBarTextDidEndEditing(contentsSearchBar)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchView)
        setSearchBarInNavigation()
        setSearchController()
        setSearchView()
    }
    
    // MARK: SearchView 세팅
    private func setSearchView() {
        searchView.snp.makeConstraints { (make) -> Void in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(5)
            make.leading.equalTo(view.snp.leading).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-5)
        }
        
    }
    
    // MARK: SearchController - NavigationBar 세팅
    private func setSearchBarInNavigation() {
        // NavigationBar 투명하게 설정
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = UIColor.clear
        
        self.navigationItem.titleView = searchController.searchBar
        searchController.hidesNavigationBarDuringPresentation = false
        
        // searchTextField 내부 세팅
        contentsSearchBar.tintColor = UIColor.setNetfilxColor(name: .white)
        contentsSearchBar.placeholder = "검색"
        contentsSearchBar.setValue("취소", forKey: "cancelButtonText")
        contentsSearchBar.searchTextField.backgroundColor = UIColor.setNetfilxColor(name: .netflixDarkGray)
        contentsSearchBar.searchTextField.textColor = UIColor.setNetfilxColor(name: .netflixLightGray)
        contentsSearchBar.searchTextField.clearButtonMode = .always
        contentsSearchBar.searchTextField.leftView?.tintColor = UIColor.setNetfilxColor(name: .netflixLightGray)
        
    }
    
    // MARK: SearchView 세팅
    private func setSearchController() {
        searchView.searchResultCollectionView.dataSource = self
        searchView.searchResultCollectionView.delegate = self
        contentsSearchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        //        definesPresentationContext = true // iOS 13 미만에서만 해줌, 13은 필요없음. 서치바에 커서 올라가면 주변 어두워지는 기능
        filteredData = data
    }
    
}

// MARK: Search Result Collection View DataSource, Delegate
extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if isFiltering {
        //            setIsFilteringToShow(filteredItemCount: filteredData.count, of: data.count)
        //        }
        //        return self.filteredData.count
        return self.data.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SearchResultCollectionViewHeader.identifier, for: indexPath) as! SearchResultCollectionViewHeader
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentsBasicItem.identifier, for: indexPath) as? ContentsBasicItem
        
        //유진 - 바뀐 셀에 관련된 부분 configure에 더미 image 넣어서 사용하세유~
        // 임시 background
        //        cell?.backgroundColor = .white
        //        cell?.titleLabel.text = self.filteredData[indexPath.item
        
        cell?.configure(poster: UIImage(named: "posterCellDummy")!)
        
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //        print(filteredData[indexPath.item])
        print(data[indexPath.item])
        // request
//        delegate?.deliveryContentId(id: 3)
        let contentVC = ContentViewController()
        contentVC.modalPresentationStyle = .fullScreen
        present(contentVC, animated: true)
    }
}

// MARK: Search Result Collection View FlowLayout
extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return flowLayout.edgeInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return flowLayout.linesOnScreen
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return flowLayout.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return searchView.setFlowLayout()
    }
}

// MARK: Search Result Updating
extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        // 체크
        if isFiltering {
            setIsFilteringToShow(filteredItemCount: filteredData.count, of: data.count)
        }
        guard let searchText = contentsSearchBar.text else { return }
        filterContentForSearchText(searchText: searchText)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBarTextDidEndEditing(searchBar)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
    }
    
    // 텍스트 바뀔 때마다 요청
    //    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    //
    //    }
    
    // 다 입력하고 검색 버튼 누르면 요청
    //    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    //        <#code#>
    //    }
}

// MARK: 네비게이션바 때문에 가려져서 preferredStatusBarStyle 안먹히기 때문에 사용
extension UINavigationController {
    open override var preferredStatusBarStyle: UIStatusBarStyle {
       return topViewController?.preferredStatusBarStyle ?? .default
    }
}
