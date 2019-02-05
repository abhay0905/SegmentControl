//
//  SegmentedControl.swift
//
//
//  Created by Abhay Shankar on 29/01/19.
//

import UIKit

@IBDesignable
class SegmentedControl: UISegmentedControl {

    @IBInspectable
    var indicatorColor: UIColor = UIColor.init(red: CGFloat(52)/255.0, green: CGFloat(152)/255.0, blue: CGFloat(219)/255.0, alpha: 1.0){
        didSet{
            indicatorBar.backgroundColor = indicatorColor
        }
    }

    @IBInspectable
    var padding : CGFloat = 3.0{
        didSet{
            let vals = updateSlider()
            self.indicatorBar.frame.origin.x = vals.leftSpacing
            self.indicatorBar.frame.size.width = vals.width
        }
    }
    
    @IBInspectable
    var indicatorHeight : CGFloat = 3.0{
        didSet{
            heightContraintOfIndicatorBar?.constant = indicatorHeight
            topContraintOfIndicatorBar?.constant = -indicatorHeight
            self.indicatorBar.frame.origin.y = self.frame.height - indicatorHeight
            self.indicatorBar.frame.size.height = indicatorHeight
            indicatorBar.layer.cornerRadius = indicatorHeight/2.0
        }
    }

    fileprivate let indicatorBar = UIView()
    fileprivate var leftContraintOfIndicatorBar : NSLayoutConstraint?
    fileprivate var widthContraintOfIndicatorBar : NSLayoutConstraint?
    fileprivate var heightContraintOfIndicatorBar : NSLayoutConstraint?
    fileprivate var topContraintOfIndicatorBar : NSLayoutConstraint?

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        initUI()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initUI()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        let vals = updateSlider()
        UIView.animate(withDuration: 0.3) {
            self.indicatorBar.frame.origin.x = vals.leftSpacing
            self.indicatorBar.frame.size.width = vals.width
        }
    }

    fileprivate func initUI() {
        self.selectedSegmentIndex = 0
        self.backgroundColor = .clear
        self.tintColor = .clear

        self.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .selected)

        self.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17),
            NSAttributedString.Key.foregroundColor: UIColor.black
            ], for: .normal)
        setupIndicatorBar()
    }

    fileprivate func setupIndicatorBar() {
        indicatorBar.translatesAutoresizingMaskIntoConstraints = false
        indicatorBar.backgroundColor = indicatorColor
        indicatorBar.layer.cornerRadius = indicatorHeight/2.0
        indicatorBar.layer.masksToBounds = true
        self.addSubview(indicatorBar)

        topContraintOfIndicatorBar = indicatorBar.topAnchor.constraint(equalTo: self.bottomAnchor, constant : -indicatorHeight)
        topContraintOfIndicatorBar?.isActive = true
        heightContraintOfIndicatorBar = indicatorBar.heightAnchor.constraint(equalToConstant: indicatorHeight)
        heightContraintOfIndicatorBar?.isActive = true
        leftContraintOfIndicatorBar = indicatorBar.leftAnchor.constraint(equalTo: self.leftAnchor)
        leftContraintOfIndicatorBar?.isActive = true
        var width = self.widthForSegment(at: self.selectedSegmentIndex)
        if width == 0{
            width = (self.frame.width / CGFloat(self.numberOfSegments))
        }

        widthContraintOfIndicatorBar =  indicatorBar.widthAnchor.constraint(equalToConstant: width)
        widthContraintOfIndicatorBar?.isActive = true
        self.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: UIControl.Event.valueChanged)

        let vals = updateSlider()
        self.indicatorBar.frame.origin.x = vals.leftSpacing
        self.indicatorBar.frame.size.width = vals.width
    }

    @objc
    fileprivate func segmentedControlValueChanged(_ sender: UISegmentedControl) {

        let vals = updateSlider()
        UIView.animate(withDuration: 0.3) {
            self.indicatorBar.frame.origin.x = vals.leftSpacing
            self.indicatorBar.frame.size.width = vals.width
        }
    }

    @discardableResult
    fileprivate func updateSlider()->(leftSpacing : CGFloat, width : CGFloat){

        if selectedSegmentIndex < 0{
            return (0,0)
        }
        var widthList = (0..<self.numberOfSegments).map({self.widthForSegment(at: $0)})
       
        let autoWidthCount = widthList.filter({$0 == 0.0}).count
        if autoWidthCount > 0{
            let widthSum = widthList.reduce(0) { (result, next) -> CGFloat in
                result + next
            }
            let remainingWidth = (self.frame.size.width - widthSum) / CGFloat(autoWidthCount)
            widthList = widthList.map({ (width) -> CGFloat in
                if width == 0.0{
                    return remainingWidth
                }else{
                    return width
                }
            })
        }
       
        var width = widthList[selectedSegmentIndex]
        var leftSpacing = (0..<self.selectedSegmentIndex).reduce(0) { (result, next) -> CGFloat in
            let width = widthList[next]
            return result + width
        }
        width = width - (2*padding)
        leftSpacing = leftSpacing + padding
        self.leftContraintOfIndicatorBar?.constant = leftSpacing
        self.widthContraintOfIndicatorBar?.constant = width
        
        return(leftSpacing,width)
    }
}
