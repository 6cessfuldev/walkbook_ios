import RxSwift
import RxCocoa

extension UIImageView {
    func setImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { observer in
            guard let imageUrl = URL(string: url), imageUrl.scheme == "http" || imageUrl.scheme == "https" else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let error = error {
                    observer.onNext(nil)
                } else if let data = data, let image = UIImage(data: data) {
                    observer.onNext(image)
                } else {
                    observer.onNext(nil)
                }
                observer.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
        .observe(on: MainScheduler.instance)
        .do(onNext: { [weak self] image in
            self?.image = image
        })
    }
}
