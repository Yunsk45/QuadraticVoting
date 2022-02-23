// SPDX-License-Identifier: MIT
pragma solidity >=0.4.0 <0.9.0;

contract QuadraticVoting {
   struct Item {
      address payable owner;
      uint amount;
      byte32 title;
      string imageHash; //IPFS
      string description;
      mapping(address => uint) positiveVotes;
      mapping(address => uint) negativeVotes;
      uint totalPositiveWeight;
      uint totalNegativeWeight;
   }

}
