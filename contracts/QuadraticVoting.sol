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

   uint constant public voteCost = 10_000_000_000;
   mapping(uint => Item) public items;
   uint public itemCount = 0;

   event ItemCrated(uint itemId);
   event Voted(uint itemId, uint weight, bool positive);

   function currenctWeight(uint itemId, address addr, bool isPositive) public view returns(uint) {
      if(isPositive) {
         return items[itemId].positiveVotes[addr];
      }
      else {
         return items[itemId].negativeVotes[addr];
      }
   }

   function calcCost(uint currWeight, uint weight) public pure returns(uint) {
      if(currWeight > weight) {
         return weight * weight * voteCost;
      } else if (currWeight < weight) {
         return (weight*weight - currWeight*currWeight) * voteCost;
      }
      else {
         return 0;
      }
   }

   function createItem(bytes32 title, string memory imageHash, string memory description) public {
      uint itemId = itemCount;
      itemCount++; //Clearer separation of incrementation
      Item storage item = items[itemId];
      item.owner = msg.sender;
      item.title = title;
      item.imageHash = imageHash;
      item.description = description;
      emit ItemCrated(itemId);
   }
/*
   modifier onlyItemOwner(Item storage item) {
      require(msg.sender == item.owner);
      _;
   }
   modifier notItemOwner(Item storage item) {
      require(msg.sender != item.owner);
      _;
   }
  */
   function positiveVote(uint itemId, uint weight) public payable {
      Item storage item = items[itemId];
      require(msg.sender != item.owner, "Owner cannot vote.");

      uint currWeight = item.positiveVotes[msg.sender];
      if (currWeight == weight) {
         return;
      }

      uint cost = calcCost(currWeight, weight);
      require(msg.value >= cost, "Must pay enough to vote");

      item.positiveVotes[msg.sender] = weight;
      item.totalPositiveWeight += weight - currWeight;

      item.totalNegativeWeight -= item.negativeVotes[msg.sender];
      item.negativeVotes[msg.sender] = 0;

      item.amount += msg.value;
   
      emit Voted(itemId, weight, true);
   }

   function negativeVote(uint itemId, uint weight) public payable {
      Item storage item = items[itemId];
      require(msg.sender != item.owner);

      uint currWeight = item.negativeVotes[msg.sender];

      uint cost = calcCost(currWeight, weight);
      require(msg.value >= cost, "Must pay enough to vote");

      item.negativeVotes[msg.sender] = weight;
      item.totalNegativeWeight += weight - currWeight;

      item.totalPositiveWeight -= item.positiveVotes[msg.sender];
      item.positiveVotes[msg.sender] = 0;

      uint reward = msg.value / (itemCount - 1);
      for (uint i = 0; i < itemCount; i++) {
         if(i != itemId) items[i].amount += reward;
      }

      emit Voted(itemId, weight, false);
   }
}

