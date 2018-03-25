pragma solidity ^0.4.2;

contract ERC721 {
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner);
    function transfer(address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
}

contract FishBase {

    event Transfer(address from, address to, uint256 tokenId);

    struct Fish {
        uint64 birthTime;
        uint256 genes;
        uint256 price;
    }

    Fish[] fishes;

    mapping (uint256 => address) public fishIndexToOwner;
    mapping (address => uint256) ownershipTokenCount;

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
        }
        ownershipTokenCount[_to]++;
        fishIndexToOwner[_tokenId] = _to;

        Transfer(_from, _to, _tokenId);
    }

    function _createFish(uint256 _genes, uint256 _price, address _owner) internal returns (uint) {
        require(_owner != address(0));

        Fish memory _fish = Fish({
            genes: _genes,
            birthTime: uint16(now),
            price: _price
        });

        uint256 newFishId = fishes.push(_fish) - 1;
        _transfer(0, _owner, newFishId);

        return newFishId;
    }
}

contract FishCore is FishBase, ERC721 {
    string public constant name = "GoldFish";
    string public constant symbol = "GF";

    function FishCore() public {
        _createFish(123, 15, msg.sender);
        _createFish(345, 26, msg.sender);
        _createFish(567, 37, msg.sender);
        _createFish(789, 48, msg.sender);
    }

    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return fishIndexToOwner[_tokenId] == _claimant;
    }

    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    function transfer(address _to, uint256 _tokenId) external {
        require(_to != address(0));
        require(_to != address(this));
        require(_owns(msg.sender, _tokenId));
        _transfer(msg.sender, _to, _tokenId);
    }

     function totalSupply() public view returns (uint) {
        return fishes.length;
     }

    function ownerOf(uint256 _tokenId) external view returns (address owner) {
        owner = fishIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalFishes = totalSupply();
            uint256 resultIndex = 0;

            uint256 fishId;

            for (fishId = 1; fishId <= totalFishes-1; fishId++) {
                if (fishIndexToOwner[fishId] == _owner) {
                    result[resultIndex] = fishId;
                    resultIndex++;
                }
            }
            return result;
        }
    }

    function getFish(uint256 _id) public view returns (uint256 birthTime, uint256 genes, uint256 price) {
        Fish storage fish = fishes[_id];
        price = fish.price;
        genes = fish.genes;
        birthTime = fish.birthTime;
    }

    function getFishesPrice() public view returns (uint256[]) {
       uint256 totalFishes = totalSupply();
       uint256[] memory result = new uint256[](totalFishes);
       uint256 i;
       for (i=0; i < totalFishes; i++) {
           result[i] = fishes[i].price;
       } 

       return result;
    }

    function buyFish(uint256 _fishId) external payable returns (bool) {
        Fish storage fish = fishes[_fishId];
        require(msg.value == fish.price);
        address owner = fishIndexToOwner[_fishId];
        msg.sender.transfer(fish.price);
        _transfer(owner, msg.sender, _fishId);
    }
}