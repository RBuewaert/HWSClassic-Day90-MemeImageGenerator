//
//  ViewController.swift
//  Project27M
//
//  Created by Romain Buewaert on 18/11/2021.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    @IBOutlet weak var imageView: UIImageView!

    var textsList = [String: String]()
    var currentImage: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()

        let loadImageButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(loadImage))
        let editButton = UIBarButtonItem(title: "Edit text", style: .done, target: self, action: #selector(editText))
        navigationItem.leftBarButtonItems = [loadImageButton, editButton]

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareImage))
    }

    @objc func loadImage() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let importedImage = info[.editedImage] as? UIImage else { return }
        currentImage = importedImage

        dismiss(animated: true, completion: userTextTapped)
    }

    @objc func userTextTapped() {
        guard currentImage != nil else { return }

        let ac = UIAlertController(title: "Enter top text", message: nil, preferredStyle: .alert)
        ac.addTextField()

        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
            guard let text = ac?.textFields?[0].text else { return }
            print(text)
            self?.textsList["topText"] = text

            let ac = UIAlertController(title: "Enter bottom text", message: nil, preferredStyle: .alert)
            ac.addTextField()

            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
                guard let text = ac?.textFields?[0].text else { return }
                print(text)
                self?.textsList["bottomText"] = text
                self?.createMemeImage()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true, completion: nil)
    }

    @objc func editText() {
        let ac = UIAlertController(title: "Which text do you want to change?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Top text only", style: .default, handler: { [weak self] _ in
            let ac = UIAlertController(title: "Enter top text", message: nil, preferredStyle: .alert)
            ac.addTextField()

            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
                guard let text = ac?.textFields?[0].text else { return }
                print(text)
                self?.textsList["topText"] = text
                self?.createMemeImage()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Bottom text only", style: .default, handler: { [weak self] _ in
            let ac = UIAlertController(title: "Enter bottom text", message: nil, preferredStyle: .alert)
            ac.addTextField()

            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self, weak ac] _ in
                guard let text = ac?.textFields?[0].text else { return }
                print(text)
                self?.textsList["bottomText"] = text
                self?.createMemeImage()
            }))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            self?.present(ac, animated: true, completion: nil)
        }))
        ac.addAction(UIAlertAction(title: "Both text", style: .default, handler: { [weak self] _ in
            self?.userTextTapped()
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }

    func createMemeImage() {
        print(textsList)
        guard let currentImage = currentImage else { return }
        let renderer = UIGraphicsImageRenderer(size: currentImage.size)

        let imageToLoad = renderer.image { ctx in
            currentImage.draw(at: CGPoint(x: 0, y: 0))

            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineBreakMode = .byWordWrapping

            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 45),
                .foregroundColor: UIColor.white,
                .paragraphStyle: paragraphStyle
            ]

            guard let topString = textsList["topText"] else { return }
            let attributedTopString = NSAttributedString(string: topString, attributes: attrs)
            attributedTopString.draw(with: CGRect(x: 0, y: 18, width: currentImage.size.width, height: currentImage.size.height), options: .usesLineFragmentOrigin, context: nil)

            guard let bottomString = textsList["bottomText"] else { return }

            var numberOfLines = 1
            let size = (bottomString as NSString).size(withAttributes: attrs)

            if size.width > currentImage.size.width - 10 {
                let numberOfLetterByLine = (currentImage.size.width - 10) * CGFloat(bottomString.count) / size.width
                numberOfLines = Int((CGFloat(bottomString.count) / numberOfLetterByLine).rounded(.up))
                print("bottomString.count", bottomString.count)
                print("numberOfLetterByLine", numberOfLetterByLine)
                print("numberOfLines", numberOfLines)
            }

            let heightY: CGFloat = 18 + (50 * CGFloat(numberOfLines))
            let positionY: CGFloat = currentImage.size.height - heightY

            let attributedBottomString = NSAttributedString(string: bottomString, attributes: attrs)
            attributedBottomString.draw(with: CGRect(x: 0, y: positionY, width: currentImage.size.width, height: heightY), options: .usesLineFragmentOrigin, context: nil)
        }
        imageView.image = imageToLoad
    }

    @objc func shareImage() {
        guard let currentImage = imageView.image?.jpegData(compressionQuality: 0.8) else { return }

        let vc = UIActivityViewController(activityItems: [currentImage], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
