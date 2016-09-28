//
//  BrewScoreDetailsAssembly.swift
//  Brewer
//
//  Created by Maciej Oczko on 01.05.2016.
//  Copyright © 2016 Maciej Oczko. All rights reserved.
//

import Foundation
import Swinject

final class BrewScoreDetailsAssembly: AssemblyType {
    func assemble(_ container: Container) {        
        container.registerForStoryboard(BrewScoreDetailsViewController.self) {
            r, c in c.themeConfiguration = r.resolve(ThemeConfiguration.self)
        }
        
        container.register(BrewScoreDetailsViewModelType.self) {
            (r, brew: Brew) in BrewScoreDetailsViewModel(brew: brew)
        }
    }
}
