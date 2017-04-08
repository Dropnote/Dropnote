//
//  BrewDetailsViewController.swift
//  Brewer
//
//  Created by Maciej Oczko on 09.04.2016.
//  Copyright © 2016 Maciej Oczko. All rights reserved.
//

import Foundation
import UIKit
import Swinject

extension BrewDetailsViewController: ThemeConfigurable { }
extension BrewDetailsViewController: ThemeConfigurationContainer { }
extension BrewDetailsViewController: ResolvableContainer { }

final class BrewDetailsViewController: UIViewController {
	private lazy var tableView: UITableView = {
		let tableView = UITableView(frame: .zero, style: .plain)
		tableView.tableFooterView = UIView()
		tableView.estimatedRowHeight = 50
		tableView.rowHeight = UITableViewAutomaticDimension
		tableView.delegate = self
		return tableView
	}()

	let resolver: ResolverType
	var themeConfiguration: ThemeConfiguration?
	let viewModel: BrewDetailsViewModelType

    fileprivate weak var pushedViewController: UIViewController?

	init(viewModel: BrewDetailsViewModelType, themeConfiguration: ThemeConfiguration? = nil, resolver: ResolverType = Assembler.sharedResolver) {
		self.viewModel = viewModel
		self.themeConfiguration = themeConfiguration
		self.resolver = resolver
		super.init(nibName: nil, bundle: nil)
		title = tr(.brewDetailsItemTitle)
	}
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

	override func viewDidLoad() {
		super.viewDidLoad()
		viewModel.configureWithTableView(tableView)
        enableSwipeToBack()
        navigationController?.delegate = self
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        deactivatePushedViewController()
        
        configureWithTheme(themeConfiguration)
		tableView.configureWithTheme(themeConfiguration)
		viewModel.refreshData()

        tableView.setNeedsLayout()
        tableView.layoutIfNeeded()
        tableView.reloadData()
    
        Analytics.sharedInstance.trackScreen(withTitle: AppScreen.brewDetails)
	}
    
	override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.saveBrewIfNeeded()
    }

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
		switch segueIdentifierForSegue(segue) {
		case .BrewScoreDetails:
			let viewController = segue.destination as! BrewScoreDetailsViewController
			viewController.viewModel = resolver.resolve(BrewScoreDetailsViewModelType.self,
														argument: viewModel.currentBrew())!
			break
		default:
			fatalError("Unknown segue performed.")
		}

        segue.destination.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(asset: .Ic_back),
            style: .plain,
            target: self,
            action: #selector(pop)
        )
        segue.destination.enableSwipeToBack()
        pushedViewController = segue.destination
	}

    fileprivate func deactivatePushedViewController() {
        if let pushedViewController = pushedViewController {
            if var activable = pushedViewController as? Activable {
                activable.active = false
            }
            self.pushedViewController = nil
        }
    }

    fileprivate func removeCurrentBrewIfNeeded() {
        let alertController = UIAlertController(title: tr(.brewDetailsConfirmationTitle), message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: tr(.brewDetailsConfirmationYes), style: .destructive) {
            _ in
            self.viewModel.removeCurrentBrew {
                [weak self] didRemove in
                if didRemove {
                    _ = self?.navigationController?.popViewController(animated: true)
                }
            }
        })
        alertController.addAction(UIAlertAction(title: tr(.brewDetailsConfirmationNo), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

extension BrewDetailsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = true
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = false
    }

	func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.accessibilityLabel = "Select \((indexPath as NSIndexPath).row + 1)"
		(cell as? FinalScoreCell)?.configureWithTheme(themeConfiguration)
		(cell as? BrewAttributeCell)?.configureWithTheme(themeConfiguration)
		(cell as? BrewNotesCell)?.configureWithTheme(themeConfiguration)
		(cell as? BrewDetailsRemoveCell)?.configureWithTheme(themeConfiguration)
        if case .disclosureIndicator = cell.accessoryType {
            cell.accessoryView = UIImageView(image: UIImage(asset: .Ic_arrow))
        } else {
            cell.accessoryView = nil
        }
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		// TODO refactor when all controllers are changed
        switch viewModel.sectionType(forIndexPath: indexPath) {
			case .score:
				performSegue(.BrewScoreDetails)
				break
			case .coffeeInfo:
				guard viewModel.editable else { return }
				let identifier = viewModel.coffeeAttribute(forIndexPath: indexPath)
				let selectableSearchViewController = resolver.resolve(SelectableSearchViewController.self,
																	  arguments: identifier, viewModel.brewModelController)!
				selectableSearchViewController.title = identifier.description
				selectableSearchViewController.enableSwipeToBack()
				selectableSearchViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
						image: UIImage(asset: .Ic_back),
						style: .plain,
						target: self,
						action: #selector(pop)
				)
				pushedViewController = selectableSearchViewController
				navigationController?.pushViewController(selectableSearchViewController, animated: true)
				break
			case .attributes:
				guard viewModel.editable else { return }
				let brewAttributeType = viewModel.brewAttributeType(forIndexPath: indexPath)
				let viewController: UIViewController
				switch brewAttributeType.segueIdentifier {
					case .NumericalInput:
						viewController = resolver.resolve(NumericalInputViewController.self,
														  arguments: brewAttributeType, viewModel.brewModelController)!
						break
					case .Tamping:
						viewController = resolver.resolve(TampingViewController.self,
														  argument: viewModel.brewModelController)!
						break
					case .GrindSize:
						viewController = resolver.resolve(GrindSizeViewController.self,
														  argument: viewModel.brewModelController)!
						break
					default: fatalError()
				}
				viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
						image: UIImage(asset: .Ic_back),
						style: .plain,
						target: self,
						action: #selector(pop)
				)
				pushedViewController = viewController
				viewController.enableSwipeToBack()
				navigationController?.pushViewController(viewController, animated: true)
				break
			case .notes:
				let notesViewController = resolver.resolve(NotesViewController.self, argument: viewModel.brewModelController)!
				notesViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
						image: UIImage(asset: .Ic_back),
						style: .plain,
						target: self,
						action: #selector(pop)
				)
				pushedViewController = notesViewController
				notesViewController.enableSwipeToBack()
				navigationController?.pushViewController(notesViewController, animated: true)
				break
			case .remove:
				removeCurrentBrewIfNeeded()
				break
		}
	}
}

extension BrewDetailsViewController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if var activable = viewController as? Activable {
            activable.active = true
        }
    }
}
