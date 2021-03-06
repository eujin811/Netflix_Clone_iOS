//
//  searchResultItem.swift
//  NetflixClone
//
//  Created by MyMac on 2020/03/29.
//  Copyright © 2020 Netflex. All rights reserved.
//

import Foundation
import UIKit

final class ContentsBasicItem: UICollectionViewCell {
    static let identifier = "contentsBasic"
    
    //    let titleLabel = UILabel()
    private let posterImage = UIImageView()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: -UI
    private func setUI() {
        
        posterImage.contentMode = .scaleAspectFill
        posterImage.clipsToBounds = true

        contentView.addSubview(posterImage)
        
        posterImage.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview()
        }
        
    }
    

    
    //MARK: -configure (포스터, contentID)
    func configure(poster: UIImage) {
        self.posterImage.image = poster
        self.posterImage.backgroundColor = .red
    }
    
}
