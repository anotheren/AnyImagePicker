//
//  PhotoAssetCell.swift
//  AnyImageKit
//
//  Created by 刘栋 on 2019/9/17.
//  Copyright © 2019-2022 AnyImageKit.org. All rights reserved.
//

import UIKit
import Photos
import Kingfisher

final class PhotoAssetCell: UICollectionViewCell {
    
    let selectEvent: Delegate<Void, Void> = .init()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.layer.masksToBounds = true
        return view
    }()
    private lazy var gifView: GIFView = {
        let view = GIFView()
        view.isHidden = true
        return view
    }()
    private lazy var videoView: VideoView = {
        let view = VideoView()
        view.isHidden = true
        return view
    }()
    private lazy var editedView: EditedView = {
        let view = EditedView()
        view.isHidden = true
        return view
    }()
    private lazy var selectdCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    private lazy var disableCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return view
    }()
    private(set) lazy var boxCoverView: UIView = {
        let view = UIView(frame: .zero)
        view.isHidden = true
        view.layer.borderWidth = 4
        return view
    }()
    private(set) lazy var selectButton: NumberCircleButton = {
        let view = NumberCircleButton(frame: .zero, style: .default)
        view.addTarget(self, action: #selector(selectButtonTapped(_:)), for: .touchUpInside)
        return view
    }()
    
    private var task: Task<Void, Error>?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        task?.cancel()
        task = nil
        selectdCoverView.isHidden = true
        gifView.isHidden = true
        videoView.isHidden = true
        editedView.isHidden = true
        disableCoverView.isHidden = true
        boxCoverView.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        contentView.addSubview(selectdCoverView)
        contentView.addSubview(gifView)
        contentView.addSubview(videoView)
        contentView.addSubview(editedView)
        contentView.addSubview(disableCoverView)
        contentView.addSubview(boxCoverView)
        contentView.addSubview(selectButton)
        
        imageView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectdCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        gifView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        videoView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        editedView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        disableCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        boxCoverView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
        selectButton.snp.makeConstraints { maker in
            maker.top.right.equalToSuperview().inset(0)
            maker.width.height.equalTo(40)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension PhotoAssetCell: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        boxCoverView.layer.borderColor = options.theme[color: .primary].cgColor
        selectButton.isHidden = options.selectionTapAction.hideToolBar && options.selectLimit == 1
        updateChildrenConfigurable(options: options)
    }
}

extension PhotoAssetCell {
    
    var image: UIImage? {
        return imageView.image
    }
}

// MARK: - Action
extension PhotoAssetCell {
    
    @objc private func selectButtonTapped(_ sender: NumberCircleButton) {
        selectEvent.call()
    }
}

extension PhotoAssetCell {
    
    func setContent(_ asset: Asset<PHAsset>, options: PickerOptionsInfo, animated: Bool = false, isPreview: Bool = false) {
        task?.cancel()
        task = Task {
            do {
                let targetSize = frame.size.displaySize
                let options = ResourceLoadOptions.library(targetSize: targetSize)
                for try await result in asset.loadImage(options: options) {
                    guard !Task.isCancelled else {
                        print("\(String(describing: task)) isCancelled")
                        return
                    }
                    switch result {
                    case .progress:
                        break
                    case .success(let loadResult):
                        switch loadResult {
                        case .thumbnail(let image):
                            self.imageView.image = image
                        case .preview(let image):
                            self.imageView.image = image
                        default:
                            break
                        }
                    }
                }
            } catch {
                _print(error)
            }
        }
        
        updateState(asset, options: options, animated: animated, isPreview: isPreview)
    }
    
    func updateState(_ asset: Asset<PHAsset>, options: PickerOptionsInfo, animated: Bool = false, isPreview: Bool = false) {
        update(options: options)
        switch asset.mediaType {
        case .photoGIF:
            gifView.isHidden = false
        case .video:
            videoView.isHidden = false
        default:
            break
        }
        
        if !isPreview {
            selectButton.setNum(asset.selectedNum, isSelected: asset.isSelected, animated: animated)
            selectdCoverView.isHidden = !asset.isSelected
            if asset.isDisabled {
                disableCoverView.isHidden = false
            } else {
                disableCoverView.isHidden = !(asset.checker.isUpToLimit && !asset.isSelected)
            }
        }
    }
}


// MARK: - VideoView
private class VideoView: UIView {
    
    private lazy var videoImageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    private lazy var videoLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.isHidden = true
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12)
        return view
    }()
    private lazy var coverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverLayer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(coverLayer)
        addSubview(videoImageView)
        addSubview(videoLabel)
        
        videoImageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.width.equalTo(24)
            maker.height.equalTo(15)
        }
        videoLabel.snp.makeConstraints { maker in
            maker.left.equalTo(videoImageView.snp.right).offset(3)
            maker.centerY.equalTo(videoImageView)
        }
    }
    
}

extension VideoView {
    
    /// 设置视频时间，单位：秒
    func setVideoTime(_ time: String) {
        videoLabel.isHidden = false
        videoLabel.text = time
    }
}

// MARK: - PickerOptionsConfigurable
extension VideoView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        videoImageView.image = options.theme[icon: .video]
        updateChildrenConfigurable(options: options)
        options.theme.labelConfiguration[.assetCellVideoDuration]?.configuration(videoLabel)
    }
}


// MARK: - GIF View
private class GIFView: UIView {

    private lazy var gifLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.text = "GIF"
        view.textColor = UIColor.white
        view.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
        return view
    }()
    private lazy var coverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverLayer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(coverLayer)
        addSubview(gifLabel)
        
        gifLabel.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(8)
            maker.height.equalTo(15)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension GIFView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        options.theme.labelConfiguration[.assetCellGIFMark]?.configuration(gifLabel)
    }
}

// MARK: - Edited View
private class EditedView: UIView {

    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        return view
    }()
    
    private lazy var coverLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
        layer.colors = [
            UIColor.black.withAlphaComponent(0.5).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor]
        layer.locations = [0, 1]
        layer.startPoint = CGPoint(x: 0.5, y: 1)
        layer.endPoint = CGPoint(x: 0.5, y: 0)
        return layer
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        coverLayer.frame = CGRect(x: 0, y: self.bounds.height-35, width: self.bounds.width, height: 35)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.addSublayer(coverLayer)
        addSubview(imageView)
        
        imageView.snp.makeConstraints { maker in
            maker.left.bottom.equalToSuperview().inset(6)
        }
    }
}

// MARK: - PickerOptionsConfigurable
extension EditedView: PickerOptionsConfigurable {
    
    func update(options: PickerOptionsInfo) {
        imageView.image = options.theme[icon: .photoEdited]
        updateChildrenConfigurable(options: options)
    }
}