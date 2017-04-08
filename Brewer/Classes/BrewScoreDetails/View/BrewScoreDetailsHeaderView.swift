//
//  BrewScoreDetailsHeaderView.swift
//  Brewer
//
//  Created by Maciej Oczko on 03.05.2016.
//  Copyright © 2016 Maciej Oczko. All rights reserved.
//

import Foundation
import UIKit

final class BrewScoreDetailsHeaderView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!    
}

extension BrewScoreDetailsHeaderView {
    
    func configure(with theme: ThemeConfiguration?) {
        backgroundColor = theme?.darkColor
        [titleLabel, valueLabel].forEach {
            $0?.configure(with: theme)
            $0?.backgroundColor = theme?.darkColor
            $0?.textColor = theme?.lightColor
        }
    }
}
