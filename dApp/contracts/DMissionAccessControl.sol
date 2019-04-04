pragma solidity ^0.4.2;

contract DMissionAccessControl 
{
    /**
    * @notice ContractUpgrade is the event that will be emitted if we set a new contract address
    */
    event ContractUpgrade(address newContract);
    event Paused();
    event Unpaused();


    address public ceoAddress;
    address public cfoAddress;
    address public cooAddress;
    address public withdrawalAddress;

    bool public paused = false;

    modifier onlyCEO() 
    {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onlyCFO() 
    {
        require(msg.sender == cfoAddress);
        _;
    }

    modifier onlyCOO() 
    {
        require(msg.sender == cooAddress);
        _;
    }

    modifier onlyCLevel() 
    {
        require(
            msg.sender == cooAddress ||
            msg.sender == ceoAddress ||
            msg.sender == cfoAddress
        );
        _;
    }

    function setCEO(address _newCEO) external onlyCEO 
    {
        require(_newCEO != address(0));

        ceoAddress = _newCEO;
    }

    function setCFO(address _newCFO) external onlyCEO 
    {
        require(_newCFO != address(0));

        cfoAddress = _newCFO;
    }

    function setCOO(address _newCOO) external onlyCEO 
    {
        require(_newCOO != address(0));

        cooAddress = _newCOO;
    }
    
    /**
    * @notice Sets a new withdrawalAddress
    * @param _newWithdrawalAddress - the address where we'll send the funds
    */
    function setWithdrawalAddress(address _newWithdrawalAddress) external onlyCEO 
    {
        require(_newWithdrawalAddress != address(0));
        withdrawalAddress = _newWithdrawalAddress;
    }
    
    /**
    * @notice Withdraw the balance to the withdrawalAddress
    * @dev We set a withdrawal address seperate from the CFO because this allows us to withdraw to a cold wallet.
    */
    function withdrawBalance() external onlyCLevel 
    {
        require(withdrawalAddress != address(0));
        withdrawalAddress.transfer(this.balance);
    }

    modifier whenNotPaused() 
    {
        require(!paused);
        _;
    }

    modifier whenPaused 
    {
        require(paused);
        _;
    }

    function pause() external onlyCLevel whenNotPaused 
    {
        paused = true;
    }

    function unpause() public onlyCEO whenPaused 
    {
        paused = false;
    }
}