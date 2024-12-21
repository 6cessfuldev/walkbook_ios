import Foundation
import RxSwift
import RxCocoa

class WriteNewStoryViewModel {
    
    // MARK: - Inputs
    let title = BehaviorRelay<String>(value: "")
    let imageUrl = BehaviorRelay<String>(value: "")
    let description = BehaviorRelay<String>(value: "")
    let submitTapped = PublishRelay<Void>()
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    
    // MARK: - Outputs
    let isSubmitting: Driver<Bool>
    let submissionResult: Driver<Result<Void, Error>>
    
    private let _isSubmitting = BehaviorRelay<Bool>(value: false)
    private let _submissionResult = PublishRelay<Result<Void, Error>>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    private var initialStory: Story?
    private let storyUseCase: StoryUseCaseProtocol
    private let imageUseCase: ImageUseCaseProtocol
    private let userProfileUseCase: UserProfileUseCaseProtocol
    
    // MARK: - Initializer
    init(
        story: Story? = nil,
        storyUseCase: StoryUseCaseProtocol,
        imageUseCase: ImageUseCaseProtocol,
        userProfileUseCase: UserProfileUseCaseProtocol
    ) {
        self.storyUseCase = storyUseCase
        self.imageUseCase = imageUseCase
        self.userProfileUseCase = userProfileUseCase
        self.initialStory = story
        
        self.isSubmitting = _isSubmitting.asDriver()
        self.submissionResult = _submissionResult.asDriver(onErrorJustReturn: .failure(NSError(domain: "UnknownError", code: -1, userInfo: nil)))
        
        setupInitialStory()
        setupBindings()
    }
    
    // MARK: - 초기값 설정
    private func setupInitialStory() {
        if let story = initialStory {
            title.accept(story.title)
            imageUrl.accept(story.imageUrl)
            description.accept(story.description)
        }
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        bindSubmission()
//        bindImageSelection()
        bindImageUrl()
    }
    
    private func bindSubmission() {
        submitTapped
            .filter { !self._isSubmitting.value }
            .withLatestFrom(Observable.combineLatest(title, imageUrl, description))
            .filter { !$0.0.isEmpty && !$0.2.isEmpty }
            .do(onNext: { _ in self._isSubmitting.accept(true) })
            .flatMapLatest { [weak self] title, imageUrl, description -> Observable<Result<Void, Error>> in
                guard let self = self else {
                    return Observable.just(.failure(NSError(domain: "ViewModelError", code: -1, userInfo: nil)))
                }
                guard let userId = self.getAuthorId() else {
                    return Observable.just(.failure(NSError(domain: "SessionError", code: -1, userInfo: nil)))
                }
                if(self.initialStory == nil) {
                    let story = Story(
                        id: nil,
                        title: title,
                        authorId: userId,
                        imageUrl: imageUrl,
                        description: description,
                        rootChapterId: nil
                    )
                    return self.createStoryObservable(story)
                        .catch { error in
                            self._isSubmitting.accept(false)
                            return Observable.just(.failure(error))
                        }
                } else {
                    let updatedStory = Story(
                        id: initialStory?.id,
                        title: title,
                        authorId: userId,
                        imageUrl: imageUrl,
                        description: description,
                        rootChapterId: initialStory?.id
                    )
                    return self.updateStoryObservable(updatedStory)
                        .catch { error in
                            self._isSubmitting.accept(false)
                            return Observable.just(.failure(error))
                        }
                }
            }
            .do(onNext: { _ in self._isSubmitting.accept(false) })
            .bind(to: _submissionResult)
            .disposed(by: disposeBag)
    }
    
    func uploadImage() {
        guard let image = selectedImage.value, let data = image.toData() else { return }
        
        _isSubmitting.accept(true)
        
        imageUseCase.uploadImage(data) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.imageUrl.accept(url)
                case .failure(let error):
                    print("Image upload failed: \(error)")
                }
                self._isSubmitting.accept(false)
            }
        }
    }
    
    private func bindImageUrl() {
        imageUrl
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .take(initialStory != nil && !initialStory!.imageUrl.isEmpty ? 1 : 0)
            .do(onNext: { _ in self._isSubmitting.accept(true) })
            .flatMapLatest { [weak self] url -> Observable<UIImage?> in
                guard let self = self else {
                    return Observable.just(nil)
                }
                return self.loadImageFromUrl(url)
            }
            .do(onNext: { _ in self._isSubmitting.accept(false) })
            .bind(to: selectedImage)
            .disposed(by: disposeBag)
    }
    
    private func createStoryObservable(_ story: Story) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            self?.storyUseCase.createStory(story) { result in
                switch result {
                case .success(_):
                    observer.onNext(.success(()))
                case .failure(let error):
                    observer.onNext(.failure(error))
                }
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func updateStoryObservable(_ story: Story) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            self?.storyUseCase.updateStory(story) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    private func getAuthorId() -> String? {
        let result = userProfileUseCase.getUserIDFromSession()
        switch result {
        case .success(let userID):
            return userID
        case .failure:
            return nil
        }
    }
    
    private func loadImageFromUrl(_ url: String) -> Observable<UIImage?> {
        return Observable<UIImage?>.create { observer in
            guard let imageUrl = URL(string: url) else {
                observer.onNext(nil)
                observer.onCompleted()
                return Disposables.create()
            }
            
            let task = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let error = error {
                    print("Failed to load image: \(error)")
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
    }
}
