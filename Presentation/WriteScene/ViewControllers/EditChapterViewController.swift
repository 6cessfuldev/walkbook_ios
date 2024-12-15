import UIKit
import RxSwift
import RxCocoa

class EditChapterViewController: UIViewController {
    
    // MARK: - Properties
    private let viewModel: EditChapterViewModel
    weak var coordinator: MainFlowCoordinator!
    
    private let disposeBag = DisposeBag()
    
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Chapter Title"
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    private let selectImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Select Image", for: .normal)
        return button
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.layer.borderColor = UIColor.lightGray.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 14)
        return textView
    }()
    
    private let tableView = UITableView()
    private let addStepButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Step", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Lifecycle
    init(viewModel: EditChapterViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBindings()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .background
        navigationItem.title = "챕터 내용 수정"
        
        view.addSubview(titleTextField)
        view.addSubview(imageView)
        view.addSubview(selectImageButton)
        view.addSubview(descriptionTextView)
        view.addSubview(tableView)
        view.addSubview(addStepButton)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        selectImageButton.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        addStepButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            imageView.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 16),
            imageView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200),
            
            selectImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            selectImageButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: selectImageButton.bottomAnchor, constant: 16),
            descriptionTextView.leadingAnchor.constraint(equalTo: titleTextField.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: titleTextField.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            tableView.topAnchor.constraint(equalTo: descriptionTextView.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addStepButton.topAnchor, constant: -16),
            
            addStepButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addStepButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addStepButton.widthAnchor.constraint(equalToConstant: 120),
            addStepButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        tableView.register(StepTableViewCell.self, forCellReuseIdentifier: "StepCell")
        tableView.dataSource = self
    }
    
    private func setupBindings() {
        titleTextField.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        descriptionTextView.rx.text.orEmpty
            .bind(to: viewModel.description)
            .disposed(by: disposeBag)
        
        viewModel.selectedImage
            .asDriver(onErrorJustReturn: nil)
            .filter { $0 != nil }
            .drive(onNext: { [weak self] image in
                self?.imageView.image = image
            })
            .disposed(by: disposeBag)
        
        addStepButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.addStep()
            })
            .disposed(by: disposeBag)
        
        let tapGesture = UITapGestureRecognizer()
        imageView.addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .bind { [weak self] _ in
                self?.presentImagePicker()
            }
            .disposed(by: disposeBag)
    }
    
    private func presentImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func addStep() {
        let addStepVC = AddStepViewController()
        addStepVC.modalPresentationStyle = .overFullScreen

        addStepVC.onSave = { [weak self] title in
            self?.viewModel.addOtherStep(title: title)
        }

        present(addStepVC, animated: true, completion: nil)
    }
}

// MARK: - TableView DataSource
extension EditChapterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chapter.value.steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as? StepTableViewCell else {
            return UITableViewCell()
        }
        let step = viewModel.chapter.value.steps[indexPath.row]
        cell.configure(with: step)
        return cell
    }
}

extension EditChapterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            viewModel.selectedImage.accept(image)
        }
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Custom Step Cell
class StepTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let editButton = UIButton(type: .system)
    private let deleteButton = UIButton(type: .system)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        editButton.setTitle("Edit", for: .normal)
        deleteButton.setTitle("Delete", for: .normal)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            deleteButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            editButton.trailingAnchor.constraint(equalTo: deleteButton.leadingAnchor, constant: -8),
            editButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    func configure(with step: Step) {
        titleLabel.text = step.type.stringValue
    }
}
