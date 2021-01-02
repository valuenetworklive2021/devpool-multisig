pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

// import ierc20 & safemath & non-standard
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Tresury {
    address[] public approvers;
    uint public votes;
    struct Transfer {
        uint id;
        uint amount;
        address payable to;
        uint approvals;
        bool sent;
    }
    Transfer[] public transfers;
    mapping(address => mapping(uint => bool)) public approvals;
    
    IERC20 public dai;
    
    constructor(address[] memory _approvers, uint _votes , address _dai) public {
        approvers = _approvers;
        votes = _votes;
        dai = IERC20(_dai);
    }
    
    function getApprovers() external view returns(address[] memory) {
        return approvers;
    }
    
    function getTransfers() external view returns(Transfer[] memory) {
        return transfers;
    }

    function createTransfer(uint amount, address payable to) external onlyApprover() {
        transfers.push(Transfer(
            transfers.length,
            amount,
            to,
            0,
            false
        ));
    }
    
    function approveTransfer(uint id) external onlyApprover() {
        require(transfers[id].sent == false, 'transfer has already been sent');
        require(approvals[msg.sender][id] == false, 'cannot approve transfer twice');
        
        approvals[msg.sender][id] = true;
        transfers[id].approvals++;
        
        if(transfers[id].approvals >= votes && approvals[approvers[0]][id]) {
            transfers[id].sent = true;
            address payable to = transfers[id].to;
            uint amount = transfers[id].amount;
            dai.transfer(to,amount);
        }
    }
    
    function getTotaldai() public view returns(uint256){
        return dai.balanceOf(address(this));
    }
    
    modifier onlyApprover() {
        bool allowed = false;
        for(uint i = 0; i < approvers.length; i++) {
            if(approvers[i] == msg.sender) {
                allowed = true;
            }
        }
        require(allowed == true, 'only approver allowed');
        _;
    }
    
}
