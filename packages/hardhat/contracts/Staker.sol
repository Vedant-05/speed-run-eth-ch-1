// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;  //Do not change the solidity version as it negativly impacts submission grading


import "./ExampleExternalContract.sol";


contract Staker {

  ExampleExternalContract public exampleExternalContract;

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  mapping ( address => uint256 ) public balances;

  uint256 public constant threshold = 1 ether;

  uint256 public  deadline = block.timestamp + 72 hours;

  bool openForWithdraw = false;

  bool callOnlyOnce = false;


  event Stake(address,uint256);

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // (Make sure to add a `Stake(address,uint256)` event and emit it for the frontend `All Stakings` tab to display)

  function timeLeft() public view returns (uint256) {
  
    if(block.timestamp >= deadline) {
        return 0;
    }
    if(block.timestamp < deadline) {
        return (deadline - block.timestamp);  // Fixed: deadline minus current time
    }
}

  function  stake() public payable {
    address from = msg.sender;
    balances[from] += msg.value;

    emit Stake(msg.sender, msg.value);
  }


  function execute() public {
     require(block.timestamp >= deadline, "Still Time is Remaining");
     require(!callOnlyOnce, "Already Been Called Once");

     callOnlyOnce = true;

     if(address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
      return;
     }

     openForWithdraw = true;

  }

  function withdraw() public {
    require(openForWithdraw,"Funds Transfered to external contract");
    require(balances[msg.sender] > 0,"No Amount Remaining");
    uint toTransfer = balances[msg.sender];
    balances[msg.sender] = 0;
    payable(msg.sender).transfer(toTransfer);
  }

  receive() external payable {
    stake();
    // balances[msg.sender] += msg.value;
  }

     


  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`


  // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend


  // Add the `receive()` special function that receives eth and calls stake()

}
