//
//  PreViewController.swift
//  NetflixClone
//
//  Created by MyMac on 2020/04/13.
//  Copyright © 2020 Netflex. All rights reserved.
//

import UIKit
import AVFoundation
import Kingfisher

class PreViewController: BaseViewController {
    let categoryLabel = UILabel()
    let playButton = UIButton()
    private let dibsView = CustomButtonView(imageName: "plus", labelText: "내가 찜한 콘텐츠")
//    private lazy var dibsView = {
//        if {
//            CustomButtonView(imageName: "plus", labelText: "내가 찜한 콘텐츠")
//        } else {
//
//        }
//    }
    private let infoView = CustomButtonView(imageName: "info.circle", labelText: "정보")
    private let dismissButton = UIButton()
    private let playerScrollView = UIScrollView()
    private var displayingViewIndex: Int {
        set {
            
        }
        get {
            let index = Int(self.playerScrollView.contentOffset.x / self.playerScrollView.bounds.width)
            print(index)
            return index
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var previewSubviews = [PreviewView]()
    
    private var preview: [PreviewContent]
    private var receivedPreviewIndex: Int
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    weak var delegate: IsClickedProtocol?
    
    init(index: Int = 0, previews: [PreviewContent]) {
        self.receivedPreviewIndex = index
        self.preview = previews
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(receivedPreviewIndex)
        setUI()
        setConstraints()
        createPreviewSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        playerScrollView.setContentOffset(CGPoint(x: CGFloat(receivedPreviewIndex) * playerScrollView.bounds.width, y: 0), animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard preview.count > 0 else { return }
        previewSubviews[receivedPreviewIndex].player.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        previewSubviews[displayingViewIndex].player.pause()
    }
    
    private func setUI() {
        [categoryLabel, playerScrollView, dibsView, infoView, playButton, dismissButton].forEach {
            view.addSubview($0)
        }
        
        dibsView.button.tag = 0
        infoView.button.tag = 1
        playButton.tag = 2
        
        categoryLabel.font = UIFont.dynamicFont(fontSize: 13, weight: .regular)
        categoryLabel.textColor = UIColor.setNetfilxColor(name: .white)
        categoryLabel.textAlignment = .center
//        self.applyContentsUniqueValue()
        
        playButton.layer.borderWidth = 2
        playButton.layer.borderColor = UIColor.white.cgColor
        playButton.setTitle("▶︎ 재생", for: .normal)
        playButton.setTitleColor(UIColor.setNetfilxColor(name: .white), for: .normal)
        playButton.tintColor = .clear
        
        dibsView.label.textColor = UIColor.setNetfilxColor(name: .white)
        infoView.label.textColor = UIColor.setNetfilxColor(name: .white)
        dibsView.label.font = UIFont.dynamicFont(fontSize: 10, weight: .regular)
        infoView.label.font = UIFont.dynamicFont(fontSize: 10, weight: .regular)
        
        dibsView.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        infoView.button.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(didTapButton(_:)), for: .touchUpInside)
        
        dismissButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        dismissButton.tintColor = UIColor.setNetfilxColor(name: .white)
        dismissButton.addTarget(self, action: #selector(didTapDismissButton(_:)), for: .touchUpInside)
        view.bringSubviewToFront(dismissButton)
        
        playerScrollView.isPagingEnabled = true
        playerScrollView.delegate = self
    }
    
    private func createPreviewSubviews() {
        self.previewSubviews = preview.compactMap {
            guard let url = URL(string: $0.previewVideoURL) else {
                print("makeURL Fail")
                return nil
            }
            let view = PreviewView(url: url)
            view.configure(image: $0.poster)
            NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying(note:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: view.player.currentItem)
            return view
        }
        
        for (index, view) in previewSubviews.enumerated() {
            playerScrollView.addSubview(view)
            let leading = index == 0 ? playerScrollView.snp.leading : previewSubviews[index-1].snp.trailing
            view.snp.makeConstraints {
                $0.leading.equalTo(leading)
                $0.top.bottom.width.height.equalTo(playerScrollView)
            }
            
            if index == previewSubviews.count - 1 {
                view.snp.makeConstraints {
                    $0.trailing.equalTo(playerScrollView.snp.trailing)
                }
            }
            
        }
    }
    
    @objc private func didTapDismissButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func didTapButton(_ sender: UIButton) {
        var dibsButtonClicked = dibsView.isClicked
        
        switch sender.tag {
        case 0:
            // MARK: 찜하기 버튼 눌렀을 때 액션, 서버로 보내기
            if dibsButtonClicked {
                print("찜하기 버튼 클릭: ", dibsButtonClicked)
                // MARK: 눌렀을 때 애니메이션 (숫자의 크기에 따라서 도는 방향이 결정 됨)
                self.dibsView.imageView.transform = .init(rotationAngle: CGFloat.pi)
                UIView.transition(with: self.dibsView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.dibsView.imageView.transform = .identity
                    self.dibsView.imageView.image = UIImage(systemName: "checkmark")})
                
            } else {
                print("찜하기 버튼 풀기: ", dibsButtonClicked)
                // MARK: 찜하기 버튼 한번 더 눌러서 액션 풀기, 서버로 보내기
                self.dibsView.imageView.transform = .init(rotationAngle: CGFloat.pi / 2)
                UIView.transition(with: self.dibsView, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.dibsView.imageView.transform = .identity
                    self.dibsView.imageView.image = UIImage(systemName: "plus")
                })
            }
            delegate?.dibButtonIsCliked()
            dibsButtonClicked.toggle()
            
        // 정보버튼 눌렀을 때
        case 1:
            print("정보 버튼 눌렀을 때 인덱스: ", displayingViewIndex)
            self.receivedPreviewIndex = displayingViewIndex
            let contentsVC = ContentViewController(id: preview[displayingViewIndex].id)
            print(preview[displayingViewIndex].title)
            print(preview[displayingViewIndex].poster)
            contentsVC.modalPresentationStyle = .fullScreen
            present(contentsVC, animated: true)
        case 2:
            print("재생 버튼 눌렀을 때 인덱스: ", displayingViewIndex)
            self.receivedPreviewIndex = displayingViewIndex
            presentVideoController(contentID: preview[displayingViewIndex].id)
        default:
            break
        }
    }
    
    private func setConstraints() {
        playerScrollView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalTo(view)
        }
        
        let betweenLabelAndButton = CGFloat.dynamicYMargin(margin: 20)
        let buttonHeight = CGFloat.dynamicYMargin(margin: 40)
        let bottomOffset = CGFloat.dynamicYMargin(margin: -60)
        let dismissButtonSize = CGFloat.dynamicXMargin(margin: 25)
        
        categoryLabel.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(view.snp.width).multipliedBy(0.7)
            $0.bottom.equalTo(playButton.snp.top).offset(betweenLabelAndButton)
        }
        
        playButton.snp.makeConstraints {
            $0.centerX.equalTo(view.snp.centerX)
            $0.width.equalTo(view.snp.width).multipliedBy(0.3)
            $0.height.equalTo(buttonHeight)
            $0.bottom.equalTo(view.snp.bottom).offset(bottomOffset)
        }
        
        dibsView.snp.makeConstraints {
            $0.width.height.bottom.equalTo(playButton)
            $0.trailing.equalTo(playButton.snp.leading)
        }
        
        infoView.snp.makeConstraints {
            $0.width.height.bottom.equalTo(playButton)
            $0.leading.equalTo(playButton.snp.trailing)
        }
        
        dismissButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(5)
            $0.trailing.equalTo(view).offset(-10)
            $0.width.height.equalTo(dismissButtonSize)
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("영상 끝나면 다음 영상으로 넘겨 줄 것")
        let cmTime = CMTime(value: 0, timescale: 1)
        previewSubviews[displayingViewIndex].player.seek(to: cmTime)
        
        if displayingViewIndex < previewSubviews.count - 1 {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
                    
                    self.categoryLabel.alpha = 0
                    self.playerScrollView.contentOffset.x = CGFloat(self.displayingViewIndex + 1) * self.view.frame.width
                }, completion: { _ in
                    self.categoryLabel.alpha = 1
                    self.previewSubviews[self.displayingViewIndex].player.play()
                })
            }
        } else {
            dismiss(animated: true)
        }
        
    }
    
    // 레이블 값 바꿔주고, 찜한 값 이미지 변경해주기
    private func applyContentsUniqueValue() {
        let categoryArr = preview[displayingViewIndex].categories
        let categoryString = categoryArr.joined(separator: "・")
        self.categoryLabel.text = categoryString
    }
}

extension PreViewController: UIScrollViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        print(#function)
        previewSubviews[displayingViewIndex].player.play()
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        print(#function)
        previewSubviews.forEach {
            $0.player.pause()
        }
    }
}

extension PreViewController: IsClickedProtocol {
    func likeButtonIsCliked() {
        print("필요없는 버튼")
    }
    
    func dibButtonIsCliked() {
        print("displayingIndex: ", displayingViewIndex )
        let contentId = self.preview[displayingViewIndex].id
        
        guard let profileID =  LoginStatus.shared.getProfileID(),let url = URL(string: "https://www.netflexx.ga/\(profileID)/contents/\(contentId)/select/"),
            let token = LoginStatus.shared.getToken()
            else { return }
        APIManager().request(url: url, method: .get, token: token) { _ in }
    }
    
}
