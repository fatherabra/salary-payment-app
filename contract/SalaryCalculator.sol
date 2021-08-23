// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 < 0.9.0;

interface CUSDToken {
  function approve(address, uint256) external returns (bool);
  function balanceOf(address) external view returns (uint256);
  function transferFrom(address, address, uint256) external returns (bool);
}

contract SalaryCalculator {
  struct EmployeeInfo {
    address payable wallet;
    string  name;
    string  jobTitle;
    uint256 employeeID;
    uint256 annualSalary;
  }

  uint256 public employeeCount = 0;
  address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;

  mapping (uint256 => EmployeeInfo) internal employees;

  function addEmployee(
    string memory _name,
    string memory _jobTitle, 
    uint256 _annualSalary,
    address _wallet
  ) public {
    EmployeeInfo memory newEmployee = EmployeeInfo(
      payable(_wallet),
      _name,
      _jobTitle,
      employeeCount,
      _annualSalary
    );

    employees[employeeCount] = newEmployee;
    employeeCount++;
  }

  function makePayment(
    uint256 _employeeID
  ) payable public {
    CUSDToken(cUsdTokenAddress).transferFrom(
      msg.sender,
      employees[_employeeID].wallet,
      msg.value
    );
  }

  function getEmployee(uint256 _employeeID) public view returns (
    address payable wallet,
    string memory name, 
    string memory jobTitle,
    uint256 employeeID,
    uint256 annualSalary
  ) {
    EmployeeInfo storage employee = employees[_employeeID];

    return(
      employee.wallet,
      employee.name,
      employee.jobTitle,
      employee.employeeID,
      employee.annualSalary
    );
  }
}