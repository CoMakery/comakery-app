contract Project {
    string public name;
    string public symbol;
    uint8 public decimals;

    mapping (address => uint256) public balanceOf;

    /* public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /* Initializes contract with initial supply tokens to the creator of the contract */
    function Project(uint256 initialSupply, string tokenName) {
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
    }

    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Check if the sender has enough
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Check for overflows
        balanceOf[msg.sender] -= _value;                     // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        Transfer(msg.sender, _to, _value);                   // Notify anyone listening that this transfer took place
    }

    function balances() {
        return balanceOf;
    }

    /* This unnamed function is called whenever someone tries to send ether to it */
    function () {
        throw;     // Prevents accidental sending of ether
    }
}
