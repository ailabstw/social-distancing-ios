//
//  IntroductionViewController.swift
//  Tracer
//
//  Created by Shiva Huang on 2020/4/1.
//  Copyright © 2020 AI Labs. All rights reserved.
//

import SnapKit
import UIKit

class IntroductionViewController: UIPageViewController {
    private var viewModel: IntroductionViewModel
    
    init(viewModel: IntroductionViewModel) {
        self.viewModel = viewModel
        
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = Color.background
        
        self.dataSource = self
        
        self.setViewControllers([IntroductionPageViewController(viewModel: viewModel.introductions.first!)], direction: .forward, animated: true, completion: nil)
        
        let appearance = UIPageControl.appearance(whenContainedInInstancesOf: [UIPageViewController.self])
        appearance.pageIndicatorTintColor = Color.pageIndicatorTintColor
        appearance.currentPageIndicatorTintColor = Color.currentPageIndicatorTintColor
        appearance.backgroundColor = Color.background

        viewModel.$title { [weak self] (title) in
            self?.title = title
        }
    }
}

extension IntroductionViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let model = (viewController as? IntroductionPageViewController)?.viewModel,
            let beforeIntro = viewModel.introduction(before: model) else {
                return nil
        }
        
        return IntroductionPageViewController(viewModel: beforeIntro)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let model = (viewController as? IntroductionPageViewController)?.viewModel,
            let nextIntro = viewModel.introduction(after: model) else {
                return nil
        }
        
        return IntroductionPageViewController(viewModel: nextIntro)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewModel.introductions.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}

extension IntroductionViewController {
    enum Color {
        static let pageIndicatorTintColor = UIColor.white
        static let currentPageIndicatorTintColor = UIColor(red: (46/255.0), green: (182/255.0), blue: (169/255.0), alpha: 1)
        static let background = UIColor(white: 235.0/255.0, alpha: 1.0)
    }
}
