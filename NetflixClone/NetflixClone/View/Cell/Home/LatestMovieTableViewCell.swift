//
//  LatestMovieTableViewCell.swift
//  NetflixClone
//
//  Created by YoujinMac on 2020/04/01.
//  Copyright © 2020 Netflex. All rights reserved.
//

import UIKit


protocol LatestMovieTableViewCellDelegate: class {
    func didTabLatestMovieCell(id: Int) -> ()
}


class LatestMovieTableViewCell: UITableViewCell {
    
    static let indentifier = "LatestMoviewTC"
    
    //MARK: data
    private var idData = [Int]()
    private var posterData = [UIImage]()
    
    weak var delegate: LatestMovieTableViewCellDelegate?
    
    
    private let sectionHeight: CGFloat = 24
    
    private let collectionViewFlow = FlowLayout(itemsInLine: 1, linesOnScreen: 1)
    
    private let headerLabel = UILabel()

    private let contentsCollectionView: UICollectionView = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            return UICollectionView(frame: .zero, collectionViewLayout: layout)
        }()
    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.setNetfilxColor(name: UIColor.ColorAsset.backgroundGray)
        setUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -UI
    private func setUI() {
        let HeaderFont: UIFont = .boldSystemFont(ofSize: 16)
                
        headerLabel.text = "최신영화"
        headerLabel.font = HeaderFont
        headerLabel.backgroundColor = .clear
        headerLabel.textColor = UIColor.setNetfilxColor(name: UIColor.ColorAsset.white)
        
        contentsCollectionView.dataSource = self
        contentsCollectionView.delegate = self
        
        contentsCollectionView.register(ContentsBasicItem.self, forCellWithReuseIdentifier: ContentsBasicItem.identifier)
        
        contentsCollectionView.backgroundColor = UIColor.setNetfilxColor(name: UIColor.ColorAsset.backgroundGray)
        
        contentView.addSubview(headerLabel)
        contentView.addSubview(contentsCollectionView)
    }
    
    private func setConstraints() {
        let headerYMargin: CGFloat = 10
        let headerXMargin: CGFloat = 10
        
        headerLabel.snp.makeConstraints {
            $0.top.equalTo(headerYMargin)
            $0.leading.equalTo(headerXMargin)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(sectionHeight - headerYMargin)
        }
        
        contentsCollectionView.snp.makeConstraints {
            $0.top.equalTo(headerLabel.snp.bottom)
            $0.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    
    
    //MARK: -configure
    func configure(id: [Int], poster: [UIImage]) {
        self.idData = id
        self.posterData = poster
        print("Latest ----------> poster : \(poster)")
        contentsCollectionView.reloadData()
    }
    
}

//MARK: -CollectionView DataSource
extension LatestMovieTableViewCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return idData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = contentsCollectionView.dequeueReusableCell(withReuseIdentifier: ContentsBasicItem.identifier, for: indexPath) as! ContentsBasicItem
        
        cell.configure(poster: posterData[indexPath.row])
        
        return cell
    }
    
    
}

//MARK: -CollectionView FlowLayout Delegate
extension LatestMovieTableViewCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {

        return collectionViewFlow.edgeInsets
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {

        return collectionViewFlow.itemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        print(frame)
        let cellWidth = round(collectionView.frame.width / 3.5)
        let cellHeight = round(collectionView.frame.height - (collectionViewFlow.lineSpacing * 2))
        
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        delegate?.didTabLatestMovieCell(id: idData[indexPath.row])
    }
}
