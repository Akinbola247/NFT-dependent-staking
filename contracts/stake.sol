// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";


contract stake {
    IERC20 rewardToken;
    IERC721 nftContract;
    IERC20 USDCContract;

struct stakerDetail{
        uint amount;
        uint initialStaketime;
        bool stakeStatus;
    }
bool isApproved;
mapping(address => stakerDetail) staker;
mapping(address => uint) trackReward;
event rewardCheck (uint balance);
    constructor(IERC20 _rewardToken){
        rewardToken = IERC20(_rewardToken);
        nftContract = IERC721(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);
        USDCContract = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }
uint256 constant SECONDS_PER_YEAR = 31536000;
function nftBalance() internal view returns(uint){
   uint balance = nftContract.balanceOf(msg.sender);
    return balance;
}

function stakingPool(uint _amount) public {
    uint stakerBalance = nftBalance();
uint USDCOwnerBalance = USDCContract.balanceOf(msg.sender);
    require(stakerBalance >= 1, "You need to be a boardApe NFT holder");
    require(USDCOwnerBalance >= 30, "Minimum of 30 usdc can be staked" );
USDCContract.transferFrom(msg.sender, address(this), _amount);
stakerDetail storage details = staker[msg.sender];
details.amount += _amount;
details.initialStaketime = block.timestamp;
details.stakeStatus = true;

}

function calculateReward() internal {
    stakerDetail storage stakers = staker[msg.sender];
    uint _Amount = stakers.amount;
    uint rewardTime = block.timestamp - stakers.initialStaketime;  
    uint reward = (rewardTime * 20 * (_Amount)) / (SECONDS_PER_YEAR * 100);      
    trackReward[msg.sender] += reward;
    if(rewardTime >= SECONDS_PER_YEAR ){
        uint RewardingTime = rewardTime/SECONDS_PER_YEAR;
        uint result = RewardingTime - (rewardTime % SECONDS_PER_YEAR);
        uint totalResult = result * SECONDS_PER_YEAR;
        uint remainingTime = rewardTime - totalResult;
        uint rewardss = (totalResult * 20 * (_Amount)) / (SECONDS_PER_YEAR * 100); 
         uint initialReward = trackReward[msg.sender] += rewardss;
        uint Compoundreward = (rewardTime * 20 * (_Amount + initialReward)) / (SECONDS_PER_YEAR * 100);  
        uint remSec = (remainingTime * 20 * (_Amount)) / (SECONDS_PER_YEAR * 100); 
        trackReward[msg.sender] += Compoundreward + remSec;
        stakers.initialStaketime = block.timestamp;
    } 
    
    trackReward[msg.sender] += reward;  
    stakers.initialStaketime = block.timestamp;
    }

function checkreward() public returns(uint){
        calculateReward();
    uint reward = trackReward[msg.sender];
      emit rewardCheck(reward);
      return reward;   
    }
function claimReward(uint _amount) public {
    calculateReward();

 uint claimAbleAmount = trackReward[msg.sender];
        require(trackReward[msg.sender] != 0, "You have no reward");
        require(_amount <= claimAbleAmount, "Can't withdraw more than your reward");
        require(_amount < rewardToken.balanceOf(address(this)), "check back to claim reward");
        if (_amount == claimAbleAmount){
            rewardToken.transfer(msg.sender, claimAbleAmount);
             trackReward[msg.sender] = 0;
        }else {
            rewardToken.transfer(msg.sender, _amount);
           uint rewardLeft = claimAbleAmount - _amount;
            trackReward[msg.sender] = rewardLeft;
        }
}


}