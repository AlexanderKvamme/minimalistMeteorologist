import UIKit
import Foundation

final class Animations{
    
    static var checkmarkImages: [UIImage] = [] // static keyword makes this a type property
    
    class func setupAnimation(){
        for i in 40...79 {
            let filename = String(format: "loading_%05d", i)
            if let image = UIImage(named: filename) {
                checkmarkImages.append(image)
            }
        }
    }
    
    // --- //
    
     class func playCheckmarkOnce(inImageView imageView: UIImageView){
     
        imageView.animationImages = checkmarkImages
        imageView.animationDuration = 1
        imageView.animationRepeatCount = 1
        imageView.startAnimating()
     }
     
     class func playCheckmarkAnimation(inImageView imageView: UIImageView){
        setupAnimation()
        playCheckmarkOnce(inImageView: imageView)
     }
}
