# CELOIPFSImage ChangeLog

Change Log file for the dacade [Celo Development 101](https://dacade.org/communities/celo-development-101) dApp submission by [abrahamic](https://dacade.org/communities/celo-development-101/submissions/475f0b89-7010-4500-b89c-1e6479c2d564).

**```Keywords```**

* `Added` for new features.
* `Changed` for changes in existing functionality.
* `Deprecated` for soon-to-be removed features.
* `Removed` for now removed features.
* `Fixed` for any bug fixes.
* `Security` in case of vulnerabilities.

## [emmanuelJet](https://github.com/emmanuelJet) - 2021-08-26

**Contract Review:** First, a nice implementation of the `msg.value` method to sending tokens. I started my review by increasing the contact scope with three new structs (`AdminInfo`, `PaymentInfo`, and `PaymentTran`). This struct helps saves admin and payment information in the `admins` and `payments` maps. The `AdminInfo` struct allows the contacts admins to perform admin-based functions with an included `verifyContractAdmin` modifier. The `PaymentInfo` struct helps record all payment transactions information on the contract (employeeID, amountPaid, paymentID, paidOn, and paidBy variables) to allow the contract owner to know each payment information. The `PaymentTran` struct does not save anything in the contract state. It assists the contact to save some variables that verify and assist the contact for a successful payment from an admin to an employee. I then introduced two new addresses (`deadAddress` and `ownerAddress`) and removed the declaration on the `cUsdTokenAddress` address. I removed the declaration to allow assigning the values of the three addresses in the contract constructor. The `deadAddress` is the default address Solidity gives an address that is empty or null. The `cUsdTokenAddress` would remain the same as CELO USD Contract Address. The `ownerAddress` is the contract deployer address that serves as the super admin user with the `verifyContractOwner` modifier to restrict some functions to the user. Keeping my review feedback short, I ensured to comment as much as I could on the contact to explain better its interface, structs, variables, maps, contructor, modifiers, and functions. However, the functions I included on the contract are `addAdmin`, `changeCanPayStatus`, `getOwnerProfile`, `getAdminProfile`, `getPayment` and `addPayment`. Other existing functions I updated are `addEmployee`, `makePayment`, and `getEmployee`. Find the *emmanuelJetReview* directory containing *SalaryCalculator.sol* and *salaryCalculator.abi.json* files to see the contract. Lastly, I used the return instead emit (An Event-based function that logs output) method to produce outputs on the contract send function. Note: For the ownerAddress to have full access to the contact functions the user with the address needs to be an admin. **DApp Review:** For better dApp optimization, use a JavaScript front-end framework with or without webpack. I feel this will make implementation easy to produce a better UX for users. Also, you can use a GitHub action or the *gh-pages* npm package to deploy your dApp to GitHub instead of using the docs method. **Design Review:** To utilize the functionalities I included on the contact, here is a flow the design can follow. You start with an authentication page. This page can display the connected wallet address with two buttons. The first button for the contract owner leads to another page (say `ownerPage`) with all the contact owner-only functions after successful authentication with the `getOwnerProfile` function. The second button for contract admin leads to another page (say `adminPage`) with all admin-only functions after successful authentication with the `getAdminProfile` function. The `ownerPage` can then display the return wallet address from the `getOwnerProfile` function alongside the balance of the connected wallet. The `ownerPage` can then have sections for the owner-only functions (`paymentCount`, `addAdmin`, `changeCanPayStatus`, and `getPayment`). And then to the `adminPage` displays the returned information from the `getAdminProfile` authentication function. You can decide to make the canPay bool variable display an alert to notify the admin of the account status to pay employees. The `adminPage` can then have sections for the admin-only functions (`employeeCount`, `addEmployee`, `makePayment`, and `getEmployee`). This review changes the initial flow of the dApp to having an owner and admin structure where the owner modifies admins and sees payment records. Then the admins can add and see employees with the ability to pay employees.

### Added

* SalaryCalculator.sol file
* salaryCalculator.abi.json file
* .editorconfig file
* .gitignore
* CHANGELOG.md file
