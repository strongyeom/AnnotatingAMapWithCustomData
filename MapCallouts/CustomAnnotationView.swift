/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The custom MKAnnotationView object representing a generic location, displaying a title and image.
*/

import UIKit
import MapKit

class CustomAnnotationView: MKAnnotationView {

    private let boxInset = CGFloat(10)
    private let interItemSpacing = CGFloat(10)
    private let maxContentWidth = CGFloat(90)
    private let contentInsets = UIEdgeInsets(top: 10, left: 30, bottom: 20, right: 20)
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [label, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = interItemSpacing
        
        return stackView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = UIColor.white
        label.lineBreakMode = .byWordWrapping
        label.backgroundColor = UIColor.clear
        label.numberOfLines = 2
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        
        return label
    }()
        
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        return imageView
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stackView)
        
        // Anchor the top and leading edge of the stack view to let it grow to the content size.
        stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: contentInsets.left).isActive = true
        stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: contentInsets.top).isActive = true
        
        // Limit how much the content is allowed to grow.
        imageView.widthAnchor.constraint(lessThanOrEqualToConstant: maxContentWidth).isActive = true
        label.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        /*
         If using the same annotation view and reuse identifier for multiple annotations, iOS will reuse this view by calling `prepareForReuse()`
         so the view can be put into a known default state, and `prepareForDisplay()` right before the annotation view is displayed. This method is
         the view's oppurtunity to update itself to display content for the new annotation.
         */
        if let annotation = annotation as? CustomAnnotation {
            label.text = annotation.title
            if let imageName = annotation.imageName, let image = UIImage(named: imageName) {
                imageView.image = image
                
                /*
                 The image view has a width constraint to keep the image to a reasonable size. A height constraint to keep the aspect ratio
                 proportions of the image is required to keep the image packed into the stack view. Without this constraint, the image's height
                 will remain the intrinsic size of the image, resulting in extra height in the stack view that is not desired.
                 */
                
                if let heightConstraint = imageHeightConstraint {
                    imageView.removeConstraint(heightConstraint)
                }
                
                let ratio = image.size.height / image.size.width
                imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio, constant: 0)
                imageHeightConstraint?.isActive = true
            }
        }
        
        // Since the image and text sizes may have changed, require the system do a layout pass to update the size of the subviews.
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // The stack view will not have a size until a `layoutSubviews()` pass is completed. As this view's overall size is the size
        // of the stack view plus a border area, the layout system needs to know that this layout pass has invalidated this view's
        // `intrinsicContentSize`.
        invalidateIntrinsicContentSize()
        
        // The annotation view's center is at the annotation's coordinate. For this annotation view, offset the center so that the
        // drawn arrow point is the annotation's coordinate.
        let contentSize = intrinsicContentSize
        centerOffset = CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        
        // Now that the view has a new size, the border needs to be redrawn at the new size.
        setNeedsDisplay()
    }
    
    override var intrinsicContentSize: CGSize {
        var size = stackView.bounds.size
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // Used to draw the rounded background box and pointer.
        UIColor.darkGray.setFill()
        
        // Draw the pointed shape.
        let pointShape = UIBezierPath()
        pointShape.move(to: CGPoint(x: 14, y: 0))
        pointShape.addLine(to: CGPoint.zero)
        pointShape.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height))
        pointShape.fill()
        
        // Draw the rounded box.
        let box = CGRect(x: boxInset, y: 0, width: rect.size.width - boxInset, height: rect.size.height)
        let roundedRect = UIBezierPath(roundedRect: box, cornerRadius: 5)
        roundedRect.lineWidth = 2
        roundedRect.fill()
    }
}
