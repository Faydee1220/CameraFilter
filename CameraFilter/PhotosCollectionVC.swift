//
//  PhotosCollectionVC.swift
//  CameraFilter
//
//  Created by 永動科技RQ on 2019/5/28.
//  Copyright © 2019 永動科技 RQ. All rights reserved.
//

import UIKit
import Photos
import RxSwift

class PhotosCollectionVC: UICollectionViewController {

    private let selectedPhotoSubject = PublishSubject<UIImage>()
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotoSubject.asObserver()
    }

    var images = [PHAsset]()

    override func viewDidLoad() {
        super.viewDidLoad()
        requestPhotoPermission()
    }

    func requestPhotoPermission() {
        PHPhotoLibrary.requestAuthorization { [weak self] (status) in
            print("request photo authorization")
            switch status {
            case .authorized:
                print("authorized")
                let assets = PHAsset.fetchAssets(with: .image, options: nil)
                assets.enumerateObjects({ (asset, count, stop) in
                    self?.images.append(asset)
                })
                self?.images.reverse()
//                print("images: \(self?.images)")
                DispatchQueue.main.async {
                    self?.collectionView.reloadData()
                }
            case .notDetermined: print("notDetermined")
            case .denied: print("denied")
            case .restricted: print("restricted")
            @unknown default:
                print("unknown")
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell",
                                                            for: indexPath) as? PhotoCell else {
            return UICollectionViewCell()
        }
    
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        manager.requestImage(for: asset,
                             targetSize: CGSize(width: 100, height: 100),
                             contentMode: .aspectFill,
                             options: nil) { (image, _) in
                                DispatchQueue.main.async {
                                    cell.photoImageView.image = image
                                }
        }
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedAsset = images[indexPath.row]
        PHImageManager.default().requestImage(for: selectedAsset,
                                              targetSize: CGSize(width: 300, height: 300),
                                              contentMode: .aspectFill,
                                              options: nil) { [weak self] (image, info) in
            guard let info = info,
                // 第一次可能拿到縮圖，可用 PHImageResultIsDegradedKey 判斷，來取得原始圖片
                // https://developer.apple.com/documentation/photokit/phimagemanager/1616964-requestimage
                let isDegradedImage = info["PHImageResultIsDegradedKey"] as? Bool,
                !isDegradedImage,
                let image = image else {
                return
            }
            self?.selectedPhotoSubject.onNext(image)
            self?.dismiss(animated: true, completion: nil)
        }
    }

}
