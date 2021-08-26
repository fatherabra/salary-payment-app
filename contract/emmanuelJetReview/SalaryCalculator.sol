// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0;

/// @title A contract to manage salary transactions of employees
/// @notice You can use this contract for only development purposes
/// @dev You can contribute to this contract to fix bugs or errors
/// @custom:experimental This is an experimental contract

/**
* @title Represents the cUSD token contract interface
*/
interface CUSDToken {
  function approve(address, uint256) external returns (bool);
  function balanceOf(address) external view returns (uint256);
  function transferFrom(address, address, uint256) external returns (bool);
}

contract SalaryCalculator {
  /** 
  * @title Represents a single contract Admin information
  */
  struct AdminInfo {
    address payable wallet;
    string  name;
    bool    canPay;
    uint256 createdOn;
  }

  /** 
  * @title Represents a single contract Employee information 
  */
  struct EmployeeInfo {
    address payable wallet;
    string  name;
    string  jobTitle;
    uint256 employeeID;
    uint256 annualSalary;
    uint256 createdOn;
    address createdBy;
  }

  /** 
  * @title Represents a single contract Payment information 
  */
  struct PaymentInfo {
    uint256 employeeID;
    uint256 amountPaid;
    uint256 paymentID;
    uint256 paidOn;
    address paidBy;
  }

  /** 
  * @title Represents a single payment transaction information 
  */
  struct PaymentTran {
    uint256 amountPaid;
    uint256 paymentID;
    uint256 paidOn;
    uint256 employeeMonthlySalary;
    uint256 adminBalance;
  }

  /// @notice ETH default empty address: 0x0000000000000000000000000000000000000000
  address internal deadAddress;
  /// @notice cUSD default contract address: 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1
  address internal cUsdTokenAddress;
  /// @notice Contract Deployer Address
  address payable internal ownerAddress;

  /// @notice Contract payment count
  uint256 public paymentCount = 0;
  /// @notice Contract employee count
  uint256 public employeeCount = 0;

  /// @notice Maps AdminInfo to an address identifier
  mapping (address => AdminInfo) internal admins;
  /// @notice Maps EmployeeInfo to an employeeCount identifier
  mapping (uint256 => EmployeeInfo) internal employees;
  /// @notice Maps AdminInfo to a paymentCount identifier
  mapping (uint256 => PaymentInfo) internal payments;

  /**
  * @notice Configuring contract information
  * @param _deadAddress The default ETH empty address
  * @param _cUsdTokenAddress The default cUSD contract address
  */
  constructor(
    address _deadAddress,
    address _cUsdTokenAddress
  ) {
    deadAddress = _deadAddress;
    ownerAddress = payable(msg.sender);
    cUsdTokenAddress = _cUsdTokenAddress;
  }

  /**
  * @notice Ensures the contract deployer address
  */
  modifier verifyContractOwner() {
    require(msg.sender == ownerAddress, "Error 401: Unauthorized owner access.");
    _;
  }

  /**
  * @notice Ensure an admin account status on the contract
  * @param _adminAddress The intending wallet of the admin
  */
  modifier verifyContractAdmin(address _adminAddress) {
    address adminAddress = admins[_adminAddress].wallet;
    require(msg.sender == adminAddress, "Error 401: Unauthorized admin access");
    _;
  }

  /**
  * @notice Adds an admin with AdminInfo struct to the admins map
  * @dev Uses the verifyContractOwner modifier
  * @param _wallet The intending to add admin wallet address
  * @param _name The intending to add admin name
  * @return wallet The new admin wallet address
  * @return name The new admin name
  * @return canPay The new admin can pay status
  * @return createdOn The new admin created on datetime
  */
  function addAdmin(
    address _wallet,
    string memory _name
  ) verifyContractOwner public returns (
    address wallet,
    string  memory name,
    bool    canPay,
    uint256 createdOn
  ) {
    bool _canPay = true;
    uint256 _createdOn = block.timestamp;

    AdminInfo memory newAdmin = AdminInfo(
      payable(_wallet),
      _name,
      _canPay,
      _createdOn
    );

    admins[_wallet] = newAdmin;

    return (
      newAdmin.wallet,
      newAdmin.name,
      newAdmin.canPay,
      newAdmin.createdOn
    );
  }

  /**
  * @notice Adds an employee with EmployeeInfo struct to the employees map
  * @dev Uses the verifyContractAdmin modifier
  * @param _name The intending to add employee name
  * @param _jobTitle The intending to add employee job title
  * @param _annualSalary The intending to add employee annual salary in cUSD
  * @param _wallet The intending to add employee wallet address
  * @param _adminAddress The admin address utilizing the function
  * @return employeeWallet The new employee wallet address
  * @return createdOn The new employee created on datetime
  * @return createdBy The new employee creator admin wallet address
  */
  function addEmployee(
    string memory _name,
    string memory _jobTitle, 
    uint256 _annualSalary,
    address _wallet,
    address _adminAddress
  ) verifyContractAdmin(_adminAddress) public returns (
    address employeeWallet, 
    uint256 createdOn,
    address createdBy
  ) {
    uint256 _employeeID = employeeCount;
    uint256 _createdOn = block.timestamp;

    EmployeeInfo memory newEmployee = EmployeeInfo(
      payable(_wallet),
      _name,
      _jobTitle,
      _employeeID,
      _annualSalary,
      _createdOn,
      _adminAddress
    );

    employees[_employeeID] = newEmployee;
    employeeCount++;

    return(
      newEmployee.wallet,
      newEmployee.createdOn,
      newEmployee.createdBy
    );
  }

  /**
  * @notice Sends an employee monthly salary
  * @dev Uses the verifyContractAdmin modifier
  * @param _employeeID The intending to pay employee identifier
  * @param _adminAddress The admin address utilizing the function
  * @return paymentID The new payment identifier
  * @return amountPaid The new payment transaction amount
  * @return employeeWallet The new payment employee wallet address
  */
  function makePayment(
    uint256 _employeeID,
    address _adminAddress
  ) verifyContractAdmin(_adminAddress) payable public returns (
    uint256 paymentID,
    uint256 amountPaid,
    address employeeWallet
  ) {
    AdminInfo storage admin = admins[_adminAddress];
    EmployeeInfo storage employee = employees[_employeeID];

    require(admin.canPay, "Error 403: Admin Can't make a payment");
    require(employee.wallet != deadAddress, "Error 404: Employee Does Not Exist");

    PaymentTran memory tran = PaymentTran(
      msg.value,
      paymentCount,
      block.timestamp,
      employee.annualSalary / 12,
      CUSDToken(cUsdTokenAddress).balanceOf(admin.wallet)
    );
    
    require(tran.adminBalance >= tran.amountPaid, "Insufficient Admin Balance");
    require(tran.amountPaid == tran.employeeMonthlySalary, "The amount to pay is not equal to employee monthly salary");

    CUSDToken(cUsdTokenAddress).transferFrom(
      admin.wallet,
      employee.wallet,
      tran.amountPaid
    );

    addPayment(employee.employeeID, tran.amountPaid, tran.paymentID, tran.paidOn, admin.wallet);

    return(
      tran.paymentID,
      tran.amountPaid,
      employee.wallet
    );
  }

  /**
  * @notice Changes the an admin status to pay employees
  * @dev Uses the verifyContractOwner modifier
  * @param _adminAddress The intending to update admin identifier
  * @return status The new admin can pay status
  */
  function changeCanPayStatus(
    address _adminAddress
  ) verifyContractOwner public returns (
    bool status
  ) {
    AdminInfo storage admin = admins[_adminAddress];

    require(admin.wallet != deadAddress, "Error 404: Admin Does Not Exist");

    admin.canPay = ! admin.canPay;

    return(
      admin.canPay
    );
  }

  /**
  * @notice Returns the owner wallet address
  * @dev Uses the verifyContractOwner modifier
  * @return wallet The owner wallet address
  */
  function getOwnerProfile() verifyContractOwner public view returns (
    address wallet
  ) {
    return (
      ownerAddress
    );
  }

  /**
  * @notice Returns an AdminInfo in the admins map
  * @dev Uses the verifyContractAdmin modifier
  * @param _adminAddress The intending to get admin identifier
  * @return wallet The admin wallet address
  * @return name The admin name
  * @return canPay The admin can pay status
  * @return createdOn The admin created on datetime
  */
  function getAdminProfile(
    address _adminAddress
  ) verifyContractAdmin(_adminAddress) public view returns (
    address wallet,
    string  memory name,
    bool    canPay,
    uint256 createdOn
  ) {
    AdminInfo storage admin = admins[_adminAddress];
    require(admin.wallet != deadAddress, "Error 404: Admin Does Not Exist");

    return (
      admin.wallet,
      admin.name,
      admin.canPay,
      admin.createdOn
    );
  }

  /**
  * @notice Returns an EmployeeInfo in the employees map
  * @dev Uses the verifyContractAdmin modifier
  * @param _employeeID The intending to get employee identifier
  * @param _adminAddress The admin address utilizing the function
  * @return wallet The employee wallet address
  * @return name The employee name
  * @return jobTitle The employee job title
  * @return employeeID The employee identifier
  * @return annualSalary The employee annual salary
  * @return createdOn The employee created on datetime
  * @return createdBy The employee creator admin wallet address
  */
  function getEmployee(
    uint256 _employeeID,
    address _adminAddress
  ) verifyContractAdmin(_adminAddress) public view returns (
    address wallet,
    string memory name, 
    string memory jobTitle,
    uint256 employeeID,
    uint256 annualSalary, 
    uint256 createdOn,
    address createdBy
  ) {
    EmployeeInfo storage employee = employees[_employeeID];
    require(employee.wallet != deadAddress, "Error 404: Employee Does Not Exist");

    return(
      employee.wallet,
      employee.name,
      employee.jobTitle,
      employee.employeeID,
      employee.annualSalary,
      employee.createdOn,
      employee.createdBy
    );
  }

  /**
  * @notice Returns a PaymentInfo in the payments map
  * @dev Uses the verifyContractOwner modifier
  * @param _paymentID The intending to get payment identifier
  * @return employeeID The payment employee identifier
  * @return amountPaid The payment transaction amount
  * @return paymentID The payment identifier
  * @return paidOn The payment paid on datetime
  * @return paidBy The payment payer admin wallet address
  */
  function getPayment(
    uint256 _paymentID
  ) verifyContractOwner public view returns (
    uint256 employeeID,
    uint256 amountPaid,
    uint256 paymentID,
    uint256 paidOn,
    address paidBy
  ) {
    PaymentInfo storage payment = payments[_paymentID];
    require(payment.paidBy != deadAddress, "Error 404: Payment Does Not Exist");

    return(
      payment.employeeID,
      payment.amountPaid,
      payment.paymentID,
      payment.paidOn,
      payment.paidBy
    );
  }

  /**
  * @notice Adds an payment with PaymentInfo struct to the payments map
  * @dev Controlled by circuit breaker
  * @param _employeeID The paid employee identifier
  * @param _amountPaid The amount paid to the employee
  * @param _paymentID The payment identifier
  * @param _paidOn The payment transaction datatime
  * @param _paidBy The payer admin wallet address
  */
  function addPayment(
    uint256 _employeeID,
    uint256 _amountPaid,
    uint256 _paymentID,
    uint256 _paidOn,
    address _paidBy
  ) internal {
    PaymentInfo memory newPayment = PaymentInfo(
      _employeeID,
      _amountPaid,
      _paymentID,
      _paidOn,
      _paidBy
    );

    payments[_paymentID] = newPayment;
    paymentCount++;
  }
}