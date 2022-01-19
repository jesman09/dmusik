// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract DmusikMarketplace {

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    using SafeMath for uint;

    uint internal argumentsLength = 0;
    // support price 2 cusd
    uint supportPrice = 2e18;
    uint likePrice = 1e18;
    address _contractOwner;

    struct Dmusik {
        address payable owner;
        mapping (address => bool) likes;
        uint likesCount;
        uint support;
    }

    mapping (uint => Dmusik) internal dmusik;

    constructor() {
        _contractOwner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == _contractOwner);
        _;
    }


    function likeSong(uint _index) public payable { 
        bool prevLike = dmusik[_index].likes[msg.sender];
        require(prevLike == false, "You already liked this song.");
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            _contractOwner,
            likePrice
          ),
          "Transfer failed."
        );

        dmusik[_index].likesCount = dmusik[_index].likesCount.add(1);
        dmusik[_index].likes[msg.sender] = true;
    }
    
    function getLikesCount(uint _index) public view returns (uint) {
        return dmusik[_index].likesCount;
    }

   function dmusikSupport() public payable {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(msg.sender, 
                _contractOwner,
                supportPrice
            ),
          "Transfer failed."
        );
	}
}