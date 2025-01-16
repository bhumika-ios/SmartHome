import SwiftUI
import SpriteKit

public struct SmokeConfig: BaseConfig {
    var content: [Content] = [
        .image(UIImage.loadFromBundle(named: .spark), nil, 1)
    ]
    var backgroundColor: Color = .clear
    var intensity: Intensity = .medium
    var lifetime: Lifetime = .medium
    var initialVelocity: InitialVelocity = .medium
    var fadeOut: FadeOut = .medium
    var spreadRadius: SpreadRadius = .high
    var particleColor: Color = .black  // Add particleColor property
    
    public init() {}
    
    public init(
        content: [Content] = [
            .image(UIImage.loadFromBundle(named: .spark), nil, 1)
        ],
        backgroundColor: Color = .clear,
        intensity: Intensity = .medium,
        lifetime: Lifetime = .medium,
        initialVelocity: InitialVelocity = .medium,
        fadeOut: FadeOut = .medium,
        spreadRadius: SpreadRadius = .high,
        particleColor: Color = .black // Allow color customization
    ) {
        self.content = content
        self.backgroundColor = backgroundColor
        self.intensity = intensity
        self.initialVelocity = initialVelocity
        self.fadeOut = fadeOut
        self.spreadRadius = spreadRadius
        self.particleColor = particleColor
    }
}
public enum Intensity {
    case low, medium, high
}
protocol BaseConfig {
    var content: [Content] { get }
    var backgroundColor: Color { get }
    var intensity: Intensity { get }
    var lifetime: Lifetime { get }
    var initialVelocity: InitialVelocity { get }
    var fadeOut: FadeOut { get }
    var spreadRadius: SpreadRadius { get }
    
    // default values for base configs view values
    var birthRateValue: Float { get }
    var lifetimeValue: Float { get }
    var velocityValue: CGFloat { get }
    var alphaSpeedValue: Float { get }
    var spreadRadiusValue: CGFloat { get }
}
public enum Content {
    public enum Shape {
        case circle
        case triangle
        case square
        case custom(CGPath)
    }

    case shape(Shape, UIColor?, CGFloat = 1)
    case image(UIImage, UIColor?, CGFloat = 1)
    case emoji(Character, CGFloat = 1)
}
public enum Lifetime {
    case short, medium, long
}
public enum InitialVelocity {
    case slow, medium, fast
}
public enum FadeOut {
    case none, slow, medium, fast
}
public enum SpreadRadius {
    case low, medium, high
}
extension SmokeConfig {
    var birthRateValue: Float {
        switch intensity {
        case .low:
            return 1.5
        case .medium:
            return 0.5
        case .high:
            return 0.1
        }
    }
    
    var lifetimeValue: Float {
        switch lifetime {
        case .short:
            return 2
        case .medium:
            return 10
        case .long:
            return 100
        }
    }
    
    var velocityValue: CGFloat {
        switch initialVelocity {
        case .slow:
            return 5
        case .medium:
            return 40
        case .fast:
            return 100
        }
    }
    
    var alphaSpeedValue: Float {
        switch fadeOut {
        case .none:
            return 0
        case .slow:
            return -0.08
        case .medium:
            return -0.15
        case .fast:
            return -0.28
        }
    }
    
    var spreadRadiusValue: CGFloat {
        switch spreadRadius {
        case .low:
            return .pi / 4
        case .medium:
            return .pi
        case .high:
            return .pi * 2
        }
    }

}

extension Content {
    var color: UIColor? {
        switch self {
        case let .image(_, color?, _),
            let .shape(_, color?, _):
            return color
        default:
            return nil
        }
    }
    
    var image: UIImage {
        switch self {
        case let .image(image, _, _):
            return image
        case let .shape(shape, color, _):
            return shape.image(with: color ?? .white)
        case let .emoji(character, _):
            return "\(character)".image()
        }
    }
    
    var scale: CGFloat {
        switch self {
        case .shape(_, _, let scale):
            return scale
        case .image(_, _, let scale):
            return scale
        case .emoji(_, let scale):
            return scale
        }
    }
}

extension Content.Shape {
    func path(in rect: CGRect) -> CGPath {
        switch self {
        case .circle:
            return CGPath(ellipseIn: rect, transform: nil)
        case .triangle:
            let path = CGMutablePath()
            path.addLines(between: [
                CGPoint(x: rect.midX, y: 0),
                CGPoint(x: rect.maxX, y: rect.maxY),
                CGPoint(x: rect.minX, y: rect.maxY),
                CGPoint(x: rect.midX, y: 0)
            ])
            return path
        case .square:
            return CGPath(rect: rect, transform: nil)
        case .custom(let path):
            return path
        }
    }
    
    func image(with color: UIColor) -> UIImage {
        let rect = CGRect(origin: .zero, size: CGSize(width: 12.0, height: 12.0))
        return UIGraphicsImageRenderer(size: rect.size).image { context in
            context.cgContext.setFillColor(color.cgColor)
            context.cgContext.addPath(path(in: rect))
            context.cgContext.fillPath()
        }
    }
}

extension String {
    func image(with font: UIFont = UIFont.systemFont(ofSize: 16.0)) -> UIImage {
        let string = NSString(string: "\(self)")
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font
        ]
        let size = string.size(withAttributes: attributes)
        
        return UIGraphicsImageRenderer(size: size).image { _ in
            string.draw(at: .zero, withAttributes: attributes)
        }
    }
}


class SmokeScene: SKScene {
    
    var config: SmokeConfig
    
    init(size: CGSize, config: SmokeConfig) {
        self.config = config
        super.init(size: size)
        
        backgroundColor = UIColor(config.backgroundColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        launchSmoke()
    }
    
    var customBirthRate: CGFloat {
        switch config.intensity {
        case .low:
            return 10
        case .medium:
            return 40
        case .high:
            return 100
        }
    }
    
    func launchSmoke() {
        for contentElement in config.content {
            let node = SKEmitterNode()
            
            node.particleTexture = SKTexture(image: contentElement.image)
            
            // Particle General
            node.particleBirthRate = customBirthRate
            node.particleLifetime = CGFloat(config.lifetimeValue)
            node.particlePositionRange = CGVector(dx: size.width / 4, dy: 30)
            
            node.emissionAngle = 0
            node.emissionAngleRange = config.spreadRadiusValue
            
            node.particleAlpha = 0.4
            node.particleAlphaRange = 0.3
            node.particleAlphaSpeed = CGFloat(config.alphaSpeedValue)
            
            node.yAcceleration = 0
            node.particleScale = contentElement.scale
            node.particleScaleRange = 0.3
            node.particleScaleSpeed = 0.5
            
            node.particleSpeed = config.velocityValue
            node.particleSpeedRange = 40
            node.particleColor = UIColor(config.particleColor)  // Apply custom smoke color
            node.particleColorBlendFactor = 1
            
            node.particleRotation = 0
            node.particleRotationRange = .pi * 2
            node.particleRotationSpeed = .pi * 1.6
            
            node.particleBlendMode = .alpha
            node.fieldBitMask = 0
            
            node.position = CGPoint(x: size.width / 2, y: size.height / 2)
            addChild(node)
        }
    }
}
import SwiftUI

public struct SmokeView1: View {
    
    private var config: SmokeConfig
    
    public init(config: SmokeConfig = SmokeConfig()) {
        self.config = config
    }
    
    public var body: some View {
        GeometryReader { proxy in
            SmokeContainerView(proxy: proxy, config: config)
        }
        .edgesIgnoringSafeArea(.all)
    }
}
import SwiftUI

enum SmokeExample: Int, CaseIterable {
    case one = 1
    case two
    case three
    
    @ViewBuilder func view() -> some View {
        switch self {
        case .one:
            SmokeView1(
                config: SmokeConfig(
                    intensity: .low,
                    lifetime: .short,
                    initialVelocity: .fast,
                    fadeOut: .slow,
                    //                                backgroundColor: .white.opacity(0.3),
                    particleColor: .white  // Set smoke color to black
                )
            )
        case .two:
            SmokeView1(
                config: SmokeConfig(
                    intensity: .medium,
                    lifetime: .short,
                    initialVelocity: .fast,
                    fadeOut: .slow,
                    //                                backgroundColor: .white.opacity(0.3),
                    particleColor: .white  // Set smoke color to black
                )
            )
        case .three:
            SmokeView1(
                config: SmokeConfig(
                    intensity: .high,
                    lifetime: .short,
                    initialVelocity: .fast,
                    fadeOut: .slow,
                    //                                backgroundColor: .white.opacity(0.3),
                    particleColor: .white  // Set smoke color to black
                )
            )
        }
    }
}


//struct SmokeContainer: View {
//    
//    @State private var currentExample: SmokeExample = .regular
//    
//    var body: some View {
//        ZStack {
//            Text("546")
//            currentExample.view()
//               
//            ScrollView {
//                ForEach(SmokeExample.allCases, id: \.self) { example in
//                    Button {
//                        currentExample = example
//                    } label: {
//                        Text(example.rawValue.capitalized)
//                            .frame(maxWidth: .infinity)
//                    }
//                    .buttonStyle(.bordered)
//                    .overlay(
//                        example == currentExample ?
//                        RoundedRectangle(cornerRadius: 10, style: .continuous)
//                            .stroke(Color.accentColor, lineWidth: 4)
//                        : nil
//                    )
//                    .padding()
//                }
//            }
//        }
//        .navigationTitle("Fireworks examples")
//    }
//}

//struct SmokeContainer_Previews: PreviewProvider {
//    static var previews: some View {
//        SmokeContainer()
//    }
//}
struct SmokeContainerView: View {
    
    var proxy: GeometryProxy
    var config: SmokeConfig
    
    var body: some View {
        SpriteView(
            scene: createScene(of: proxy.size),
            options: [.allowsTransparency]
        )
    }
    
    func createScene(of size: CGSize) -> SKScene {
        return SmokeScene(size: size, config: config)
        
    }
}
