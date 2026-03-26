import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        activityIndicator.startAnimating()
        self.view.addSubview(activityIndicator)
        
        handleSharedImage()
    }

    private func handleSharedImage() {
        guard let extensionContext = extensionContext else { return }
        
        for item in extensionContext.inputItems as? [NSExtensionItem] ?? [] {
            for provider in item.attachments ?? [] {
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { [weak self] (data, error) in
                        guard let self = self else { return }
                        
                        var image: UIImage?
                        if let url = data as? URL, let imageData = try? Data(contentsOf: url) {
                            image = UIImage(data: imageData)
                        } else if let uiImage = data as? UIImage {
                            image = uiImage
                        } else if let imageData = data as? Data {
                            image = UIImage(data: imageData)
                        }
                        
                        if let image = image {
                            self.saveAndRedirect(image)
                        } else {
                            self.dismiss()
                        }
                    }
                    return
                }
            }
        }
        self.dismiss()
    }

    private func saveAndRedirect(_ image: UIImage) {
        let appGroupId = "group.com.xiaobai.memofluxapp"
        guard let sharedContainerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) else {
            return
        }
        
        let fileName = "shared_image_\(Date().timeIntervalSince1970).jpg"
        let fileURL = sharedContainerURL.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            
            let url = URL(string: "memoflux://share?imagePath=\(fileName)")!
            self.openURL(url)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
            }
        }
    }

    @objc func openURL(_ url: URL) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(NSSelectorFromString("openURL:options:completionHandler:"), with: url, with: [:])
                return
            }
            responder = responder?.next
        }
    }
    
    private func dismiss() {
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
}
