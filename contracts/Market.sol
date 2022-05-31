//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Market is ReentrancyGuard {
    address payable private immutable owner;
    uint256 public immutable feePercent;
    uint256 private itemCount;

    struct NFT {
        uint256 itemId;
        IERC721 token;
        uint256 tokenId;
        uint256 price;
        address payable seller;
        bool sold;
    }

    mapping(uint256 => NFT) public listing;

    event Offered(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller
    );
    event Bought(
        uint256 itemId,
        address indexed nft,
        uint256 tokenId,
        uint256 price,
        address indexed seller,
        address indexed buyer
    );

    constructor(uint256 _feePercent) {
        owner = payable(msg.sender);
        feePercent = _feePercent;
    }

    function listNFT(
        IERC721 _nft,
        uint256 _tokenId,
        uint256 _price
    ) external nonReentrant {
        require(_price > 0, "Price must be greater than zero");

        itemCount++;

        _nft.transferFrom(msg.sender, address(this), _tokenId);

        listing[itemCount] = NFT(
            itemCount,
            _nft,
            _tokenId,
            _price,
            payable(msg.sender),
            false
        );

        emit Offered(itemCount, address(_nft), _tokenId, _price, msg.sender);
    }

    function buyNFT(uint256 _itemId) external payable nonReentrant {
        uint256 _totalPrice = getPrice(_itemId);
        NFT storage nft = listing[_itemId];
        require(_itemId > 0 && _itemId <= itemCount, "NFT doesn't exist");

        require(
            msg.value >= _totalPrice,
            "not enough ether to cover item price and market fee"
        );

        require(!nft.sold, "nft already sold");

        nft.seller.transfer(nft.price);
        owner.transfer(_totalPrice - nft.price);
        nft.sold = true;

        nft.token.transferFrom(address(this), msg.sender, nft.tokenId);

        emit Bought(
            _itemId,
            address(nft.token),
            nft.tokenId,
            nft.price,
            nft.seller,
            msg.sender
        );
    }

    function getPrice(uint256 _itemId) public view returns (uint256) {
        return ((listing[_itemId].price * (100 + feePercent)) / 100);
    }
}
