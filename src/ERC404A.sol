//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

/**
 * @dev A sequence of items with the ability to efficiently push and pop items (i.e. insert and remove) on both ends of
 * the sequence (called front and back). Among other access patterns, it can be used to implement efficient LIFO and
 * FIFO queues. Storage use is optimized, and all operations are O(1) constant time. This includes {clear}, given that
 * the existing queue contents are left in storage.
 *
 * The struct is called `Bytes32Deque`. Other types can be cast to and from `bytes32`. This data structure can only be
 * used in storage, and not in memory.
 * ```solidity
 * DoubleEndedQueue.Bytes32Deque queue;
 * ```
 */
library DoubleEndedQueue {
    /**
     * @dev An operation (e.g. {front}) couldn't be completed due to the queue being empty.
     */
    error QueueEmpty();

    /**
     * @dev A push operation couldn't be completed due to the queue being full.
     */
    error QueueFull();

    /**
     * @dev An operation (e.g. {at}) couldn't be completed due to an index being out of bounds.
     */
    error QueueOutOfBounds();

    /**
     * @dev Indices are 128 bits so begin and end are packed in a single storage slot for efficient access.
     *
     * Struct members have an underscore prefix indicating that they are "private" and should not be read or written to
     * directly. Use the functions provided below instead. Modifying the struct manually may violate assumptions and
     * lead to unexpected behavior.
     *
     * The first item is at data[begin] and the last item is at data[end - 1]. This range can wrap around.
     */
    struct Uint256Deque {
        uint128 _begin;
        uint128 _end;
        mapping(uint128 index => uint256) _data;
    }

    /**
     * @dev Inserts an item at the end of the queue.
     *
     * Reverts with {QueueFull} if the queue is full.
     */
    function pushBack(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex + 1 == deque._begin) revert QueueFull();
            deque._data[backIndex] = value;
            deque._end = backIndex + 1;
        }
    }

    /**
     * @dev Removes the item at the end of the queue and returns it.
     *
     * Reverts with {QueueEmpty} if the queue is empty.
     */
    function popBack(
        Uint256Deque storage deque
    ) internal returns (uint256 value) {
        unchecked {
            uint128 backIndex = deque._end;
            if (backIndex == deque._begin) revert QueueEmpty();
            --backIndex;
            value = deque._data[backIndex];
            delete deque._data[backIndex];
            deque._end = backIndex;
        }
    }

    /**
     * @dev Inserts an item at the beginning of the queue.
     *
     * Reverts with {QueueFull} if the queue is full.
     */
    function pushFront(Uint256Deque storage deque, uint256 value) internal {
        unchecked {
            uint128 frontIndex = deque._begin - 1;
            if (frontIndex == deque._end) revert QueueFull();
            deque._data[frontIndex] = value;
            deque._begin = frontIndex;
        }
    }

    /**
     * @dev Removes the item at the beginning of the queue and returns it.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function popFront(
        Uint256Deque storage deque
    ) internal returns (uint256 value) {
        unchecked {
            uint128 frontIndex = deque._begin;
            if (frontIndex == deque._end) revert QueueEmpty();
            value = deque._data[frontIndex];
            delete deque._data[frontIndex];
            deque._begin = frontIndex + 1;
        }
    }

    /**
     * @dev Returns the item at the beginning of the queue.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function front(
        Uint256Deque storage deque
    ) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        return deque._data[deque._begin];
    }

    /**
     * @dev Returns the item at the end of the queue.
     *
     * Reverts with `QueueEmpty` if the queue is empty.
     */
    function back(
        Uint256Deque storage deque
    ) internal view returns (uint256 value) {
        if (empty(deque)) revert QueueEmpty();
        unchecked {
            return deque._data[deque._end - 1];
        }
    }

    /**
     * @dev Return the item at a position in the queue given by `index`, with the first item at 0 and last item at
     * `length(deque) - 1`.
     *
     * Reverts with `QueueOutOfBounds` if the index is out of bounds.
     */
    function at(
        Uint256Deque storage deque,
        uint256 index
    ) internal view returns (uint256 value) {
        if (index >= length(deque)) revert QueueOutOfBounds();
        // By construction, length is a uint128, so the check above ensures that index can be safely downcast to uint128
        unchecked {
            return deque._data[deque._begin + uint128(index)];
        }
    }

    /**
     * @dev Resets the queue back to being empty.
     *
     * NOTE: The current items are left behind in storage. This does not affect the functioning of the queue, but misses
     * out on potential gas refunds.
     */
    function clear(Uint256Deque storage deque) internal {
        deque._begin = 0;
        deque._end = 0;
    }

    /**
     * @dev Returns the number of items in the queue.
     */
    function length(
        Uint256Deque storage deque
    ) internal view returns (uint256) {
        unchecked {
            return uint256(deque._end - deque._begin);
        }
    }

    /**
     * @dev Returns true if the queue is empty.
     */
    function empty(Uint256Deque storage deque) internal view returns (bool) {
        return deque._end == deque._begin;
    }
}

abstract contract Ownable {
    event OwnershipTransferred(address indexed user, address indexed newOwner);

    error Unauthorized();
    error InvalidOwner();

    address public owner;

    modifier onlyOwner() virtual {
        if (msg.sender != owner) revert Unauthorized();

        _;
    }

    constructor(address _owner) {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(address(0), _owner);
    }

    function transferOwnership(address _owner) public virtual onlyOwner {
        if (_owner == address(0)) revert InvalidOwner();

        owner = _owner;

        emit OwnershipTransferred(msg.sender, _owner);
    }

    function revokeOwnership() public virtual onlyOwner {
        owner = address(0);

        emit OwnershipTransferred(msg.sender, address(0));
    }
}

abstract contract ERC721Receiver {
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual returns (bytes4) {
        return ERC721Receiver.onERC721Received.selector;
    }
}

/// @notice ERC404
///         A gas-efficient, mixed ERC20 / ERC721 implementation
///         with native liquidity and fractionalization.
///
///         This is an experimental standard designed to integrate
///         with pre-existing ERC20 / ERC721 support as smoothly as
///         possible.
///
/// @dev    In order to support full functionality of ERC20 and ERC721
///         supply assumptions are made that slightly constraint usage.
///         Ensure decimals are sufficiently large (standard 18 recommended)
///         as ids are effectively encoded in the lowest range of amounts.
///
///         NFTs are spent on ERC20 functions in a FILO queue, this is by
///         design.
///
abstract contract ERC404A is Ownable {
    using DoubleEndedQueue for DoubleEndedQueue.Uint256Deque;

    /// @dev The queue of ERC-721 tokens stored in the contract.
    DoubleEndedQueue.Uint256Deque private _storedERC721Ids;

    // Events
    event ERC20Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );
    event ERC721Approval(
        address indexed owner,
        address indexed spender,
        uint256 indexed id
    );
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );
    event ERC721Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed id
    );

    // Errors
    error NotFound();
    error AlreadyExists();
    error InvalidRecipient();
    error InvalidSender();
    error UnsafeRecipient();
    error InvalidParameter();
    error OwnedIndexOverflow();
    error NotAllowed();

    // Metadata
    /// @dev Token name
    string public name;

    /// @dev Token symbol
    string public symbol;

    /// @dev Decimals for fractional representation
    uint8 public immutable decimals;

    /// @dev Total supply in fractionalized representation
    uint256 public immutable totalSupply;

    /// @dev Total supply
    uint256 public immutable totalNativeSupply;

    /// @dev Current mint counter, monotonically increasing to ensure accurate ownership
    uint256 public minted;

    // Mappings
    /// @dev Balance of user in fractional representation
    mapping(address => uint256) public balanceOf;

    /// @dev Allowance of user in fractional representation
    mapping(address => mapping(address => uint256)) public allowance;

    /// @dev Approval in native representaion
    mapping(uint256 => address) public getApproved;

    /// @dev Approval for all in native representation
    mapping(address => mapping(address => bool)) public isApprovedForAll;

    /// @dev Packed representation of ownerOf and owned indices
    mapping(uint256 => uint256) internal _ownedData;

    /// @dev Array of owned ids in native representation
    mapping(address => uint256[]) internal _owned;

    /// @dev Address bitmask for packed ownership data
    uint256 private constant _BITMASK_ADDRESS = (1 << 160) - 1;

    /// @dev Owned index bitmask for packed ownership data
    uint256 private constant _BITMASK_OWNED_INDEX = ((1 << 96) - 1) << 160;

    /// @dev Addresses whitelisted from minting / burning for gas savings (pairs, routers, etc)
    mapping(address => bool) public whitelist;

    bool private nftMintBurnPaused;

    // Constructor
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        uint256 _totalNativeSupply,
        address _owner
    ) Ownable(_owner) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalNativeSupply * (10 ** decimals);
        totalNativeSupply = _totalNativeSupply;
    }

    /// @notice Initialization function to set pairs / etc
    ///         saving gas by avoiding mint / burn on unnecessary targets
    function setWhitelist(address target, bool state) public onlyOwner {
        whitelist[target] = state;
    }

    function setNftMintBurnPaused(bool state) public onlyOwner {
        nftMintBurnPaused = state;
    }

    /// @notice Function to find owner of a given native token
    function ownerOf(uint256 id) public view virtual returns (address owner) {
        owner = _getOwnerOf(id);

        if (owner == address(0)) {
            revert NotFound();
        }
    }

    // function erc721BalanceOf(
    //     address owner
    // ) public view virtual returns (uint256) {
    //     return balanceOf[owner] / _getUnit();
    // }

    function _getLastTokenId(
        address from
    ) internal view returns (uint256 id, uint256 index, uint256 lastSubIndex) {
        // find last item position
        if (_owned[from].length == 0) return (0, 0, 0);

        index = _owned[from].length - 1;
        uint256 idTemp = _owned[from][index];
        lastSubIndex = 15;

        for (uint256 i = 1; i < 16; i++) {
            if ((idTemp >> (i * 16)) == 0) {
                lastSubIndex = i - 1;
                break;
            }
        }

        id = idTemp >> (lastSubIndex * 16);

        return (id, index, lastSubIndex);
    }

    // Backtest
    function erc721BalanceOf(
        address owner
    ) public view virtual returns (uint256) {
        if (_owned[owner].length == 0) return 0;

        (
            uint256 tokenId,
            uint256 index,
            uint256 lastSubIndex
        ) = _getLastTokenId(owner);

        return index * 16 + lastSubIndex + 1;
    }

    /// @notice tokenURI must be implemented by child contract
    function tokenURI(uint256 id) public view virtual returns (string memory);

    /// @notice Function for token approvals
    /// @dev This function assumes id / native if amount less than or equal to current max id
    function approve(
        address spender,
        uint256 amountOrId
    ) public virtual returns (bool) {
        if (amountOrId <= minted) {
            address owner = _getOwnerOf(amountOrId);

            if (msg.sender != owner && !isApprovedForAll[owner][msg.sender]) {
                revert Unauthorized();
            }

            getApproved[amountOrId] = spender;

            emit Approval(owner, spender, amountOrId);
        } else {
            allowance[msg.sender][spender] = amountOrId;

            emit Approval(msg.sender, spender, amountOrId);
        }

        return true;
    }

    /// @notice Function native approvals
    function setApprovalForAll(address operator, bool approved) public virtual {
        isApprovedForAll[msg.sender][operator] = approved;

        emit ApprovalForAll(msg.sender, operator, approved);
    }

    /// @notice Function for mixed transfers
    /// @dev This function assumes id / native if amount less than or equal to current max id
    function transferFrom(
        address from,
        address to,
        uint256 amountOrId
    ) public virtual {
        if (to == address(0)) {
            revert InvalidRecipient();
        }

        if (amountOrId <= minted) {
            uint256 i;

            if (from != _getOwnerOf(amountOrId)) {
                revert Unauthorized();
            }

            if (
                msg.sender != from &&
                !isApprovedForAll[from][msg.sender] &&
                msg.sender != getApproved[amountOrId]
            ) {
                revert Unauthorized();
            }

            balanceOf[from] -= _getUnit();

            unchecked {
                balanceOf[to] += _getUnit();
            }

            _setOwnerOf(amountOrId, to);
            delete getApproved[amountOrId];

            // get last id and remove it
            uint256 lastIndex = _owned[from].length - 1;
            uint256 lastIdTemp = _owned[from][lastIndex];
            uint256 lastId = 0;

            if (lastIdTemp >> 16 == 0) {
                _owned[from].pop();
                lastId = lastIdTemp;
            } else {
                i = 2;
                for (; i < 16; i++) {
                    if ((lastIdTemp >> (i * 16)) == 0) {
                        break;
                    }
                }

                lastId = lastIdTemp >> ((i - 1) * 16);
                _owned[from][lastIndex] =
                    lastIdTemp -
                    (lastId << ((i - 1) * 16));
            }

            // move last id to index of amountOrId
            if (lastId != amountOrId) {
                _setOwnedIndex(lastId, _getOwnedIndex(amountOrId));

                uint256 index = _getOwnedIndex(amountOrId) >> 4;
                uint256 subIndex = _getOwnedIndex(amountOrId) - (index << 4);
                uint256 idTemp = _owned[from][index];

                _owned[from][index] =
                    idTemp -
                    (amountOrId << (16 * subIndex)) +
                    (lastId << (16 * subIndex));
            }

            // push amountOrId to to
            uint256 toIndex = 0;
            uint256 toIdTemp = 0;
            if (_owned[to].length > 0) {
                toIndex = _owned[to].length - 1;
                toIdTemp = _owned[to][toIndex];
            }

            i = 0;
            for (; i < 16; i++) {
                if ((toIdTemp >> (i * 16)) == 0) {
                    toIdTemp = toIdTemp | (amountOrId << (i * 16));
                    if (_owned[to].length == 0) _owned[to].push(toIdTemp);
                    else _owned[to][toIndex] = toIdTemp;
                    _setOwnedIndex(amountOrId, toIndex * 16 + i);
                    break;
                }
            }

            if (i == 16) {
                _owned[to].push(amountOrId);
                _setOwnedIndex(amountOrId, (toIndex + 1) * 16);
            }

            emit Transfer(from, to, amountOrId);
            emit ERC20Transfer(from, to, _getUnit());
        } else {
            uint256 allowed = allowance[from][msg.sender];

            if (allowed < amountOrId) revert NotAllowed();

            if (allowed != type(uint256).max)
                allowance[from][msg.sender] = allowed - amountOrId;

            _transfer(from, to, amountOrId);
        }
    }

    /// @notice Function for fractional transfers
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        return _transfer(msg.sender, to, amount);
    }

    /// @notice Function for native transfers with contract support
    function safeTransferFrom(
        address from,
        address to,
        uint256 id
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, "") !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Function for native transfers with contract support and callback data
    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        bytes calldata data
    ) public virtual {
        transferFrom(from, to, id);

        if (
            to.code.length != 0 &&
            ERC721Receiver(to).onERC721Received(msg.sender, from, id, data) !=
            ERC721Receiver.onERC721Received.selector
        ) {
            revert UnsafeRecipient();
        }
    }

    /// @notice Internal function for fractional transfers
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        uint256 unit = _getUnit();
        uint256 balanceBeforeSender = balanceOf[from];
        balanceOf[from] -= amount;

        uint256 balanceBeforeReceiver = balanceOf[to];
        unchecked {
            balanceOf[to] += amount;
        }
        
        if (!nftMintBurnPaused) {
            if (whitelist[from] && whitelist[to]) {} else if (whitelist[from]) {
                // [to] is not whitelisted.
                uint256 tokens_to_mint = (balanceOf[to] / unit) -
                    (balanceBeforeReceiver / unit);

                if (tokens_to_mint > 0) _mint(to, tokens_to_mint);
            } else if (whitelist[to]) {
                // [from] is not whitelisted.
                uint256 tokens_to_burn = (balanceBeforeSender / unit) -
                    (balanceOf[from] / unit);

                if (tokens_to_burn > 0) _burn(from, tokens_to_burn);
            } else {
                // Both are not whitelisted.

                // Whole tokens worth of ERC-20s get transferred as ERC-721s without any burning/minting.
                uint256 nftsToTransfer = amount / unit;
                for (uint256 i = 0; i < nftsToTransfer; ) {
                    // Pop from sender's ERC-721 stack and transfer them (LIFO)
                    (
                        uint256 tokenId,
                        uint256 index,
                        uint256 lastSubIndex
                    ) = _getLastTokenId(from);

                    _transferLastERC721(from, to, tokenId, index, lastSubIndex);

                    unchecked {
                        i++;
                    }
                }

                uint256 fractionalAmount = amount % unit;
                if (
                    (balanceBeforeSender - fractionalAmount) / unit <
                    (balanceBeforeSender / unit)
                ) {
                    _burn(from, 1);
                }

                // Check if the receive causes the receiver to gain a whole new token that should be represented
                // by an NFT due to receiving a fractional part that completes a whole token.
                if (
                    (balanceBeforeReceiver + fractionalAmount) / unit >
                    (balanceBeforeReceiver / unit)
                ) {
                    _mint(to, 1);
                }
            }
        }

        emit ERC20Transfer(from, to, amount);
        return true;
    }

    // Internal utility logic
    function _getUnit() internal view returns (uint256) {
        return 10 ** decimals;
    }

    /// @notice Consolidated record keeping function for transferring ERC-721s.
    /// @dev Assign the token to the new owner, and remove from the old owner.
    /// Note that this function allows transfers to and from 0x0.
    /// Does not handle ERC-721 exemptions.

    function _transferLastERC721(
        address from,
        address to,
        uint256 id,
        uint256 index,
        uint256 lastSubIndex
    ) internal virtual {
        // If this is not a mint, handle record keeping for transfer from previous owner.
        if (from != address(0)) {
            // On transfer of an NFT, any previous approval is reset.

            if (lastSubIndex == 0) {
                _owned[from].pop();
            } else {
                uint256 idTemp = _owned[from][index];
                idTemp = idTemp - (id << (lastSubIndex * 16));
                _owned[from][index] = idTemp;
            }

            // delete _ownedData[id];
            delete getApproved[id];
        }

        // If not a burn, update the owner of the token to the new owner.
        // Update owner of the token to the new owner.
        _setOwnerOf(id, to);
        // Push token onto the new owner's stack.
        (
            uint256 toLastTokenId,
            uint256 toIndex,
            uint256 toSubIndex
        ) = _getLastTokenId(to);

        if (_owned[to].length == 0) {
            _owned[to].push(id);
        } else if (toSubIndex == 15) {
            _owned[to].push(id);
            toIndex++;
            toSubIndex = 0;
        } else {
            uint256 idTemp = _owned[to][toIndex];
            toSubIndex++;
            idTemp = idTemp | (id << (toSubIndex * 16));
            _owned[to][toIndex] = idTemp;
        }

        // Update index for new owner's stack.
        _setOwnedIndex(id, toIndex * 16 + toSubIndex);

        emit ERC721Transfer(from, to, id);
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (to == address(0)) {
            revert InvalidRecipient();
        }

        uint256 i;

        // find last item position
        uint256 index = 0;
        uint256 subIndex = 0;
        uint256 idTemp = 0;
        bool updateFirst = false;

        if (_owned[to].length > 0) {
            index = _owned[to].length - 1;
            idTemp = _owned[to][index];

            for (i = 0; i < 16; i++) {
                if ((idTemp >> (i * 16)) == 0) {
                    subIndex = i;
                    updateFirst = true;
                    break;
                }
            }

            if (i == 16) {
                index++;
                idTemp = 0;
            }
        }

        for (i = 0; i < amount; i++) {
            uint256 id;

            if (minted < totalNativeSupply) {
                // Increase id up to totalNativeSupply
                minted++;
                id = minted;
            } else {
                if (!DoubleEndedQueue.empty(_storedERC721Ids)) {
                    // If there are any tokens in the bank, use those first.
                    // Pop off the end of the queue (FIFO).
                    id = _storedERC721Ids.popBack();
                } else {
                    // Otherwise, mint a new token, should not be able to go over the total fractional supply.
                    minted++;
                    id = minted;
                }
            }

            if (_getOwnerOf(id) != address(0)) {
                revert AlreadyExists();
            }

            _setOwnerOf(id, to);
            _setOwnedIndex(id, index * 16 + subIndex);

            idTemp = idTemp | (id << (subIndex * 16));
            subIndex++;

            if (subIndex == 16) {
                if (updateFirst) {
                    _owned[to][index] = idTemp;
                    updateFirst = false;
                } else {
                    _owned[to].push(idTemp);
                }

                subIndex = 0;
                index++;
                idTemp = 0;
            }

            emit Transfer(address(0), to, id);
        }

        if (subIndex != 0) {
            if (updateFirst) {
                _owned[to][index] = idTemp;
            } else {
                _owned[to].push(idTemp);
            }
        }
    }

    function _burn(address from, uint256 amount) internal virtual {
        if (from == address(0)) {
            revert InvalidSender();
        }

        if (_owned[from].length == 0 || amount == 0) {
            revert InvalidParameter();
        }

        // find last item position
        uint256 index = _owned[from].length - 1;
        uint256 idTemp = _owned[from][index];
        uint256 lastSubIndex = 15;

        for (uint256 i = 1; i < 16; i++) {
            if ((idTemp >> (i * 16)) == 0) {
                lastSubIndex = i - 1;
                break;
            }
        }

        for (uint256 i = 0; i < amount; i++) {
            uint256 id = idTemp;
            if (lastSubIndex == 0) {
                lastSubIndex = 15;
                if (index > 0) index--;
                idTemp = _owned[from][index];
                _owned[from].pop();
            } else {
                id = idTemp >> (lastSubIndex * 16);
                idTemp = idTemp - (id << (lastSubIndex * 16));
                lastSubIndex--;
            }

            delete _ownedData[id];
            delete getApproved[id];

            // Record the token in the contract's bank queue.
            _storedERC721Ids.pushFront(id);

            emit Transfer(from, address(0), id);
        }

        if (lastSubIndex != 15) {
            _owned[from][index] = idTemp;
        }
    }

    function _setNameSymbol(
        string memory _name,
        string memory _symbol
    ) internal {
        name = _name;
        symbol = _symbol;
    }

    function _getOwnerOf(
        uint256 id_
    ) internal view virtual returns (address ownerOf_) {
        uint256 data = _ownedData[id_];

        assembly {
            ownerOf_ := and(data, _BITMASK_ADDRESS)
        }
    }

    function _setOwnerOf(uint256 id_, address owner_) internal virtual {
        uint256 data = _ownedData[id_];

        assembly {
            data := add(
                and(data, _BITMASK_OWNED_INDEX),
                and(owner_, _BITMASK_ADDRESS)
            )
        }

        _ownedData[id_] = data;
    }

    function _getOwnedIndex(
        uint256 id_
    ) internal view virtual returns (uint256 ownedIndex_) {
        uint256 data = _ownedData[id_];

        assembly {
            ownedIndex_ := shr(160, data)
        }
    }

    function _setOwnedIndex(uint256 id_, uint256 index_) internal virtual {
        uint256 data = _ownedData[id_];

        if (index_ > _BITMASK_OWNED_INDEX >> 160) {
            revert OwnedIndexOverflow();
        }

        assembly {
            data := add(
                and(data, _BITMASK_ADDRESS),
                and(shl(160, index_), _BITMASK_OWNED_INDEX)
            )
        }

        _ownedData[id_] = data;
    }
}
