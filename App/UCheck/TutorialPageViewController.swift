//
//  TutorialPageViewController.swift
//  UCheck
//
//  Created by Ezaan Mangalji on 2017-12-01.
//

import UIKit

class TutorialPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    lazy var VCArr: [UIViewController] = {
        return [//self.VCInstance(name: "TutorialOneVC"),
                self.VCInstance(name: "TutorialTwoVC"),
                self.VCInstance(name: "TutorialThreeVC")]
    }()
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = VCArr.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = view.superview!.bounds
            } else if view is UIPageControl {
                let pos = CGPoint(x: view.frame.midX - (view.frame.width / 2), y: self.view.frame.height - 80 - view.frame.height)
                view.frame = CGRect(origin: pos, size: view.frame.size)
                let pageControl = view as! UIPageControl
                pageControl.currentPageIndicatorTintColor = Colors.lightRed
                pageControl.pageIndicatorTintColor = UIColor.gray
                view.backgroundColor = UIColor.clear
            }
        }
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return VCArr.last
        }
        
        guard VCArr.count > previousIndex else {
            return nil
        }
        
        return VCArr[previousIndex]
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArr.count else {
            return VCArr.first
        }
        
        guard VCArr.count > nextIndex else {
            return nil
        }
        
        return VCArr[nextIndex]
    }
    
    
    public func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArr.count
    }

    public func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.index(of: firstViewController) else {
                return 0
        }

        return firstViewControllerIndex
    }
}
