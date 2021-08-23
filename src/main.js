import './assets/style.css'
import BigNumber from 'bignumber.js'
import { newKitFromWeb3 } from '@celo/contractkit'
import Web3 from '@celo/contractkit/node_modules/web3'
import tokenAbi from '../contract/cUSDToken.abi.json'
import calculatorAbi from '../contract/salaryCalculator.abi.json'

const TOKEN_DECIMALS = 18;
const tokenAddress = "0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1";
const calculatorAddress = "0x8fE40f53cd8873329e4772a03f8BdAC7bD56d603";

let kit, contract;
let monthlyTotal = new BigNumber(0);

toastr.options = {
  "newestOnTop": true,
  "progressBar": true,
  "preventDuplicates": true,
  "showDuration": "300",
  "hideDuration": "1000",
  "timeOut": "5000",
  "extendedTimeOut": "1000",
  "showEasing": "swing",
  "hideEasing": "linear",
  "showMethod": "fadeIn",
  "hideMethod": "fadeOut"
}

$(document).ready(init);

async function init() {
  toastr.info('Loading...');
  await connectCeloWallet()
  console.log('we ready to rock and roll');
  await render();
  $('#employeeInfoForm').on('submit', submitEmployeeInfoForm);
  $('.js-employeeInfoDisplay').on('click', '.js-button-pay', payEmployee);
}

const connectCeloWallet = async function () {
  if (window.celo) {
    toastr.warning('Please approve this dApp to use it');
    try {
      await window.celo.enable()

      const web3 = new Web3(window.celo)
      kit = newKitFromWeb3(web3)

      const accounts = await kit.web3.eth.getAccounts()
      kit.defaultAccount = accounts[0]

      contract = new kit.web3.eth.Contract(calculatorAbi, calculatorAddress)
    } catch (error) {
      toastr.warning(`${error}.`);
    }
  } else {
    toastr.info('Please install the CeloExtensionWallet.');
  }
}

const approve = async function (amount) {
  const value = amount.toString();

  const TokenContract = new kit.web3.eth.Contract(tokenAbi, tokenAddress)

  const result = await TokenContract.methods.approve(calculatorAddress, value).send({
    from: kit.defaultAccount
  })

  return result
}

async function submitEmployeeInfoForm(e) {
  e.preventDefault();
  
  const employeeInfoParams = [
    $('#name').val(),
    $('#jobTitle').val(),
    new BigNumber($('#annualSalary').val()).shiftedBy(TOKEN_DECIMALS).toString(),
    $('#wallet').val()
  ]

  await contract.methods.addEmployee(...employeeInfoParams).send({
    from: kit.defaultAccount
  })

  render();
  resetInputs();

  toastr.success(`You successfully added "${employeeInfoParams[0]}" as an employee`);
}

function bleedingCash() {
  if(monthlyTotal >= new BigNumber(20000).shiftedBy(TOKEN_DECIMALS).toString()) {
    $('.js-monthly-total-display').css("color", "red",);
    console.log ('we are bleeding cash boss');
  }else {
    $('.js-monthly-total-display').css("color", "black",);
    console.log ('you can def afford that new Vette bossman!');
  }
}

const render = async function () {
  monthlyTotal = 0;
  $('.js-employeeInfoDisplay').empty();

  const employeeLength = await contract.methods.employeeCount().call()
  for (let i = 0; i < employeeLength; i++) {
    const employee = await contract.methods.getEmployee(i).call()

    let employeeMonthly = employee.annualSalary / 12;
    monthlyTotal = BigInt(monthlyTotal) + BigInt(employeeMonthly);

    $('.js-employeeInfoDisplay').append(`
      <tr>
        <td>${employee.employeeID}</td>
        <td>${employee.name}</td>
        <td>${employee.jobTitle}</td>
        <td>${new BigNumber(employee.annualSalary).shiftedBy(-TOKEN_DECIMALS).toFixed(2)} cUSD</td>
        <td>${new BigNumber(employeeMonthly).shiftedBy(-TOKEN_DECIMALS).toFixed(2)} cUSD</td>
        <td data-id="${i}" data-name="${employee.name}" data-monthly="${employeeMonthly}">
          <button type="button" class="js-button-pay">pay</button>
        </td>
      </tr>
    `);
  }

  bleedingCash();
  $('#monthly-total').text(`Monthly Salary Total : ${new BigNumber(monthlyTotal).shiftedBy(-TOKEN_DECIMALS).toFixed(2)} cUSD`);
}

async function payEmployee() {
  const id = $(this).parent().data('id');
  const name = $(this).parent().data('name');
  const value = $(this).parent().data('monthly');

  console.log(id,value);

  await approve(value);
  await contract.methods.makePayment(id).send({
    from: kit.defaultAccount,
    value: value
  })

  toastr.success(`You successfully paid "${name}".`);
}

function resetInputs(){
  $('#name').val(``);
  $('#jobTitle').val(``);
  $('#annualSalary').val(``);
  $('#wallet').val(``);
}