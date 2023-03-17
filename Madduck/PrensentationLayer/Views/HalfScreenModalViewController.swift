//
//  HalfModalViewController.swift
//  Madduck
//
//  Created by Furkan on 16.03.2023.
//

import UIKit

final class HalfScreenModalViewController: BaseViewController {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = .boldSystemFont(ofSize: 20)
        return label
    }()

    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        let closeImage = UIImage(named: "icon.close")?.withRenderingMode(.alwaysTemplate)
        button.setImage(closeImage, for: .normal)
        button.tintColor = .white
        return button
    }()

    lazy var contentView: UIView = {
        let view_ = UIView()
        view_.translatesAutoresizingMaskIntoConstraints = false
        return view_
    }()

    lazy var containerView: UIView = {
        let view_ = UIView()
        view_.translatesAutoresizingMaskIntoConstraints = false
        view_.backgroundColor = .black
        view_.layer.cornerRadius = 16
        view_.clipsToBounds = true
        return view_
    }()

    let maxDimmedAlpha: CGFloat = 0.6
    lazy var dimmedView: UIView = {
        let view_ = UIView()
        view_.backgroundColor = .black
        view_.alpha = maxDimmedAlpha
        return view_
    }()

    let defaultHeight: CGFloat = 300
    let dismissibleHeight: CGFloat = 200
    let maximumContainerHeight: CGFloat = UIScreen.main.bounds.height - 64
    var currentContainerHeight: CGFloat = 300

    // Dynamic container constraint
    var containerViewHeightConstraint: NSLayoutConstraint?
    var containerViewBottomConstraint: NSLayoutConstraint?

    private let contentViewController: UIViewController

    required init(frame: CGRect = .zero, title: String, contentViewController: UIViewController) {
        self.contentViewController = contentViewController

        super.init(nibName: nil, bundle: nil)
        self.title = title

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = UIView()

        setupView()
        setupConstraints()

    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleCloseAction))
        dimmedView.addGestureRecognizer(tapGesture)

        setupPanGesture()

        addChild(contentViewController)
        contentView.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        contentViewController.view.frame = contentView.bounds
    }

    @objc func handleCloseAction() {
        animateDismissView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateShowDimmedView()
        animatePresentContainer()

    }

    func setupView() {
        let backButton = UIBarButtonItem(title: nil,
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleCloseAction))

        let closeImage = UIImage(named: "icon.close")?.withRenderingMode(.alwaysTemplate)
        backButton.image = closeImage
        backButton.tintColor = .white

        navigationItem.rightBarButtonItem = backButton
    }

    func setupConstraints() {
        // Add subviews
        view.addSubview(dimmedView)
        view.addSubview(containerView)
        view.addSubview(closeButton)

        addChild(contentViewController)
        contentViewController.view.frame = self.contentView.frame
        contentView.addSubview(contentViewController.view)
        contentViewController.didMove(toParent: self)

        dimmedView.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(titleLabel)
        containerView.addSubview(contentView)


        // Set static constraints
        NSLayoutConstraint.activate([
            // set close button constraint
            closeButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            closeButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 20.0),

            // set dimmedView edges to superview
            dimmedView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmedView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmedView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmedView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // set container static constraint (trailing & leading)
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),

            // content stackView
            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12.0),
            contentView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            contentView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),

        ])

        // Set dynamic constraints
        // First, set container to default height
        // after panning, the height can expand
        containerViewHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: defaultHeight)

        // By setting the height to default height, the container will be hide below the bottom anchor view
        // Later, will bring it up by set it to 0
        // set the constant to default height to bring it down again
        containerViewBottomConstraint = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: defaultHeight)
        // Activate constraints
        containerViewHeightConstraint?.isActive = true
        containerViewBottomConstraint?.isActive = true
    }

    func setupPanGesture() {
        // add pan gesture recognizer to the view controller's view (the whole screen)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(gesture:)))
        // change to false to immediately listen on gesture movement
        panGesture.delaysTouchesBegan = false
        panGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(panGesture)
    }

    // MARK: Pan gesture handler
    @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        // Drag to top will be minus value and vice versa
        print("Pan gesture y offset: \(translation.y)")

        // Get drag direction
        let isDraggingDown = translation.y > 0
        print("Dragging direction: \(isDraggingDown ? "going down" : "going up")")

        // New height is based on value of dragging plus current container height
        let newHeight = currentContainerHeight - translation.y

        // Handle based on gesture state
        switch gesture.state {
        case .changed:
            // This state will occur when user is dragging
            if newHeight < maximumContainerHeight {
                // Keep updating the height constraint
                containerViewHeightConstraint?.constant = newHeight
                // refresh layout
                view.layoutIfNeeded()
            }
        case .ended:
            // This happens when user stop drag,
            // so we will get the last height of container

            // Condition 1: If new height is below min, dismiss controller
            if newHeight < dismissibleHeight {
                self.animateDismissView()
            }
            else if newHeight < defaultHeight {
                // Condition 2: If new height is below default, animate back to default
                animateContainerHeight(defaultHeight)
            }
            else if newHeight < maximumContainerHeight && isDraggingDown {
                // Condition 3: If new height is below max and going down, set to default height
                animateContainerHeight(defaultHeight)
            }
            else if newHeight > defaultHeight && !isDraggingDown {
                // Condition 4: If new height is below max and going up, set to max height at top
                animateContainerHeight(maximumContainerHeight)
            }
        default:
            break
        }
    }

    func animateContainerHeight(_ height: CGFloat) {
        UIView.animate(withDuration: 0.4) {
            // Update container height
            self.containerViewHeightConstraint?.constant = height
            // Call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
        // Save current height
        currentContainerHeight = height
    }

    // MARK: Present and dismiss animation
    func animatePresentContainer() {
        // update bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = 0
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }

    func animateShowDimmedView() {
        dimmedView.alpha = 0
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = self.maxDimmedAlpha
        }
    }

    func animateDismissView() {
        // hide blur view
        dimmedView.alpha = maxDimmedAlpha
        UIView.animate(withDuration: 0.4) {
            self.dimmedView.alpha = 0
        } completion: { _ in
            // once done, dismiss without animation
            self.dismiss(animated: false)
        }
        // hide main view by updating bottom constraint in animation block
        UIView.animate(withDuration: 0.3) {
            self.containerViewBottomConstraint?.constant = self.defaultHeight
            // call this to trigger refresh constraint
            self.view.layoutIfNeeded()
        }
    }
}
