import UIKit
import RxSwift
import RxCocoa

class EditStepListViewController: UIViewController {
    
    private let viewModel: EditStepListViewModel
    weak var coordinator: MainFlowCoordinator!
    
    private let disposeBag = DisposeBag()
    
    private let tableView = UITableView()
    
    init(viewModel: EditStepListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
        
        navigationItem.title = "스탭 목록"
    }
    
    private func setupUI() {
        view.backgroundColor = .background
        navigationItem.title = "스탭 목록"

        tableView.backgroundColor = .background
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StepListTableViewCell.self, forCellReuseIdentifier: "StepListTableViewCell")
        tableView.register(AddStepTableViewCell.self, forCellReuseIdentifier: "AddStepTableViewCell")
        tableView.frame = view.bounds
        view.addSubview(tableView)
    }
    
    private func bindViewModel() {
        viewModel.stepsRelay
            .subscribe(onNext: { [weak self] step in
                self?.tableView.reloadData()
        })
        .disposed(by: disposeBag)
    }
    
    private func tapAddStepBtn() {
        let stepAddAlertController = UIAlertController(title: "추가할 단계의 유형을 선택해주세요", message: nil, preferredStyle: .actionSheet)

        stepAddAlertController.addAction(UIAlertAction(title: "텍스트", style: .default, handler: { _ in
            let addStepVC = AddTextStepViewController()
            addStepVC.onSave = { [weak self] step, completion in
                self?.viewModel.addOtherStep(step: step, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "오디오", style: .default, handler: { _ in
            let addStepVC = AddAudioStepViewController()
            addStepVC.onSave = { [weak self] audioURL, location, completion in
                self?.viewModel.addAudioTypeStep(audioURL: audioURL, location: location, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "이미지", style: .default, handler: { _ in
            let addStepVC = AddImageStepViewController()
            addStepVC.onSave = { [weak self] image, location, completion in
                self?.viewModel.addImageTypeStep(image: image, location: location, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "영상", style: .default, handler: { _ in
            let addStepVC = AddTextStepViewController()
            addStepVC.onSave = { [weak self] step, completion in
                self?.viewModel.addOtherStep(step: step, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "이동 미션", style: .default, handler: { _ in
            let addStepVC = AddTextStepViewController()
            addStepVC.onSave = { [weak self] step, completion in
                self?.viewModel.addOtherStep(step: step, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "퀴즈", style: .default, handler: { _ in
            let addStepVC = AddTextStepViewController()
            addStepVC.onSave = { [weak self] step, completion in
                self?.viewModel.addOtherStep(step: step, completion: completion)
            }
            self.navigationController?.pushViewController(addStepVC, animated: true)
            
        }))
        stepAddAlertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(stepAddAlertController, animated: true)
    }
    
    private func tapStepItem(index: Int) {
        //Todo: 스탭 수정 페이지로 이동
    }
}

extension EditStepListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.stepsRelay.value.count + 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if viewModel.stepsRelay.value.count <= indexPath.section {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "AddStepTableViewCell", for: indexPath) as? AddStepTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "StepListTableViewCell", for: indexPath) as? StepListTableViewCell else {
            return UITableViewCell()
        }

        cell.configure(with: viewModel.stepsRelay.value[indexPath.section])

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.stepsRelay.value.count == indexPath.section {
            tapAddStepBtn()
        } else {
            tapStepItem(index: indexPath.section)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.stepsRelay.value.count <= indexPath.section ? 50 : 80
    }
}

