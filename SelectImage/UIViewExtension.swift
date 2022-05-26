//
//  UIViewExtension.swift
//  SelectImage
//
//  Created by Vũ Việt Thắng on 26/05/2022.
//

import Foundation
import UIKit

extension UIView{
    func showView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: -(self.bounds.height))
        }, completion: nil)
    }
    func hideView(){
        UIView.animate(withDuration: 0.5, animations: {
            self.transform = CGAffineTransform(translationX: 0, y: 0)
        }, completion: nil)
    }
}
