pragma solidity ^0.7.0;

contract Mira {
    
    address owner;
    mapping(address => uint) tokens;
    mapping(address => uint) scores;

    address[3] top3;

    uint valorToken = 0.1 ether;
    
    event TokenComprado(address comprador, uint quantidade);
    event NovoScore(uint8 record, address enderecoRecord);

    event First(uint score, address ganhador);
    event Second(uint score, address ganhador);
    event Third(uint score, address ganhador);
    
    constructor();
    
    modifier onlyOwner{
        require(msg.sender == owner, "Only contract owner can call this function!");
        _;
    }

    function verificarPodeJogar() public view returns (bool){
        if(tokens[msg.sender] > 0){
            return true;
        }

        return false;
    }

    function comprarToken(uint _quant) public payable{
        require(msg.value == _quant*valorToken, "Quantidade invalida!");

        for(uint ii = 0; ii < _quant; ii++){
            tokens[msg.sender] += 1;
        }

        emit TokenComprado(msg.sender, _quant);
    }

    function registraScore(uint score) public{

        if(score > scores[top3[0]]){
            top3[2] = top3[1];  // top3 = top2
            top3[1] = top3[0];  // top2 = top1
            top3[0] = msg.sender;    // top1 = new score

            emit NovoScore(1, msg.sender);
        } else if(score > scores[top3[1]]){
            top3[2] = top3[1];  //top3 = top2
            top3[1] = msg.sender;    // top2 = new score

            emit NovoScore(2, msg.sender);
        } else if(score > scores[top3[2]]){
            top3[2] = msg.sender;    //top3 = new score

            emit NovoScore(3, msg.sender);
        } else{
            emit NovoScore(0, msg.sender);
        }
    }

    function verQuantidadeTokens() public view returns(uint){
        return tokens[msg.sender];
    }

    function verScore() public view returns(uint){
        return scores[msg.sender];
    }

    function verPremio() public view returns (uint){
        return address(this).balance * 7 / 10;
    }
        
    function verTop3() public{
        emit First(scores[top3[0]], top3[0]);
        emit Second(scores[top3[1]], top3[1]);
        emit Third(scores[top3[2]], top3[2]);
    }

    function distribuirPremio() external onlyOwner;

    //Premios: 40%, 20% e 10%. Mostrar prêmio mostra apenas 70% do balanço.
    function resetar() public onlyOwner;
    
    function isOwner() public view returns (bool);
    
}