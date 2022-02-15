pragma solidity ^0.7.0;

contract Mira {
    
    address payable owner;
    mapping(address => uint) tokens; //Quantidade de tokens de cada usuário
    mapping(address => uint) scores; //Scores record de cada usuário

    address payable[3] top3;    //Endereços do top3
    uint[3] top3Scores;         //Scores do top3
    address[] enderecos;        //Jogadores que compraram tokens

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

    function verPrecoToken() public view returns(uint){
        return valorToken;
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

    // Registra quando o jogador possui tokens para gastar
    function registraScore(uint score) public payable{
        require(tokens[msg.sender] > 0, "Nao possui fichas!");
        tokens[msg.sender]--;
        
        if(score > scores[msg.sender]){ // Em caso de record pessoal o novo score eh registrado 
            scores[msg.sender] = score;
        }

        // Lógica de ocupacao do top3
        if(score > top3Scores[0]){
            
            top3[2] = top3[1];  // top3 = top2
            top3[1] = top3[0];  // top2 = top1
            top3[0] = msg.sender;    // top1 = new score

            top3Scores[2] = top3Scores[1]; 
            top3Scores[1] = top3Scores[0];
            top3Scores[0] = score;
            emit NovoScore(1, msg.sender);
        } else if(score > top3Scores[top3[1]]){
            
            top3[2] = top3[1];  //top3 = top2
            top3[1] = msg.sender;    // top2 = new score

            top3Scores[2] = top3Scores[1];
            top3Scores[1] = score;
            emit NovoScore(2, msg.sender);
        } else if(score > top3Scores[top3[2]]){
            
            top3[2] = msg.sender;    //top3 = new score

            top3Scores[2] = score;
            emit NovoScore(3, msg.sender);
        } else {
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
        
    function verTop1() public view returns(uint score, address enderecoTop1){
        return (top3Scores[0], top3[0]);
    }

    function verTop2() public view returns(uint score, address enderecoTop2){
        return (top3Scores[1], top3[1]);
    }

    function verTop3() public view returns(uint score, address enderecoTop3){
        return (top3Scores[2], top3[2]);
    }

    //Premios: 40%, 20% e 10% para top1, top2 e top3 respectivamente
    function distribuirPremio() external onlyOwner{
        uint premio = address(this).balance;
        address enderecoVazio;

        uint premioTop1 = premio * 4 / 10;
        uint premioTop2 = premio * 2 / 10;
        uint premioTop3 = premio / 10;

        // Quando endereco eh 0x00... o premio nao eh transferido
        if(top3[2] != enderecoVazio){

            top3[0].transfer(premioTop1);
            top3[1].transfer(premioTop2);
            top3[2].transfer(premioTop3);
            emit First(top3Scores[0], top3[0]);
            emit Second(top3Scores[1], top3[1]);
            emit Third(top3Scores[2], top3[2]);
        } else if (top3[1] != enderecoVazio){
            
            top3[0].transfer(premioTop1);
            top3[1].transfer(premioTop2);
            emit First(top3Scores[0], top3[0]);
            emit Second(top3Scores[1], top3[1]);
        } else if(top3[0] != enderecoVazio){
            
            top3[0].transfer(premioTop1);
            emit First(top3Scores[0], top3[0]);
        }

        resetar();
    }

    function resetar() public onlyOwner{

        for(uint ii = 0; ii < enderecos.length; ii++){
            tokens[enderecos[ii]] = 0;
            scores[enderecos[ii]] = 0;
        }
        
        delete enderecos;
        delete top3;
        delete top3Scores;
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