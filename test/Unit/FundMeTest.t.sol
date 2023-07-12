// SPDX-License-Identifier:MIT
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    uint256 constant TEST_AMOUNT_FUNDS = 10e18;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;
    address USER = makeAddr("Foundry");

    function setUp() external {
        vm.deal(USER, STARTING_BALANCE);
        DeployFundMe deployFundme = new DeployFundMe();
        fundMe = deployFundme.run();
    }

    function testMinimumUSDIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwner() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionAccurate() public {
        assertEq(fundMe.getVersion(), 4);
    }

    function testNotEnoughEthFunds() public {
        vm.expectRevert();
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: TEST_AMOUNT_FUNDS}();
        _;
    }

    function testEnoughEthFundsUpdatedInDS() public funded {
        uint256 amount = fundMe.getaddressToAmountFunded(USER);
        assertEq(amount, TEST_AMOUNT_FUNDS);
    }

    function testFundedAddress() public funded {
        address userAddress = fundMe.getFunders(0);
        assertEq(userAddress, USER);
    }

    function testWithdrawUserNotTheOwner() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawForASingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundingBalance = address(fundMe).balance;

        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundingBalance = address(fundMe).balance;

        assertEq(endingFundingBalance, 0);
        assertEq(
            startingFundingBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawForMultipleFunders() public funded {
        //Arrange
        uint160 numberOfFunders = 10;
        uint160 startingIndex = 1;

        for (uint160 i = startingIndex; i < numberOfFunders; i++) {
            hoax(address(i), TEST_AMOUNT_FUNDS);
            fundMe.fund{value: TEST_AMOUNT_FUNDS}();
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundingBalance = address(fundMe).balance;

        //Act
        uint256 GAS_AT_START = gasleft();
        vm.txGasPrice(GAS_PRICE);
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();
        uint256 GAS_AT_END = gasleft();
        uint256 gasUsed = (GAS_AT_START - GAS_AT_END) * tx.gasprice;
        console.log(gasUsed);
        //Assert
        assert(address(fundMe).balance == 0);
        assert(
            startingFundingBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );
    }
}
