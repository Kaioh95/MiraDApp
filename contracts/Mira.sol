pragma solidity ^0.7.0;

contract Mira {
    
    address payable owner;
    mapping(address => uint) tokens;
    mapping(address => uint) scores;

    address payable[3] top3;
    address[] enderecos;

    uint valorToken = 0.1 ether;
    
    event TokenComprado(address comprador, uint quantidade);
    event NovoScore(uint8 record, address enderecoRecord);

    event First(uint score, address ganhador);
    event Second(uint score, address ganhador);
    event Third(uint score, address ganhador);
    
    constructor(){
        owner = msg.sender;
    }
    
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

        if(tokens[msg.sender] == 0){
            enderecos.push(msg.sender);
        }

        for(uint ii = 0; ii < _quant; ii++){
            tokens[msg.sender] += 1;
        }

        emit TokenComprado(msg.sender, _quant);
    }

    function registraScore(uint score) public payable{
        require(tokens[msg.sender] > 0, "Nao possui fichas!");
        scores[msg.sender] = score;
        tokens[msg.sender]--;

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

    function distribuirPremio() external onlyOwner{
        uint premio = address(this).balance;
        address enderecoVazio;

        uint premioTop1 = premio * 4 / 10;
        uint premioTop2 = premio * 2 / 10;
        uint premioTop3 = premio / 10;

        if(top3[2] != enderecoVazio){
            top3[0].transfer(premioTop1);
            top3[1].transfer(premioTop2);
            top3[2].transfer(premioTop3);
        } else if (top3[1] != enderecoVazio){
            top3[0].transfer(premioTop1);
            top3[1].transfer(premioTop2);
        } else if(top3[0] != enderecoVazio){
            top3[0].transfer(premioTop1);
        }

        resetar();
        sacar();
    }

    //Premios: 40%, 20% e 10%. Mostrar prêmio mostra apenas 70% do balanço.
    function resetar() public onlyOwner{
        uint ii = 0;
        while(enderecos.length != 0){
            tokens[enderecos[ii]] = 0;
            scores[enderecos[ii]] = 0;
            enderecos.pop();
            ii++;
        }

        /*for(uint ii = 0; ii < enderecos.length; ii++){
            delete tokens[enderecos[ii]];
            delete scores[enderecos[ii]];
        }

        delete top3;*/
    }

    function numeroJogadores() public view returns(uint){
        return enderecos.length;
    }

    function sacar() public onlyOwner{
        msg.sender.transfer(address(this).balance);
    }

    function isOwner() public view returns (bool){
        if(msg.sender != owner){
            return false;
        }

        return true;
    }

    function destroy() public onlyOwner{
        selfdestruct(owner);
    }
    
}