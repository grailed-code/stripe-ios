//
//  AccountPickerSelectionListView.swift
//  StripeFinancialConnections
//
//  Created by Krisjanis Gaidis on 8/22/22.
//

import Foundation
import UIKit
@_spi(STP) import StripeUICore

protocol AccountPickerSelectionListViewDelegate: AnyObject {
    func accountPickerSelectionListView(
        _ view: AccountPickerSelectionListView,
        didSelectAccounts selectedAccounts: [FinancialConnectionsPartnerAccount]
    )
}

final class AccountPickerSelectionListView: UIView {
    
    private let selectionType: AccountPickerSelectionRowView.SelectionType
    private let enabledAccounts: [FinancialConnectionsPartnerAccount]
    private let disabledAccounts: [FinancialConnectionsPartnerAccount]
    weak var delegate: AccountPickerSelectionListViewDelegate?
    
    private lazy var verticalStackView: UIStackView = {
        let verticalStackView = UIStackView()
        verticalStackView.spacing = 12
        verticalStackView.axis = .vertical
        return verticalStackView
    }()
    
    init(
        selectionType: AccountPickerSelectionRowView.SelectionType,
        enabledAccounts: [FinancialConnectionsPartnerAccount],
        disabledAccounts: [FinancialConnectionsPartnerAccount]
    ) {
        self.selectionType = selectionType
        self.enabledAccounts = enabledAccounts
        self.disabledAccounts = disabledAccounts
        super.init(frame: .zero)
        addAndPinSubviewToSafeArea(verticalStackView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func selectAccounts(_ selectedAccounts: [FinancialConnectionsPartnerAccount]) {
        // clear all previous state
        verticalStackView.arrangedSubviews.forEach { arrangedSubview in
            arrangedSubview.removeFromSuperview()
        }
        
        if selectionType == .checkbox {
            // show a "all accounts" cell
            let allAccountsCellView = AccountPickerSelectionRowView(
                selectionType: .checkbox,
                isDisabled: false,
                didSelect: { [weak self] in
                    guard let self = self else { return }
                    let isAllAccountsSelected = (self.enabledAccounts.count == selectedAccounts.count)
                    var selectedAccounts = selectedAccounts
                    if isAllAccountsSelected {
                        selectedAccounts.removeAll()
                    } else {
                        selectedAccounts = self.enabledAccounts
                    }
                    self.delegate?.accountPickerSelectionListView(self, didSelectAccounts: selectedAccounts)
                }
            )
            allAccountsCellView.setTitle(
                STPLocalizedString("All accounts", "A button that allows users to select all their bank accounts. This button appears in a screen that allows users to select which bank accounts they want to use to pay for something."),
                subtitle: nil,
                isSelected: (enabledAccounts.count == selectedAccounts.count)
            )
            verticalStackView.addArrangedSubview(allAccountsCellView)
        }
        
        // list enabled accounts
        enabledAccounts.forEach { account in
            let accountCellView = AccountPickerSelectionRowView(
                selectionType: selectionType,
                isDisabled: false,
                didSelect: { [weak self] in
                    guard let self = self else { return }
                    var selectedAccounts = selectedAccounts
                    if let index = selectedAccounts.firstIndex(where: { $0.id == account.id }) {
                        selectedAccounts.remove(at: index)
                    } else {
                        if self.selectionType == .checkbox {
                            selectedAccounts.append(account)
                        } else { // radiobutton
                            selectedAccounts = [account] // select only one account
                        }
                    }
                    self.delegate?.accountPickerSelectionListView(self, didSelectAccounts: selectedAccounts)
                }
            )
            accountCellView.setTitle(
                account.name,
                subtitle: {
                    if let displayableAccountNumbers = account.displayableAccountNumbers {
                        return "••••••••\(displayableAccountNumbers)"
                    } else {
                        return nil
                    }
                }(),
                isSelected: selectedAccounts.contains(where: { $0.id == account.id })
            )
            verticalStackView.addArrangedSubview(accountCellView)
        }
        
        // list disabled accounts
        disabledAccounts.forEach { account in
            let accountCellView = AccountPickerSelectionRowView(
                selectionType: selectionType,
                isDisabled: true,
                didSelect: {
                    // can't select disabled accounts
                }
            )
            accountCellView.setTitle(
                account.name,
                subtitle: {
                    if let displayableAccountNumbers = account.displayableAccountNumbers {
                        return "••••••••\(displayableAccountNumbers)"
                    } else {
                        return nil
                    }
                }(),
                isSelected: false
            )
            verticalStackView.addArrangedSubview(accountCellView)
        }
    }
}
