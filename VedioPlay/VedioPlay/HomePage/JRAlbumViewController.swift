//
//  JRAlbumViewController.swift
//  VedioPlay
//
//  Created by wenze on 2020/6/15.
//  Copyright © 2020 wenze. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol  JRAlbumViewControllerDelegate{
    
    func  fileSelected(_ dataArray:[Dictionary<String, Any>])
}

class JRAlbumViewController: UIViewController,JPhotoListViewDelegate {
    // ios自动布局xib
    // Autoresizing
    // 1 UIViewAutoresizingNone 默认值 frame不随suberview改变
    // 2 UIViewAutoresizingFlexibleLeftMargin 自动调整view与superview左边的距离保证右边距离不变
    // 3 UIViewAutoresizingFlexibleWidth 自动调整view的宽，保证与superView的左右边距不变
    // 4 UIViewAutoresizingFlexibleRightMargin 自动调整view与superview右边的距离保证左边距不变
    // 5 UIViewAutoresizingFlexibleTopMargin 自动调整view与superview顶部的距离保证底部距离不变
    // 6 UIViewAutoresizingFlexibleHeight 自动调整view的高，保证与superView的顶部和底部距离不变
    // 7 UIViewAutoresizingFlexibleBottomMargin 自动调整view与superview底部部的距离保证顶部距离不变
    
    @IBOutlet weak var albumView: JPhotoListView!
    
    @IBOutlet weak var originalBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    weak var delegate:JRAlbumViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // inherit module from target
        //Swift创建的XIB默认是选中Inherit Module From Target的.OC创建的XIB文件系统默认没有勾选.
        JPhotoManger.shared.clearAll()
        albumView.delegate = self
        albumView.backgroundColor = .white
        // Do any additional setup after loading the view.
        JPhotoManger.shared.laodAssetsWithCompleteBlock { (succeed:Bool) in
            if succeed{
                self.albumView.reloadCollectionView()
            }
        }
        
        updateToolBar()
        
    }
    
    func updateToolBar()  {
        
        originalBtn.setTitle("原图", for: .normal)
        originalBtn.setTitle("原图", for: .selected)
        // Unexpectedly found nil while implicitly unwrapping an Optional value: (String(describing: JPhotoManger.shared.maximumNumberOfSelection)   "发送(\(JPhotoManger.shared.indexPathsForSelectedItems.count)/\( String(describing: JPhotoManger.shared.maximumNumberOfSelection))"报错这种写法
        //let sendMessageStr:String? = "发送(\(JPhotoManger.shared.indexPathsForSelectedItems.count)/\( String(describing: JPhotoManger.shared.maximumNumberOfSelection))"
        if JPhotoManger.shared.indexPathsForSelectedItems !=  nil &&  JPhotoManger.shared.maximumNumberOfSelection != nil{
            let sendMessageStr:String? = String(format: "%d/%ld",JPhotoManger.shared.indexPathsForSelectedItems.count, JPhotoManger.shared.maximumNumberOfSelection)
            sendBtn.setTitle(sendMessageStr, for: .normal)
        }
       
        
    }
    
    
   
    @IBAction func sender(_ sender: UIButton) {
        
        DispatchQueue.global().async {
            
            let assetsArray =  JPhotoManger.shared.indexPathsForSelectedItems
            //var  isVideo = false
            var  photoArrays = [Dictionary<String, Any>]()
            for item in assetsArray ?? []{
                
                let asset = item as! ALAsset
                
                let representation = asset.defaultRepresentation()
                
                let type = asset.value(forProperty: ALAssetPropertyType) as! String
                
                if type ==  ALAssetTypePhoto {
                    
                    var image:UIImage? = nil
                    
                    if self.originalBtn.isSelected == false {
                        image = UIImage(cgImage: (asset.thumbnail()?.takeUnretainedValue())!)
                        
                    }else{
                        
                        let fullScreen = representation?.fullScreenImage()
                        image = UIImage(cgImage: (fullScreen?.takeUnretainedValue())!)
                    
                    }
                    
                    let imageData = image?.jpegData(compressionQuality: 0.8)
                    if imageData != nil {
                        photoArrays.append(["blumData":imageData! ,"isVideo":false])
                    }
                    
                }else if type == ALAssetTypeVideo{

                   // isVideo = true
                    
                    let size = representation?.size()

                    let data = NSMutableData.init(capacity: Int(size ?? 0))

                    var buffer = data?.mutableBytes
                    //UnsafeMutablePointer<UInt8>?
                   // MemoryLayout.size(ofValue:8) https://zhuanlan.zhihu.com/p/26909719?utm_medium=social&utm_source=wei
                   // MemoryLayout.alignment(ofValue: <#T##_#>) 而且在 64bit 系统下，最大的内存对齐原则是 8byte。
                  //  MemoryLayout.stride(ofValue: <#T##_#>)
                    //unsafeMutableRawPointer 等同于 void *

                    representation?.getBytes(buffer?.assumingMemoryBound(to: UInt8.self), fromOffset: 0, length: Int(size ?? 0), error: nil)
                    if buffer != nil {
                        let fileData = Data.init(bytes: buffer!, count: Int(size ?? 0))

                        //if fileData != nil {
                        photoArrays.append(["blumData":fileData ,"isVideo":true])
                       // }
                    }
                    
//                        if representation != nil {
//                          photoArrays.append(["blumData":BrigeOCSwiftModel.dataBytesAssert(representation!) ,"isVideo":true])
//                         }
                    
                }
                
            }
            
            DispatchQueue.main.async {
                
                self.delegate?.fileSelected(photoArrays)
                self.navigationController?.popViewController(animated: true)
                
            }
            
        }
        
    }
    
    
  
    @IBAction func origin(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    // JPhotoListViewDelegate
    func photoPickerDidMaximum(_ picker: JPhotoListView?) {
        
    }
    
    func photoPickerDidMinimum(_ picker: JPhotoListView?) {
        
    }
    
    func photoPickerDidSelectionFilter(_ picker: JPhotoListView?) {
        
    }
    
    func photoPicker(_ picker: JPhotoListView?, didSelectAsset asset: ALAsset?) {
         updateToolBar()
    }
    
    func photoPicker(_ picker: JPhotoListView?, didSelectUnexpectedAsset asset: ALAsset?) {
        
    }
    
    func presentDetailView() {
        
        
    }
    func photoPicker(_ picker: JPhotoListView?, didDeselectAsset asset: ALAsset?) {
        updateToolBar()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
    }
    
    
    
    deinit {
        JPhotoManger.shared.clearAll()
    }
    
//    override func delete(_ sender: Any?) {
//
//    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
