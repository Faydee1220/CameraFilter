//
//  ViewController.swift
//  CameraFilter
//
//  Created by 永動科技RQ on 2019/5/28.
//  Copyright © 2019 永動科技 RQ. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var filterButton: UIButton!

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    func updateUI(with image: UIImage) {
        photoImageView.image = image
        filterButton.isHidden = false
    }
    
    @IBAction func filterButtonPressed(_ sender: Any) {
        guard let sourceImage = photoImageView.image else { return }
        FilterTool.shared.applyFilter(to: sourceImage)
            .subscribe(onNext: { [weak self] (image) in
                DispatchQueue.main.async {
                    self?.photoImageView.image = image
                }
            }).disposed(by: disposeBag)

//        FilterTool.shared.applyFilter(to: sourceImage) { [weak self] (image) in
//            DispatchQueue.main.async {
//                self?.photoImageView.image = image
//            }
//        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let naviVC = segue.destination as? UINavigationController,
            let photosCollectionVC = naviVC.viewControllers.first as? PhotosCollectionVC else {
            return
        }
        photosCollectionVC.selectedPhoto.subscribe(onNext: { [weak self] (image) in
            DispatchQueue.main.async {
                self?.updateUI(with: image)
            }
        }).disposed(by: disposeBag)
    }

}

