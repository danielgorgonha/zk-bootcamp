# Aula 2 - O Grande Código | Seu primeiro projeto no ar usando solidity

## Programação
1. **Configuração do Ambiente**: Ferramentas do Foundry
2. **EVM & Solidity**: Arquitetura e ecossistema
3. **Fundamentos de Solidity**: Tipos de dados, funções e memória
4. **Segurança Básica**: Validação e controle de acesso
5. **ERC-20 na Prática**: Implementação de um token

## Configurando o Ambiente com Foundry
### **Por que Solidity? (2025)**

- EVM é a plataforma mais usada para smart contracts (Ethereum, Polygon, Arbitrum, etc).
- Solidity é a linguagem mais madura para EVM.

### Foundry

- cast: Ferramenta para interagir com contratos e enviar transações.
- anvil: Simulador de rede local para testes de contratos.
- forge: Compilador e ferramenta de construção para contratos Solidity.
- chisel: Um ambiente interativo (tipo terminal) onde você pode digitar e testar trechos de código Solidity em tempo real, sem precisar compilar todo o projeto. Também é conhecido como REPL (Read-Eval-Print Loop).

#### 🚀 Instalação do Foundry

Este guia explica como instalar e configurar o [Foundry](https://book.getfoundry.sh/) no seu sistema. O Foundry é uma suíte de ferramentas rápidas e portáveis para desenvolvimento de contratos inteligentes em Solidity.

##### ✅ Requisitos

- [Git](https://git-scm.com/)
- [Rust](https://www.rust-lang.org/tools/install)
- [Make](https://www.gnu.org/software/make/) (opcional, mas útil para alguns scripts)
- Sistema operacional: Linux, macOS ou WSL2 (Windows)

> Para Windows nativo (sem WSL), recomenda-se o uso do WSL2 com Ubuntu.

##### 🔧 Passo a Passo de Instalação

###### 1. Instale o Rust (se ainda não tiver)

```bash
curl https://sh.rustup.rs -sSf | sh
```

Após a instalação, reinicie o terminal ou execute:

```bash
source $HOME/.cargo/env
```

---

###### 2. Instale o Foundry via Foundryup

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Depois, adicione o Foundry ao seu terminal (caso necessário):

```bash
source ~/.bashrc    # ou ~/.zshrc, dependendo do seu shell
```

---

###### 3. Inicialize o Foundry

```bash
foundryup
```

Esse comando irá baixar e compilar os binários mais recentes: `forge`, `cast`, `anvil` e `chisel`.

---

###### 🧪 Verifique a Instalação

Rode os comandos abaixo para verificar se tudo está funcionando:

```bash
forge --version
cast --version
anvil --version
```

---

###### ⚙️ Inicializando um Projeto

Crie um novo projeto com o comando:

```bash
forge init nome-do-projeto
cd nome-do-projeto
forge build
```

---

###### 📚 Documentação

Para mais informações e comandos avançados, consulte a [documentação oficial do Foundry](https://book.getfoundry.sh/).


### EVM & Solidity

- Solidity → EVM → Blockchain (como Java → JVM → CPU).
- **Smart Contracts ≈ Classes**:
  - `Contract` → `Class`
  - `Functions` → `Methods`
  - `Storage` → `Attributes`

---

### Fundamentos de Solidity

#### Solidity: Conceitos-Chave

| Conceito                     | Exemplos                                                                         |
| ---------------------------- | -------------------------------------------------------------------------------- |
| **Tipos de dados**           | `(u)int8/16/32/64/128/256`, `int`, `bool`, `address`, `string`, `bytes`, `array`, `mapping`      |
| **Visibilidade de Atributos**             | `public`, `private`, `internal`                                    |
| **Visibilidade Funções**             | `public`, `private`, `internal`, `external`                                     |
| **Funções**                  | `view`, `pure`, `payable`, `constructor`, `fallback`, `receive`                 |
| **Gerenciamento de memória** | `storage` (persistente), `memory` (temporário), `calldata` (parâmetros externos)|

##### 🧠 Resumo: O que significam `uint8`, `uint16`, `uint32`, ..., `uint256`?

Em Solidity, os tipos `uint` e `int` podem ser especificados com tamanhos explícitos em **múltiplos de 8 bits**, indo de **8 até 256**.

###### 📏 O que representam os números (8, 16, 32, ... 256)?

Eles indicam a **quantidade de bits** usada para armazenar o valor:

| Tipo        | Bits | Faixa (`uint`)                  | Faixa (`int`)                             |
|-------------|------|----------------------------------|--------------------------------------------|
| `uint8`     | 8    | 0 a 255                          | —                                          |
| `int8`      | 8    | —                                | -128 a 127                                 |
| `uint16`    | 16   | 0 a 65.535                       | —                                          |
| `int16`     | 16   | —                                | -32.768 a 32.767                           |
| `uint32`    | 32   | 0 a 4.294.967.295                | —                                          |
| `int32`     | 32   | —                                | -2.147.483.648 a 2.147.483.647             |
| `uint64`    | 64   | 0 a 18.446.744.073.709.551.615   | —                                          |
| `int64`     | 64   | —                                | -9.2×10¹⁸ a +9.2×10¹⁸                      |
| `uint128`   | 128  | Muito maior (2¹²⁸−1)             | —                                          |
| `int128`    | 128  | —                                | ±(2¹²⁷−1)                                  |
| `uint256`   | 256  | Máximo suportado em Solidity     | —                                          |
| `int256`    | 256  | —                                | ±(2²⁵⁵−1)                                  |

###### 🛠️ Dicas de uso

- **Quanto menor o número de bits, menos espaço de armazenamento é usado** → útil para otimizar gás em estruturas compactas.
- **Evite tamanhos pequenos (ex: `uint8`) em operações aritméticas**, pois podem causar overflow se não forem tratados.
- O tipo padrão é `uint256` ou `int256`, se não especificado.

📌 **Resumo rápido**:
- `uintX` = inteiros **sem sinal**, com **X bits**
- `intX` = inteiros **com sinal**, com **X bits**

---

##### 🔍 Resumo: Diferença entre `uint` e `int`

- `uint` (unsigned integer):  
  Representa **somente números inteiros positivos**, incluindo zero.  
  Ex: `uint8`, `uint256` (faixas de 0 a 2⁸−1 ou 2²⁵⁶−1).

- `int` (signed integer):  
  Representa **números inteiros positivos e negativos**.  
  Ex: `int8`, `int256` (faixas de -2⁷ a 2⁷−1 ou -2²⁵⁵ a 2²⁵⁵−1).

✅ Use `uint` quando **não há possibilidade de valores negativos**, o que é comum em contadores, saldos, índices etc.  
⚠️ Usar `int` quando precisar representar dívidas, variações ou valores negativos.

---

##### 🔧 Resumo: Atributos em Solidity — Tipos e Visibilidade

###### 🔹 Visibilidade do Atributo

Define **quem pode acessar** uma variável do contrato:

| Modificador   | Quem pode acessar                         | Uso comum                                     |
|---------------|-------------------------------------------|-----------------------------------------------|
| `public`      | Qualquer um (interna e externamente)      | Expor informações no contrato (com getter)    |
| `internal`    | Somente no contrato e contratos herdados  | Lógica interna reutilizável                   |
| `private`     | Apenas dentro do próprio contrato         | Proteger dados sensíveis  



##### 🔧 Resumo: Funções em Solidity: Conceitos e Modificadores

Em Solidity, funções são blocos de código que executam lógica no contrato. Elas podem ter **modificadores** que definem **comportamento de leitura/escrita**, **visibilidade** e **pagamento**.

---

###### 🔹 Visibilidade da Função

Define **quem pode chamar** a função:

| Modificador   | Quem pode chamar                  | Uso comum                                      |
|---------------|------------------------------------|------------------------------------------------|
| `public`      | Qualquer um (interna e externamente) | Interface externa e lógica interna             |
| `external`    | Somente de fora do contrato        | Funções de API externa                         |
| `internal`    | Somente dentro do contrato atual ou contratos herdados | Lógica de apoio                                 |
| `private`     | Apenas dentro do próprio contrato  | Lógica totalmente encapsulada                  |

---

###### 🔹 Comportamento de Leitura/Escrita

Controla se a função **lê** ou **modifica** o estado do contrato:

| Modificador | Permite leitura de estado? | Permite alteração de estado? | Exemplo de uso                         |
|-------------|-----------------------------|-------------------------------|----------------------------------------|
| `view`      | ✅ Sim                      | ❌ Não                        | Retorna variáveis armazenadas          |
| `pure`      | ❌ Não                      | ❌ Não                        | Apenas cálculos internos, sem acesso ao estado |
| (sem tag)   | ✅ Sim                      | ✅ Sim                        | Altera variáveis, faz transferências etc |

---

###### 🔹 Modificador `payable`

Permite que a função **receba Ether** junto com a chamada:

```solidity
function deposit() public payable { }
```

> Necessário para que o contrato aceite pagamentos.


###### 🧠 Observações importantes
Atributos não têm view ou pure — esses modificadores só se aplicam a funções.

Se você não especificar visibilidade, o padrão é internal.

###### 🔍 Por que parece confuso?

Porque ao olhar para uma função assim:

```solidity
function transfer(address to, uint amount) external returns (bool) { ... }
```

Você vê external junto da definição e pode pensar que ele "define o tipo" da função. Mas o papel dele é controlar quem pode chamar essa função.

###### ✅ Recapitulando com clareza

| **Categoria**         | **Palavra-chave**                                                                 |
|-----------------------|------------------------------------------------------------------------------------|
| **Visibilidade**      | `public`, `private`, `internal`, `external` → quem pode acessar a função          |
| **Comportamento**     | `view`, `pure`, `payable` → como a função interage com o estado / com Ether       |
| **Funções especiais** | `constructor`, `receive`, `fallback` → executadas em momentos específicos         |

---

##### 🧠 Resumo: Gerenciamento de Memória em Solidity

Solidity possui três regiões principais para armazenar dados durante a execução de contratos:

| Região     | Duração                    | Uso típico                                 |
|------------|----------------------------|---------------------------------------------|
| `storage`  | Permanente (na blockchain) | Variáveis de estado do contrato             |
| `memory`   | Temporária (na execução)   | Variáveis locais em funções                 |
| `calldata` | Temporária e imutável      | Parâmetros de entrada de funções `external` |

---

###### ✨ Detalhes rápidos:

- **`storage`**
  - Guarda dados persistentes no blockchain.
  - Ex: `uint public x = 5;` (variável de estado).

- **`memory`**
  - Usado para variáveis temporárias dentro de funções.
  - Mais barato que `storage`, mas descartado após execução.
  - Ex: `string memory nome = "Ana";`

- **`calldata`**
  - Região de somente leitura, usada em parâmetros de funções `external`.
  - Mais eficiente e imutável.
  - Ex: `function saudar(string calldata nome) external {}`

---

###### ⚠️ Dicas práticas:

- Use `memory` ou `calldata` para tipos dinâmicos como `string`, `bytes` ou arrays.
- `calldata` é ideal quando os dados só serão lidos.
- Evite cópias desnecessárias entre `storage` e `memory` — isso consome mais gás.

---

#### Comparação: `contract` (Solidity) vs `class` (POO)

| Conceito             | Solidity (`contract`)         | Programação Orientada a Objetos (`class`) |
|----------------------|-------------------------------|--------------------------------------------|
| Estrutura base       | `contract Nome { ... }`       | `class Nome { ... }`                       |
| Variáveis internas   | `uint256 public number;`      | `int number;` ou `public int number;`      |
| Métodos              | `function nome(...) public`   | `public void nome(...)`                   |
| Acesso               | `public`, `private`, `internal`, `external` | `public`, `private`, `protected`        |
| Instância            | Implantado na blockchain      | Instanciado em memória                    |
| Armazenamento        | `storage` na blockchain       | Na RAM/local da aplicação                 |
| Exemplo simples      | `Counter` com `setNumber()` e `increment()` | `Counter` com `setNumber()` e `increment()` |

---

##### Exemplo Solidity

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Counter {
    uint256 public number;

    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
```
---

##### Exemplo em POO (Java-like)

```java
public class Counter {
    public int number;

    public void setNumber(int newNumber) {
        number = newNumber;
    }

    public void increment() {
        number++;
    }
}
```

---

#### Segurança Básica em Solidity

A segurança em contratos inteligentes é fundamental para garantir a integridade e proteção de dados e operações. Aqui estão três padrões importantes:

1. **Validação**:
    - É importante garantir que os dados sejam válidos antes de realizar qualquer ação. 
    - Exemplo de validação de valor (evitar valores negativos):
   
      ```solidity
      if(amount < 0) {
          revert("Amount must be positive");
      }
      ```
    - O uso de `revert` cancela a transação e devolve uma mensagem de erro, garantindo que o contrato não aceite dados inválidos.

2. **Controle de Acesso**:
    - O controle de quem pode executar funções críticas é essencial para evitar ações não autorizadas.
    - Um exemplo de modificador que verifica se a pessoa que chamou a função é o proprietário:
      
      ```solidity
        address owner;

        modifier onlyOwner() {
            if(msg.sender != owner) {
                revert("Not authorized");
            }
            _;
        }
      ```
    - Esse modificador (`onlyOwner`) impede que funções críticas sejam executadas por qualquer pessoa que não seja o proprietário do contrato.

3. **Uso de `require`**:
    - O `require` é utilizado para validar condições antes de executar uma função. Se a condição não for atendida, ele reverte a execução e devolve o gás não consumido.
    - Exemplo de uso do `require` para garantir que o valor de um depósito seja positivo:
    
      ```solidity
      function deposit(uint256 amount) public {
          require(amount > 0, "Amount must be greater than zero");
          balance[msg.sender] += amount;
      }
      ```
    - Caso o valor de `amount` seja menor ou igual a zero, a transação será revertida e a mensagem "Amount must be greater than zero" será exibida.
    - O `require` também pode ser usado para validar o estado do contrato, como verificar se o remetente de uma transferência tem saldo suficiente:

      ```solidity
      function transfer(address recipient, uint256 amount) public {
          require(balances[msg.sender] >= amount, "Insufficient balance");
          balances[msg.sender] -= amount;
          balances[recipient] += amount;
      }
      ```
    - O `require` ajuda a proteger o contrato contra operações inválidas e garante que apenas ações válidas sejam executadas.

4. **Troco de Gás**:
    - Quando uma transação falha devido ao uso de `require`, `revert` ou outras verificações, o gás consumido até o ponto da falha não é reembolsado.
    - No entanto, o **gás restante**, ou seja, o gás que não foi utilizado durante a execução, **será devolvido** ao remetente.
    - Isso significa que a transação pode falhar, mas o remetente ainda receberá de volta o gás que não foi consumido, permitindo que ele tente novamente ou execute outras transações.

> Esses padrões ajudam a garantir que o contrato execute apenas operações válidas, o controle de acesso esteja restrito a usuários autorizados e as condições sejam verificadas antes de realizar ações no contrato. Além disso, o mecanismo de gás permite que transações falhas não consumam recursos de forma excessiva, devolvendo o gás não utilizado.

---

#### Opcodes em Solidity

Os **opcodes** (códigos operacionais) são instruções de baixo nível que a Ethereum Virtual Machine (EVM) executa para processar operações em contratos inteligentes. Cada operação realizada no contrato é convertida para um opcode, que instrui a EVM sobre a ação que deve ser executada.

##### O que são Opcodes?
- **Opcode** é um código binário que instrui a EVM sobre o que fazer, como armazenar dados, realizar cálculos ou enviar tokens.
- Quando você escreve um contrato inteligente em Solidity, o compilador converte o código de alto nível para **bytecode**, que é composto por uma sequência de opcodes.
- Cada opcode tem um custo de **gás** associado, que reflete o custo computacional da operação.

##### Exemplos de Opcodes Comuns:
- **PUSH**: Empilha um valor na pilha de execução.
- **ADD**: Realiza uma operação de soma entre dois valores.
- **SSTORE**: Armazena um valor em um local específico da memória ou no armazenamento do contrato.
- **SLOAD**: Carrega um valor armazenado de volta para a memória.

##### Custo de Gas e Opcodes
- Cada **opcode** tem um custo de gás associado, dependendo da complexidade da operação.
- O **gás** é necessário para cobrir o custo das operações de bytecode que são executadas pela EVM.
- Se uma transação falhar (ex. devido a um `require` ou `revert`), o gás já consumido até o ponto da falha é perdido, mas o gás não utilizado é devolvido ao remetente.

##### Exemplo de Gasto de Gas com Opcodes
Quando você executa uma função, o código em Solidity é compilado para bytecode e, em seguida, os opcodes são executados. Suponha que você tenha uma função de depósito (`deposit`):

1. Você chama a função de depósito.
2. A função de depósito inclui verificações de `require` para validar a entrada.
3. Se a entrada for válida, o contrato executa os opcodes para alterar o saldo:
   - `PUSH` para carregar o valor.
   - `SSTORE` para armazenar o valor no armazenamento.
   - `ADD` para atualizar o saldo do remetente.
4. O gás consumido por cada opcode é somado para determinar o custo total da execução.

##### Exemplo de Uso de Opcodes com `require`:
Quando você usa o `require`, a EVM executa opcodes para verificar a condição e reverter a transação se necessário. Por exemplo:

```solidity
require(amount > 0, "Amount must be greater than zero");
```

##### Neste caso:
  - A EVM executa opcodes para verificar a condição amount > 0.
  - Se a condição não for atendida, o opcode REVERT é chamado, revertendo a transação e devolvendo o gás não consumido.


##### Resumo
  - Opcodes são as instruções de baixo nível executadas pela EVM para processar contratos inteligentes.
  - O custo de gás de cada operação depende dos opcodes executados.

> Revert e Require são exemplos de operações que geram opcodes específicos, com o require verificando condições e o revert revertendo a transação e devolvendo o gás não consumido.

---



#### Bytecodes em Solidity

Os **bytecodes** são a representação de baixo nível do código de um contrato inteligente, gerado após a compilação do código Solidity. Eles são compostos por uma sequência de **opcodes** e instruções que são executadas pela Ethereum Virtual Machine (EVM).

##### O que são Bytecodes?
- **Bytecode** é a versão compilada de um contrato inteligente que a EVM pode entender e executar.
- Quando você escreve um contrato inteligente em Solidity, o código é compilado para **bytecode** antes de ser implementado na blockchain.
- O **bytecode** é composto por uma série de **opcodes** que representam as operações que a EVM precisa executar para processar o contrato.

##### Como o Bytecode é Gerado?
- O código em **Solidity** é compilado por um compilador (como o **solc**) para **bytecode**.
- O **bytecode** contém a lógica do contrato, que inclui as funções, variáveis, e instruções de controle de fluxo, tudo em uma forma otimizada para execução pela EVM.

##### Exemplo de Bytecode:
O bytecode gerado a partir do código Solidity é uma sequência de números hexadecimais. Por exemplo:

```text
6060604052341561000f57600080fd5b6040516020806101... (continua)
```

Esse bytecode é o que será armazenado na blockchain quando o contrato for implantado. Ele inclui instruções como PUSH, ADD, CALL, SSTORE, entre outras, que são opcodes de baixo nível.

##### Como o Bytecode Funciona?
- Quando uma transação é enviada para a blockchain, a EVM pega o bytecode do contrato e o executa para realizar as operações solicitadas.

- Cada função no contrato inteligente corresponde a uma parte específica do bytecode.

- O bytecode é executado pela EVM, e o custo das operações (em termos de gás) é baseado nos opcodes que estão presentes no bytecode.

##### Custo de Gas e Bytecodes
- O custo de gás para executar um contrato inteligente depende do bytecode que está sendo executado.

- Como o bytecode contém opcodes para realizar as operações, o custo de gás varia dependendo da complexidade das instruções no bytecode.

- Cada operação que o bytecode realiza tem um custo de gás associado, que é pago pelo remetente da transação.

##### Exemplo de Gasto de Gas com Bytecode:
- Quando você chama uma função em um contrato inteligente, a EVM executa o bytecode correspondente àquela função. O custo do gás é calculado com base nas operações de bytecode que precisam ser realizadas.


###### Por exemplo:

- Você chama uma função de transferência.
- A EVM executa o bytecode associado a essa função, o que pode incluir instruções de SSTORE e SLOAD para manipular os saldos.
- Cada operação no bytecode consome uma quantidade específica de gás.

##### Resumo
- O bytecode é a forma compilada de um contrato inteligente que a EVM executa.
- Ele é gerado a partir do código Solidity e contém opcodes que instruem a EVM sobre as operações a serem executadas.
- O custo de gás de um contrato depende do bytecode, e cada opcode no bytecode tem um custo associado.
- O bytecode é a representação final do contrato inteligente, sendo essencial para sua execução e interação com a EVM. Ele está diretamente relacionado ao consumo de gás e à performance do contrato na blockchain.

---

Feito com 💜 by <a href="https://www.linkedin.com/in/danielgorgonha/">Daniel R Gorgonha</a> :wave: