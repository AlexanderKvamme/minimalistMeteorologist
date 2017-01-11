import UIKit
import Foundation

final class Animations{
    
    static var checkmarkImages: [UIImage] = [] // static keyword makes this a type property (property is static in that its assosciated with the Animations class and not an instance)

    class func setupAnimation(){
        for i in 40...79 {
            let filename = String(format: "loading_%05d", i)
            if let image = UIImage(named: filename) {
                checkmarkImages.append(image)
            }
        }
    }
    
     class func playCheckmarkAnimationOnce(inImageView imageView: UIImageView){

        DispatchQueue.main.async {

            if imageView.isAnimating {return}
            if (checkmarkImages.count == 0){
                self.setupAnimation()
            }
            
            imageView.isHidden = false // test Jan 8
            imageView.animationImages = checkmarkImages
            imageView.animationDuration = 1
            imageView.animationRepeatCount = 1
            imageView.startAnimating()
        }

     }
}
