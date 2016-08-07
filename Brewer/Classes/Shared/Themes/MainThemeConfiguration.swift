//
//  MainThemeConfigurator.swift
//  Brewer
//
//  Created by Maciej Oczko on 01.05.2016.
//  Copyright © 2016 Maciej Oczko. All rights reserved.
//

import Foundation
import UIKit

struct MainThemeConfiguration: ThemeConfiguration {
	let lightColor = UIColor.romance()
	let darkColor = UIColor.flint()
    
    let lightTintColor = UIColor.lightSkyBlue()
    let darkTintColor = UIColor.spiroDiscoBall()
    
    func defaultFontWithSize(size: CGFloat) -> UIFont {
        return UIFont.avenirBook(size)!
    }
    
    func mediumFontWithSize(size: CGFloat) -> UIFont {
        return UIFont.avenirMedium(size)!
    }

	var navigationBarConfiguration: NavigationBarThemeConfiguration {
		return MainNavigationBarThemeConfiguration(
			titleFont: UIFont.avenirMedium(17)!,
			titleColor: lightColor,
			tintColor: lightColor,
			barTintColor: darkColor,
			translucent: false
        )
	}

    var tabBarItemConfigurations: [UIControlState: TabBarItemThemeConfiguration] {
        return [
            .Normal: MainTabBarItemThemeConfiguration(font: UIFont.avenirBook(10)!, color: lightColor),
            .Selected: MainTabBarItemThemeConfiguration(font: UIFont.avenirBook(10)!, color: lightTintColor),
        ]
    }
    
    var tabBarConfiguration: TabBarThemeConfiguration {
        return MainTabBarThemeConfiguration(tintColor: lightColor, barTintColor: darkColor, translucent: false)
    }
    
    var barButtonItemConfiguration: BarButtonItemThemeConfiguration {
        return MainBarButtonItemThemeConfiguration(tintColor: lightColor)
    }
    
    // MARK: Private

	private struct MainTabBarItemThemeConfiguration: TabBarItemThemeConfiguration {
		var font: UIFont
		var color: UIColor
	}

	private struct MainTabBarThemeConfiguration: TabBarThemeConfiguration {
		var tintColor: UIColor
		var barTintColor: UIColor
		var translucent: Bool
	}

	private struct MainBarButtonItemThemeConfiguration: BarButtonItemThemeConfiguration {
		var tintColor: UIColor
	}

	private struct MainNavigationBarThemeConfiguration: NavigationBarThemeConfiguration {
		var titleFont: UIFont
		var titleColor: UIColor
		var tintColor: UIColor
		var barTintColor: UIColor
		var translucent: Bool
	}
}
