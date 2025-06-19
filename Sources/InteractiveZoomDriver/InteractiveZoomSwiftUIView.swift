import SwiftUI
import UIKit

@available(iOS 13.0, *)
public struct InteractiveZoomSwiftUIView<T: UIView>: UIViewRepresentable {

  private let sourceView: T
  private let targetViewFactory: (T) throws -> UIView
  private let shouldZoomTransform: (T) -> Bool

  public init(
    sourceView: T,
    targetViewFactory: @escaping (T) throws -> UIView,
    shouldZoomTransform: @escaping (T) -> Bool
  ) {
    self.sourceView = sourceView
    self.targetViewFactory = targetViewFactory
    self.shouldZoomTransform = shouldZoomTransform
  }

  public func makeUIView(context: Context) -> UIView {

    let containerView = UIView(frame: .zero)

    let interactiveZoomView = InteractiveZoomView(
      sourceView: sourceView,
      targetViewFactory: targetViewFactory,
      shouldZoomTransform: shouldZoomTransform
    )
    interactiveZoomView.translatesAutoresizingMaskIntoConstraints = false

    sourceView.translatesAutoresizingMaskIntoConstraints = false

    containerView.addSubview(sourceView)
    containerView.addSubview(interactiveZoomView)

    NSLayoutConstraint.activate([
      sourceView.topAnchor.constraint(equalTo: containerView.topAnchor),
      sourceView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      sourceView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      sourceView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),

      interactiveZoomView.topAnchor.constraint(equalTo: containerView.topAnchor),
      interactiveZoomView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
      interactiveZoomView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
      interactiveZoomView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
    ])

    return containerView
  }

  public func updateUIView(_ uiView: UIView, context: Context) {
    print("updateUIView called")
  }
}

@available(iOS 13.0, *)
extension InteractiveZoomSwiftUIView where T: UIImageView {

  public init(sourceView: T) {
    self.init(
      sourceView: sourceView,
      targetViewFactory: InteractiveZoomView.clone,
      shouldZoomTransform: InteractiveZoomView.shouldZoomTransform
    )
  }
}

@available(iOS 13.0, *)
struct InteractiveZoomSwiftUIView_Previews: PreviewProvider {

  private static let imageView: UIImageView = {
    let image = UIImage(systemName: "person")!
    let imageView = UIImageView(image: image)
    imageView.contentMode = .scaleAspectFit
    imageView.clipsToBounds = true
    imageView.backgroundColor = .white
    return imageView
  }()

  static var previews: some View {
    TabView {
      if #available(iOS 16.0, *) {
        NavigationStack {

          ScrollView {
            VStack(spacing: 20) {
              Text("InteractiveZoomSwiftUIView")
                .font(.headline)

              InteractiveZoomSwiftUIView(sourceView: imageView)
                .frame(width: 300, height: 300)
                .border(Color.gray)
            }
            .padding()
          }
          .navigationTitle(Text("Title"))
        }
        .tabItem {
          Text("Tab1")
        }
      }

      Text("Text")
        .tabItem {
          Text("Tab2")
        }

    }
  }
}

