import RxSwift
import RxCocoa

class EditChapterViewModel {
    
    // MARK: - Properties
    let title = BehaviorRelay<String?>(value: nil)
    let description = BehaviorRelay<String?>(value: nil)
    let selectedImage = BehaviorRelay<UIImage?>(value: nil)
    let imageUrl = BehaviorRelay<String?>(value: nil)
    let submitTapped = PublishRelay<Void>()
    
    let isSubmitting = BehaviorRelay<Bool>(value: false)
    let isImageLoading = BehaviorRelay<Bool>(value: false)
    let alertMessage = PublishRelay<String>()
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Dependencies
    private var chapter: Chapter
    private let chapterUseCase: ChapterUseCaseProtocol
    private let mediaUseCase: MediaUseCaseProtocol
    private let userProfileUseCase: UserProfileUseCaseProtocol
    
    // MARK: - Initializer
    
    init(chapter: NestedChapter, chapterUseCase: ChapterUseCaseProtocol, mediaUseCase: MediaUseCaseProtocol, userProfileUseCase: UserProfileUseCaseProtocol) {
        
        self.chapter = Chapter.fromNestedChapter(chapter)
        self.chapterUseCase = chapterUseCase
        self.mediaUseCase = mediaUseCase
        self.userProfileUseCase = userProfileUseCase
        
        setupInitialChapter()
        setupBindings()
    }
    
    // MARK: - 초기값 설정
    private func setupInitialChapter() {
        title.accept(chapter.title)
        imageUrl.accept(chapter.imageUrl)
        description.accept(chapter.description)
    }
    
    // MARK: - Bindings
    private func setupBindings() {
        tapBinding()
        bindImageUrl()
    }
    
    func uploadImage() {
        guard let image = selectedImage.value, let data = image.toData() else { return }
        
        isSubmitting.accept(true)
        
        mediaUseCase.uploadImage(data) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let url):
                    self.imageUrl.accept(url)
                case .failure(let error):
                    print("Image upload failed: \(error)")
                }
                self.isSubmitting.accept(false)
            }
        }
    }
    
    func getChapterId() -> String? {
        chapter.id
    }
    
    // MARK: - Input Handlers
    
    private func tapBinding() {
        submitTapped
            .filter { !self.isSubmitting.value }
            .withLatestFrom(Observable.combineLatest(title, imageUrl, description))
            .do(onNext: { _ in self.isSubmitting.accept(true) })
            .flatMapLatest { [weak self] title, imageUrl, description -> Observable<Result<Void, Error>> in
                guard let self = self else {
                    return Observable.just(.failure(NSError(domain: "ViewModelError", code: -1, userInfo: nil)))
                }
                
                guard let title = title, !title.isEmpty else {
                    self.alertMessage.accept("제목을 입력해주세요.")
                    self.isSubmitting.accept(false)
                    return Observable.empty()
                }

                guard let description = description, !description.isEmpty else {
                    self.alertMessage.accept("설명을 입력해주세요.")
                    self.isSubmitting.accept(false)
                    return Observable.empty()
                }

                guard let imageUrl = imageUrl, !imageUrl.isEmpty else {
                    self.alertMessage.accept("이미지 URL을 입력해주세요.")
                    self.isSubmitting.accept(false)
                    return Observable.empty()
                }

                return self.performSubmission(
                    title: title,
                    imageUrl: imageUrl,
                    description: description
                )
            }
            .do(onNext: { _ in self.isSubmitting.accept(false) })
            .subscribe(onNext: { [weak self] result in
                switch result {
                case .success:
                    self?.alertMessage.accept("저장되었습니다.")
                case .failure(let error):
                    self?.alertMessage.accept("오류: \(error.localizedDescription)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: - Private Helpers
    
    private func performSubmission(
        title: String,
        imageUrl: String,
        description: String
    ) -> Observable<Result<Void, Error>> {
        guard let userId = self.getAuthorId() else {
            return Observable.just(.failure(NSError(domain: "SessionError", code: -1, userInfo: nil)))
        }
        
        var needUpdatedChapter = chapter
        needUpdatedChapter.title = title
        needUpdatedChapter.description = description
        needUpdatedChapter.imageUrl = imageUrl
        
        let observable: Observable<Result<Void, Error>>
        
        observable = self.updateChapterObservable(chapter)
        
        return observable
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
    
    private func bindImageUrl() {
        imageUrl
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .distinctUntilChanged()
            .take(chapter.imageUrl != nil && !chapter.imageUrl!.isEmpty ? 1 : 0)
            .do(onNext: { _ in self.isSubmitting.accept(true) })
            .flatMapLatest { [weak self] url -> Observable<UIImage?> in
                guard let self = self else {
                    return Observable.just(nil)
                }
                return self.loadImageFromUrl(url)
            }
            .do(onNext: { _ in self.isSubmitting.accept(false) })
            .bind(to: selectedImage)
            .disposed(by: disposeBag)
    }
    
    private func updateChapterObservable(_ chapter: Chapter) -> Observable<Result<Void, Error>> {
        return Observable.create { [weak self] observer in
            self?.chapterUseCase.updateChapter(chapter) { result in
                observer.onNext(result)
                observer.onCompleted()
            }
            return Disposables.create()
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
