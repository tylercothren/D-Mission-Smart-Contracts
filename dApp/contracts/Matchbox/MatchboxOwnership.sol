pragma solidity ^0.4.20;

import "./MatchboxBase.sol";

/// @title The facet of the Matchboxes! core contract that manages ownership, ERC-721 (draft) compliant.
/// @dev Ref: https://github.com/ethereum/EIPs/issues/721
contract MatchboxOwnership is MatchboxBase {

    /// @notice Name and symbol of the non fungible token, as defined in ERC721.
    string public name = "D-Mission! [Matchboxes]";
    string public symbol = "DMM";
    
    /**
    * @notice Guarantees msg.sender is owner of the given Matchbox
    * @param _tokenId uint256 ID of the Matchbox to validate its ownership belongs to msg.sender
    */
    modifier onlyOwnerOfMatchbox(uint256 _tokenId) {
        require(_owns(msg.sender, _tokenId));
        _;
    }

    // bool public implementsERC721 = true;
    function implementsERC721() public pure returns (bool)
    {
        return true;
    }

    /// @dev Checks if a given address is the current owner of a particular Matchbox.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) 
    {
        return matchboxIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Matchbox.
    /// @param _claimant the address we are confirming Matchbox is approved for.
    /// @param _tokenId Matchbox id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) 
    {
        return matchboxIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    function _approve(uint256 _tokenId, address _approved) internal 
    {
        matchboxIndexToApproved[_tokenId] = _approved;
        
        // Emit approval event.
        Approval(msg.sender, _approved, _tokenId);
    }

    /// @dev Transfers a Matchbox owned by this contract to the specified address.
    ///  Used to rescue lost Matchbox. (There is no "proper" flow where this contract
    ///  should be the owner of any Matchbox. This function exists for us to reassign
    ///  the ownership of Matchbox that users may have accidentally sent to our address.)
    /// @param _matchboxId - ID of Matchbox
    /// @param _recipient - Address to send the Matchbox to
    function rescueLostMatchbox(uint256 _matchboxId, address _recipient) public onlyCOO whenNotPaused onlyOwnerOfMatchbox(_matchboxId)
    {
        require(_owns(this, _matchboxId));
        _transfer(this, _recipient, _matchboxId);
    }

    /// @notice Returns the number of Matchboxes owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) external view returns (uint256 count) 
    {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Matchbox to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  D-Mission! specifically) or your Matchbox may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Matchbox to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer( address _to, uint256 _tokenId ) public whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        
        // You can only send your own Matchbox.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Matchbox via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Matchbox that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve( address _to, uint256 _tokenId ) external payable whenNotPaused onlyOwnerOfMatchbox(_tokenId)
    {
        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);
    }

    /// @notice Transfer a Matchbox owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Matchbox to be transfered.
    /// @param _to The address that should take ownership of the Matchbox. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Matchbox to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom( address _from, address _to, uint256 _tokenId ) external payable whenNotPaused onlyOwnerOfMatchbox(_tokenId)
    {
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Matchboxes currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return matchboxes.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Matchbox.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId) external view returns (address owner)
    {
        owner = matchboxIndexToOwner[_tokenId];

        require(owner != address(0));
    }

    /// @notice Returns the nth Matchbox assigned to an address, with n specified by the
    ///  _index argument.
    /// @param _owner The owner whose Matchboxes we are interested in.
    /// @param _index The zero-based index of the cat within the owner's list of Matchboxes.
    ///  Must be less than balanceOf(_owner).
    /// @dev This method MUST NEVER be called by smart contract code. It will almost
    ///  certainly blow past the block gas limit once there are a large number of
    ///  Matchboxes in existence. Exists only to allow off-chain queries of ownership.
    ///  Optional method for ERC-721.
    function tokensOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= totalSupply(); i++) {
            if (matchboxIndexToOwner[i] == _owner) {
                if (count == _index) {
                    return i;
                } else {
                    count++;
                }
            }
        }
        revert();
    }
}