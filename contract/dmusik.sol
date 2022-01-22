// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
    function transfer(address, uint256) external returns (bool);

    function approve(address, uint256) external returns (bool);

    function transferFrom(
        address,
        address,
        uint256
    ) external returns (bool);

    function totalSupply() external view returns (uint256);

    function balanceOf(address) external view returns (uint256);

    function allowance(address, address) external view returns (uint256);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }
}

contract DmusikMarketplace {
    address internal cUsdTokenAddress =
        0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    using SafeMath for uint256;

    uint256 internal argumentsLength = 0;
    // support price 2 cusd
    uint256 supportPrice = 2e18;
    uint256 likePrice = 1e18;
    address _contractOwner;

    struct Dmusik {
        address payable owner;
        mapping(address => bool) likes;
        uint256 likesCount;
        uint256 support;
    }

    mapping(uint256 => Dmusik) internal dmusik;

    function likeSong(uint256 _index) public payable {
        bool prevLike = dmusik[_index].likes[msg.sender];
        require(prevLike == false, "You already liked this song.");
        
        dmusik[_index].likesCount = dmusik[_index].likesCount.add(1);
        dmusik[_index].likes[msg.sender] = true;
    }

    function getLikesCount(uint256 _index) public view returns (uint256) {
        return dmusik[_index].likesCount;
    }

    function dmusikSupport() public payable {
        require(
            IERC20Token(cUsdTokenAddress).transferFrom(
                msg.sender,
                _contractOwner,
                supportPrice
            ),
            "Transfer failed."
        );
    }
}
