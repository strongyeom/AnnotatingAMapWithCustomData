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
    
    // 블러 이펙트
    private let blurEffect = UIBlurEffect(style: .systemThickMaterial)
    
    // 백그라운드를 블러 처리
    private lazy var backgroundMaterial: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Label 과 ImageView의 스택뷰
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelVibrancyView, imageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .top
        stackView.spacing = interItemSpacing
        
        return stackView
    }()
    
    // 블러View위에 Label이 얹혀놓음
    private lazy var labelVibrancyView: UIVisualEffectView = {
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: .secondaryLabel)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.translatesAutoresizingMaskIntoConstraints = false
        vibrancyView.contentView.addSubview(self.label)
        
        return vibrancyView
    }()
    
    // Label
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        // 하나의 단어가 완전히 끝나지 않았어도 라인의 끝에 도착하면 다음 라인으로 줄을 바꾸어 나머지 문자를 계속 출력합니다. 물론 Line 속성에서 설정된 라인 수를 넘어서면 나머지 텍스트는 표시하지 않습니다.
        label.lineBreakMode = .byCharWrapping
        // 설정 라인을 0 으로 해서 다음 라인으로 계속 줄바꿈이 이뤄질 수 있도록 설정
        label.numberOfLines = 0
        // preferredFont : 시스템 폰트를 사용하면 디바이스 기기에 맞게 알아서 설정됨
        label.font = UIFont.preferredFont(forTextStyle: .caption1)
        label.translatesAutoresizingMaskIntoConstraints = false
        // 늘어날 수 있는 최대 크기
        label.preferredMaxLayoutWidth = maxContentWidth
        return label
    }()
        
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: nil)
        return imageView
    }()
    
    private var imageHeightConstraint: NSLayoutConstraint?
    private var labelHeightConstraint: NSLayoutConstraint?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = UIColor.clear
        addSubview(backgroundMaterial)
        
        backgroundMaterial.contentView.addSubview(stackView)
        
        // Make the background material the size of the annotation view container
        backgroundMaterial.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        backgroundMaterial.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        backgroundMaterial.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        backgroundMaterial.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        
        // Anchor the top and leading edge of the stack view to let it grow to the content size.
        stackView.leadingAnchor.constraint(equalTo: backgroundMaterial.leadingAnchor, constant: contentInsets.left).isActive = true
        stackView.topAnchor.constraint(equalTo: backgroundMaterial.topAnchor, constant: contentInsets.top).isActive = true
        
        // Limit how much the content is allowed to grow.
        // imageView가 늘어날 수 있는 최대 크기 : maxContentWidth
        imageView.widthAnchor.constraint(equalToConstant: maxContentWidth).isActive = true
        labelVibrancyView.widthAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        labelVibrancyView.heightAnchor.constraint(equalTo: label.heightAnchor).isActive = true
        labelVibrancyView.leadingAnchor.constraint(equalTo: label.leadingAnchor).isActive = true
        labelVibrancyView.topAnchor.constraint(equalTo: label.topAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Annotation도 재상용되기 때문에 prepareForReuse 메서드 호출
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    // Annotation이 뷰에 표시되기 전에 호출됨
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        /*
         If using the same annotation view and reuse identifier for multiple annotations, iOS will reuse this view by calling `prepareForReuse()`
         so the view can be put into a known default state, and `prepareForDisplay()` right before the annotation view is displayed. This method is
         the view's oppurtunity to update itself to display content for the new annotation.
         */
        
        // mapkit을 import했기 때문에 annotation을 사용 할 수 있고 다운 캐스팅을 통해 CustomAnnotation 로 만들어준다.
        
        if let annotation = annotation as? CustomAnnotation {
            // CustomAnnotation 의 title을 label에 할당한다.
            label.text = annotation.title
            
            // 이미지 또한 옵셔널 바인딩을 통해서 적용할 수 있다.
            if let imageName = annotation.imageName, let image = UIImage(named: imageName) {
                imageView.image = image
                
                /*
                 The image view has a width constraint to keep the image to a reasonable size. A height constraint to keep the aspect ratio
                 proportions of the image is required to keep the image packed into the stack view. Without this constraint, the image's height
                 will remain the intrinsic size of the image, resulting in extra height in the stack view that is not desired.
                 */
                
                
                // ⭐️baseView의 레이아웃을 설정하면 아래코드는 작성하지 않아도 된다.⭐️
                if let heightConstraint = imageHeightConstraint {
                    imageView.removeConstraint(heightConstraint)
                }
                
                let ratio = image.size.height / image.size.width
                imageHeightConstraint = imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: ratio, constant: 0)
                imageHeightConstraint?.isActive = true
            }
        }
        
        // Since the image and text sizes may have changed, require the system do a layout pass to update the size of the subviews.
        // 이미지의 크기 및 레이블의 사이즈가 변경될 수도 있으므로 레이아웃을 업데이트 한다.
        
        // #참고#
        /*
         setNeedsLayout()을 통해 다음 런루프에서 레이아웃을 업데이트하도록 예약 => layoutSubViews를 통해 레이아웃 업데이트
         즉, layoutSubViews를 쓰려면 setNeedsLayout도 항상 같이 사용해야 함
         */
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // The stack view will not have a size until a `layoutSubviews()` pass is completed. As this view's overall size is the size
        // of the stack view plus a border area, the layout system needs to know that this layout pass has invalidated this view's
        // `intrinsicContentSize`.
        invalidateIntrinsicContentSize()
        
        // Use the intrinsic content size to inform the size of the annotation view with all of the subviews.
        
        // 말풍선 모양으로 만들 수 있는 방법 ⬇️⬇️⬇️⬇️⬇️
        let contentSize = intrinsicContentSize
        frame.size = intrinsicContentSize
        
        // The annotation view's center is at the annotation's coordinate. For this annotation view, offset the center so that the
        // drawn arrow point is the annotation's coordinate.
        centerOffset = CGPoint(x: contentSize.width / 2, y: contentSize.height / 2)
        
        let shape = CAShapeLayer()
        let path = CGMutablePath()

        // Draw the pointed shape.
        let pointShape = UIBezierPath()
        pointShape.move(to: CGPoint(x: boxInset, y: 0))
        pointShape.addLine(to: CGPoint.zero)
        pointShape.addLine(to: CGPoint(x: boxInset, y: boxInset))
        path.addPath(pointShape.cgPath)

        // Draw the rounded box.
        let box = CGRect(x: boxInset, y: 0, width: self.frame.size.width - boxInset, height: self.frame.size.height)
        let roundedRect = UIBezierPath(roundedRect: box,
                                       byRoundingCorners: [.topRight, .bottomLeft, .bottomRight],
                                       cornerRadii: CGSize(width: 5, height: 5))
        path.addPath(roundedRect.cgPath)

        shape.path = path
        backgroundMaterial.layer.mask = shape
    }
    
    override var intrinsicContentSize: CGSize {
        var size = stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        size.width += contentInsets.left + contentInsets.right
        size.height += contentInsets.top + contentInsets.bottom
        return size
    }
}
