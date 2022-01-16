// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

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

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}


contract DmusikMarketplace {

    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    using SafeMath for uint;

    uint internal argumentsLength = 0;
    // support price 1 cusd
    uint supportPrice = 2e18;
    uint likePrice = 1e18;
    address _contractOwner;

    struct Dmusik {
        address payable owner;
        mapping (address => uint) likes;
        uint likesCount;
        uint likesSum;
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


    function likeSong(uint _index, uint _like) public payable {        
        require(
          IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            _contractOwner,
            likePrice
          ),
          "Transfer failed."
        );

        uint prevLike = dmusik[_index].likes[msg.sender];
        if(prevLike == 0) {
            dmusik[_index].likesCount++;
        }
        dmusik[_index].likesSum += _like;
        dmusik[_index].likes[msg.sender] = _like;
    }
    
    function getLikesCount(uint _index) public view returns (uint) {
        return dmusik[_index].likesCount;
    }

   function dmusikSupport() public payable {
        payable(msg.sender);
            require(IERC20Token(cUsdTokenAddress).transferFrom(msg.sender, _contractOwner,supportPrice),
          "Transfer failed."
        );
	}
}